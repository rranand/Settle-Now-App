import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/constant/calender_constant.dart';
import 'package:settlenow_v2/constant/input_formatter.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/screen/dashboard/personal_expense/sub_section/personal_expense_categories_section_screen.dart';
import 'package:settlenow_v2/screen/dashboard/personal_expense/sub_section/personal_expense_transaction_screen.dart';
import 'package:settlenow_v2/util/custom/custom_gesture_detector.dart';
import 'package:settlenow_v2/util/custom/multi_value_listenable_builder.dart';
import 'package:settlenow_v2/util/enum/enums.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/functions/validator.dart';
import 'package:settlenow_v2/util/graph/linear_graph_card.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/navbar_widget.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class PersonalExpenseScreen extends StatefulWidget {
  final String month;
  final String year;
  const PersonalExpenseScreen({
    super.key,
    required this.month,
    required this.year,
  });

  @override
  State<PersonalExpenseScreen> createState() => _PersonalExpenseScreenState();
}

class _PersonalExpenseScreenState extends State<PersonalExpenseScreen> {
  final ValueNotifier<bool> isSearchEnabled = ValueNotifier(false);
  final TextEditingController _searchController = TextEditingController();
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final ValueNotifier<int> _navbarSelectedIndex = ValueNotifier(0);
  final double _navBarHeight = 60;
  final DateTime _currentDate = DateTime.now();
  bool _isLivePersonalExpense = false;
  UserModel _loggedInUser = UserModel.empty();
  final List<String> headerTitle = ["Categories", "Transaction"];
  List<RoomLinkedModel> roomData = [];

  // final List<String> filterSections = [
  //   "Sort By",
  //   "Amount",
  //   "Category",
  //   "Created By",
  //   "Date Created",
  //   "Split With",
  //   "Room",
  // ];

  final List<String> filterSections = [
    "Sort By",
    "Amount",
    "Category",
    "Date Created",
    "Room",
  ];

  final ValueNotifier<int> _filterSelectedIndex = ValueNotifier(1);
  final ValueNotifier<SortBy> _selectedSortBy = ValueNotifier(
    SortBy.dateCreated,
  );
  final ValueNotifier<SortRules> _selectedSortRule = ValueNotifier(
    SortRules.mostRecent,
  );
  final ValueNotifier<Set<int>> _selectedCategory = ValueNotifier({});
  final ValueNotifier<Set<String>> _selectedRoom = ValueNotifier({});
  final ValueNotifier<RangeValues> _selectedAmountRange = ValueNotifier(
    RangeValues(0, 0),
  );
  final ValueNotifier<RangeValues> _selectedDateRange = ValueNotifier(
    RangeValues(
      DateTime.now().millisecondsSinceEpoch.toDouble(),
      DateTime.now().millisecondsSinceEpoch.toDouble(),
    ),
  );
  final TextEditingController _minController = TextEditingController(text: "0");
  final TextEditingController _maxController = TextEditingController(text: "0");
  RangeValues _amountRange = RangeValues(0, 0);
  RangeValues _dateRange = RangeValues(
    DateTime.now().millisecondsSinceEpoch.toDouble(),
    DateTime.now().millisecondsSinceEpoch.toDouble(),
  );

  void _blocListenerHandler(
    BuildContext context,
    PersonalMonthlyExpenseState state,
  ) {
    if (state is PersonalMonthlyExpenseFailure) {
      showNormalSnackBar(context, state.error);
    }
  }

  void populateRoomDataFromTransaction(
    List<PersonalExpenseTransactionModel> data,
  ) {
    Set<String> roomIDs = {};
    roomData = [];
    double maxAmount = 0;
    int minDate = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < data.length; i++) {
      maxAmount = max(maxAmount, data[i].amount);
      minDate = min(minDate, data[i].createdOn.millisecondsSinceEpoch);

      if (data[i].roomData.hasData) {
        String id =
            "${data[i].roomData.roomName}###${data[i].roomData.transactionType == "Quicksplit" ? "" : "Room"}";
        if (!roomIDs.contains(id)) {
          roomIDs.add(id);
          roomData.add(data[i].roomData);
        }
      }
    }
    maxAmount = roundUpToPowerOfTen(maxAmount.toInt()).toDouble();
    _amountRange = RangeValues(0, maxAmount);
    _dateRange = RangeValues(
      minDate.toDouble(),
      DateTime.now().millisecondsSinceEpoch.toDouble(),
    );
    _selectedAmountRange.value = _amountRange;
    _selectedDateRange.value = _dateRange;
  }

  Widget buildEnumRadioGroup<T extends Enum>(
    String displayValue,
    T enumValue,
    ValueNotifier<T> valueNotifier,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(displayValue),
      leading: Radio<T>(
        value: enumValue,
        groupValue: valueNotifier.value,
        onChanged: (T? value) {
          if (value != null) {
            valueNotifier.value = value;
          }
        },
      ),
    );
  }

  Widget buildCheckBox<T>(
    String displayValue,
    ValueNotifier<Set<T>> valueNotifier,
    T value,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(displayValue),
      leading: Checkbox(
        checkColor: Colors.white,
        activeColor: Colors.deepPurpleAccent,
        value: valueNotifier.value.contains(value),
        onChanged: (bool? selected) {
          if (selected != null) {
            final updated = Set<T>.from(valueNotifier.value);
            if (selected) {
              updated.add(value);
            } else {
              updated.remove(value);
            }
            valueNotifier.value = updated;
          }
        },
      ),
    );
  }

  Future<void> selectDate(bool isStartDate, String initialDate) async {
    DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      is24HourMode: false,
      isShowSeconds: false,
      type: OmniDateTimePickerType.date,
      firstDate: DateTime.fromMillisecondsSinceEpoch(_dateRange.start.toInt()),
      lastDate: DateTime.fromMillisecondsSinceEpoch(_dateRange.end.toInt()),
      initialDate: convertFromDateFormat(initialDate),
      borderRadius: BorderRadius.circular(16.0),
      padding: EdgeInsets.symmetric(vertical: 12),
    );
    if (dateTime != null && mounted) {
      if (isStartDate) {
        _minController.text = convertInDateFormat(dateTime);
      } else {
        _maxController.text = convertInDateFormat(dateTime);
      }
    }
  }

  Widget _filterWidget(String filterType) {
    switch (filterType) {
      case "Sort By":
        {
          return MultiValueListenableBuilder(
            listenables: [_selectedSortBy, _selectedSortRule],
            builder: (context) {
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: SortBy.values.length + SortRules.values.length,
                itemBuilder: (context, i) {
                  if (SortBy.values.length <= i) {
                    int newIndex = i - SortBy.values.length;
                    final sortRuleValue = SortRules.values[newIndex];
                    return newIndex == 0
                        ? Column(
                          children: [
                            Divider(),
                            buildEnumRadioGroup<SortRules>(
                              SortRules.values[newIndex].label,
                              sortRuleValue,
                              _selectedSortRule,
                            ),
                          ],
                        )
                        : buildEnumRadioGroup<SortRules>(
                          SortRules.values[newIndex].label,
                          sortRuleValue,
                          _selectedSortRule,
                        );
                  } else {
                    final sortValue = SortBy.values[i];
                    return buildEnumRadioGroup<SortBy>(
                      SortBy.values[i].label,
                      sortValue,
                      _selectedSortBy,
                    );
                  }
                },
              );
            },
          );
        }
      case "Category":
        {
          final ValueNotifier<Set<int>> tempSelectedCategory = ValueNotifier(
            {},
          );
          return ValueListenableBuilder(
            valueListenable: tempSelectedCategory,
            builder: (context, _, _) {
              return ListView.builder(
                itemCount: CategoryParser.expenseCategories.length,
                itemBuilder: (context, i) {
                  return buildCheckBox<int>(
                    CategoryParser.expenseCategories[i],
                    tempSelectedCategory,
                    i,
                  );
                },
              );
            },
          );
        }
      case "Room":
        {
          final state = context.read<PersonalMonthlyExpenseBloc>().state;
          final ValueNotifier<Set<String>> tempSelectedRoom = ValueNotifier({});
          if (state is PersonalMonthlyExpenseFetchSuccess &&
              roomData.isNotEmpty) {
            return ValueListenableBuilder(
              valueListenable: tempSelectedRoom,
              builder: (context, _, _) {
                return ListView.builder(
                  itemCount: roomData.length,
                  itemBuilder: (context, i) {
                    return buildCheckBox<String>(
                      "${roomData[i].roomName} ${roomData[i].transactionType == "Quicksplit" ? "" : "(Room)"}",
                      tempSelectedRoom,
                      roomData[i].id,
                    );
                  },
                );
              },
            );
          } else {
            return noRecordFoundWidget("No Data Found", context);
          }
        }
      case "Date Created":
        {
          final state = context.read<PersonalMonthlyExpenseBloc>().state;
          _minController.text = convertInDateFormat(
            DateTime.fromMillisecondsSinceEpoch(
              _selectedDateRange.value.start.toInt(),
            ),
          );
          _maxController.text = convertInDateFormat(
            DateTime.fromMillisecondsSinceEpoch(
              _selectedDateRange.value.end.toInt(),
            ),
          );

          if (state is PersonalMonthlyExpenseFetchSuccess) {
            return ValueListenableBuilder(
              valueListenable: _selectedDateRange,
              builder: (context, _, _) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: CustomFormField.textFormField(
                          _minController,
                          readOnly: true,
                          labelText: 'From Date',
                          suffixIcon: Icon(Iconsax.calendar),
                          inputDecoration: TextFormFieldInputBorder.underLine,
                          borderColor: Colors.black87,
                          onTap: () async {
                            await selectDate(true, _minController.text);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: CustomFormField.textFormField(
                          _maxController,
                          readOnly: true,
                          labelText: 'To Date',
                          suffixIcon: Icon(Iconsax.calendar),
                          inputDecoration: TextFormFieldInputBorder.underLine,
                          borderColor: Colors.black87,
                          onTap: () async {
                            await selectDate(false, _maxController.text);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return noRecordFoundWidget("No Data Found", context);
          }
        }
      case "Amount":
        {
          final state = context.read<PersonalMonthlyExpenseBloc>().state;
          final ValueNotifier<RangeValues> tempSelectedAmountRange =
              ValueNotifier(_amountRange);
          _minController.text =
              tempSelectedAmountRange.value.start.toInt().toString();
          _maxController.text =
              tempSelectedAmountRange.value.end.toInt().toString();

          if (state is PersonalMonthlyExpenseFetchSuccess) {
            return ValueListenableBuilder(
              valueListenable: tempSelectedAmountRange,
              builder: (context, _, _) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RangeSlider(
                        values: tempSelectedAmountRange.value,
                        onChanged: (value) {
                          tempSelectedAmountRange.value = value;
                          _minController.text = value.start.toInt().toString();
                          _maxController.text = value.end.toInt().toString();
                        },
                        min: _amountRange.start,
                        max: _amountRange.end,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: CustomFormField.textFormField(
                          _minController,
                          labelText: 'Min Amount',
                          textInputType: TextInputType.number,
                          inputFormatters: [AmountInputFormatter()],
                          onChanged: (value) {
                            if (value != null) {
                              String? res = CustomValidator.validateAmount(
                                value,
                                RangeValues(
                                  _amountRange.start,
                                  min(
                                    _amountRange.end,
                                    tempSelectedAmountRange.value.end,
                                  ),
                                ),
                              );
                              if (res == null) {
                                double amount = double.parse(value);
                                tempSelectedAmountRange.value = RangeValues(
                                  amount,
                                  tempSelectedAmountRange.value.end,
                                );
                              }
                            }
                          },
                          suffixIcon: UiConstant.indianRupeeSymbol,
                          validator:
                              (value) => CustomValidator.validateAmount(
                                value,
                                _amountRange,
                              ),
                          inputDecoration: TextFormFieldInputBorder.underLine,
                          borderColor: Colors.black87,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: CustomFormField.textFormField(
                          _maxController,
                          labelText: 'Max Amount',
                          textInputType: TextInputType.number,
                          inputFormatters: [AmountInputFormatter()],
                          onChanged: (value) {
                            if (value != null) {
                              String? res = CustomValidator.validateAmount(
                                value,
                                RangeValues(
                                  max(
                                    _amountRange.start,
                                    tempSelectedAmountRange.value.start,
                                  ),
                                  _amountRange.end,
                                ),
                              );
                              if (res == null) {
                                double amount = double.parse(value);
                                tempSelectedAmountRange.value = RangeValues(
                                  tempSelectedAmountRange.value.start,
                                  amount,
                                );
                              }
                            }
                          },
                          suffixIcon: UiConstant.indianRupeeSymbol,
                          validator:
                              (value) => CustomValidator.validateAmount(
                                value,
                                tempSelectedAmountRange.value,
                              ),
                          inputDecoration: TextFormFieldInputBorder.underLine,
                          borderColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return noRecordFoundWidget("No Data Found", context);
          }
        }
      default:
        {
          return noRecordFoundWidget("Filter Not Found", context);
        }
    }
  }

  void resetfilterHandler(String filterType) {
    switch (filterType) {
      case "Sort By":
        {
          _selectedSortBy.value = SortBy.dateCreated;
          _selectedSortRule.value = SortRules.mostRecent;
        }
      case "Amount":
        {
          _selectedAmountRange.value = _amountRange;
        }
      case "Category":
        {
          _selectedCategory.value = {};
        }
      case "Date Created":
        {
          _selectedDateRange.value = _dateRange;
        }
      case "Room":
        {
          _selectedRoom.value = {};
        }
      case "":
        {
          for (int i = 0; i < filterSections.length; i++) {
            resetfilterHandler(filterSections[i]);
          }
        }
      default:
        {}
    }
  }

  void filterModelBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: const EdgeInsets.all(
            16.0,
          ).add(EdgeInsets.only(bottom: keyboardHeight)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(height: 4, width: 60, color: Colors.grey[300]),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Filters",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                  ),
                  IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: _filterSelectedIndex,
                builder: (context, _, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              List.generate(filterSections.length, (index) {
                                bool isSelected =
                                    index == _filterSelectedIndex.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: CustomButton.customTextButton(
                                    filterSections[index],
                                    buttonWidth: 120,
                                    buttonHeight: 40,
                                    borderRadius: 10,
                                    borderColor:
                                        isSelected
                                            ? Colors.deepPurpleAccent
                                            : Colors.grey.shade100,
                                    backgroundColor:
                                        isSelected
                                            ? Colors.deepPurpleAccent
                                            : Colors.grey.shade100,
                                    buttonTextColor:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black,
                                    onPressed: () {
                                      _filterSelectedIndex.value = index;
                                    },
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  filterSections[_filterSelectedIndex.value],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.refresh),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 400,
                              child: _filterWidget(
                                filterSections[_filterSelectedIndex.value],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton.customTextButton(
                    "Reset All",
                    buttonWidth: 120,
                    buttonHeight: 40,
                    borderRadius: 10,
                    borderColor: Colors.grey.shade100,
                    backgroundColor: Colors.grey.shade100,
                    buttonTextColor: Colors.black,
                    onPressed: () {},
                  ),
                  CustomButton.customTextButton(
                    "Apply",
                    buttonWidth: 120,
                    buttonHeight: 40,
                    borderRadius: 10,
                    borderColor: Colors.deepPurpleAccent,
                    backgroundColor: Colors.deepPurpleAccent,
                    buttonTextColor: Colors.white,
                    onPressed: () {
                      //_filterSelectedIndex.value = index;
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    if (_currentDate.year.toString() == widget.year &&
        CalenderConstant.getIndexOfMonth(widget.month) + 1 ==
            _currentDate.month) {
      _isLivePersonalExpense = true;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      final state = context.read<PersonalMonthlyExpenseBloc>().state;
      if (!(state is PersonalMonthlyExpenseFetchSuccess &&
          state.id == (widget.year + widget.month).toLowerCase())) {
        context.read<PersonalMonthlyExpenseBloc>().add(
          PersonalMonthlyExpenseFetch(
            authToken: _loggedInUser.authToken,
            year: widget.year,
            month: widget.month,
          ),
        );
      }
    }
  }

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(context, "Please re-login...Session expired!");
      return;
    }
    context.read<PersonalMonthlyExpenseBloc>().add(
      PersonalMonthlyExpenseFetch(
        authToken: _loggedInUser.authToken,
        year: widget.year,
        month: widget.month,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= UiConstant.maxWidth;
    EdgeInsets paddingInsets = _mainScreenPadding;
    if (!isWide) {
      paddingInsets = EdgeInsets.zero;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${capatilizeFirstLetter(widget.month)}, ${widget.year}"),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
        actions: appBarActionButton(context, [
          InkWell(
            borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
            child: Icon(Icons.search),
            onTap: () {
              isSearchEnabled.value = !isSearchEnabled.value;
              _searchController.text = "";
              if (isSearchEnabled.value && _navbarSelectedIndex.value == 0) {
                _navbarSelectedIndex.value = 1;
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
              child: Icon(Iconsax.filter),
              onTap: () => filterModelBottomSheet(context),
            ),
          ),
        ]),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomGestureDetector(
          navBarIndex: _navbarSelectedIndex,
          totalTitle: headerTitle.length,
          child: BlocConsumer<
            PersonalMonthlyExpenseBloc,
            PersonalMonthlyExpenseState
          >(
            listener: _blocListenerHandler,
            builder: (context, state) {
              if (state is PersonalMonthlyExpenseFetchSuccess &&
                  state.data.isEmpty) {
                return noRecordFoundWidget("No Transaction Found", context);
              }
              return CustomScrollView(
                slivers: [
                  ValueListenableBuilder(
                    valueListenable: isSearchEnabled,
                    builder: (BuildContext context, bool value, Widget? _) {
                      if (!value) {
                        return SliverToBoxAdapter(child: SizedBox.shrink());
                      }
                      return SliverPadding(
                        padding: _mainScreenPadding,
                        sliver: SliverAppBar(
                          automaticallyImplyLeading: false,
                          pinned: value,
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.white,
                          title: CustomFormField.searchBar(
                            "Search",
                            isSearchEnabled,
                            _searchController,
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: isSearchEnabled,
                    builder: (BuildContext context, bool value, Widget? _) {
                      if (value) {
                        return SliverToBoxAdapter(child: SizedBox.shrink());
                      }
                      return SliverPadding(
                        padding: paddingInsets,
                        sliver: SliverAppBar(
                          toolbarHeight: 330,
                          automaticallyImplyLeading: false,
                          backgroundColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: false,
                            title: Builder(
                              builder: (context) {
                                if (state
                                    is PersonalMonthlyExpenseFetchSuccess) {
                                  populateRoomDataFromTransaction(state.data);
                                  return LinearGraphCard(
                                    expenses:
                                        state.data
                                            .map((ele) => ele.amount)
                                            .toList(),
                                  );
                                } else {
                                  return CustomShimmerEffect.placeHolderShimmerEffect(
                                    Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 24,
                                              horizontal: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(24),
                                                bottomRight: Radius.circular(
                                                  24,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _navbarSelectedIndex,
                    builder: (context, value, _) {
                      return SliverPadding(
                        padding: paddingInsets,
                        sliver: SliverAppBar(
                          pinned: true,
                          toolbarHeight: _navBarHeight,
                          automaticallyImplyLeading: false,
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.transparent,
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            title: NavBarCard(
                              headerTitle: headerTitle,
                              selectedIndex: _navbarSelectedIndex,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SliverPadding(
                    padding: paddingInsets,
                    sliver: ValueListenableBuilder(
                      valueListenable: _navbarSelectedIndex,
                      builder: (context, value, _) {
                        if (value == 0) {
                          return PersonalExpenseCategoriesSectionScreen();
                        } else {
                          return PersonalExpenseTransactionScreen(
                            searchController: _searchController,
                          );
                        }
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: UiConstant.spaceAtBottom + _navBarHeight,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton:
          _isLivePersonalExpense
              ? CustomButton.customFloatingButton(Iconsax.add, () {
                context.push(
                  "${RouterConstants.personalExpenseRouteName}/${widget.year}/${widget.month}${RouterConstants.personalExpenseAddExpenseRouteName}",
                );
              })
              : null,
    );
  }
}
