import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/room/lenden_room_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/bloc/room/each_room/room_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/filter/filter_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_info/room_info_cubit.dart';
import 'package:settlenow_v2/model/lenden_room_model.dart';
import 'package:settlenow_v2/model/personal_expense_transaction_model.dart';
import 'package:settlenow_v2/model/transaction_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/custom/category_parser.dart';
import 'package:settlenow_v2/util/custom/multi_value_listenable_builder.dart';
import 'package:settlenow_v2/util/enum/enums.dart';
import 'package:settlenow_v2/util/enum/filter_enums.dart';
import 'package:settlenow_v2/util/enum/transaction_type.dart';
import 'package:settlenow_v2/util/filter/filter_widget.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/functions/validator.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class FilterSheet extends StatefulWidget {
  final String id;
  final TransactionType transactionType;

  const FilterSheet({
    super.key,
    required this.id,
    required this.transactionType,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String loggedInUserID = "";
  List<String> filterSections = [];
  List<RoomLinkedModel> roomData = [];
  List<UserModel> userData = [];
  final ValueNotifier<int> _filterSelectedIndex = ValueNotifier(0);
  final ValueNotifier<SortBy> _selectedSortBy = ValueNotifier(
    SortBy.dateCreated,
  );
  final ValueNotifier<SortRules> _selectedSortRule = ValueNotifier(
    SortRules.ascending,
  );
  final ValueNotifier<LendenType> _selectedLendenType = ValueNotifier(
    LendenType.none,
  );
  final ValueNotifier<Set<int>> _selectedCategory = ValueNotifier({});
  final ValueNotifier<Set<String>> _selectedRoom = ValueNotifier({});
  final ValueNotifier<Set<String>> _selectedUser = ValueNotifier({});
  final ValueNotifier<Set<String>> _selectedSplitWith = ValueNotifier({});
  final ValueNotifier<RangeValues> _selectedAmountRange = ValueNotifier(
    RangeValues(0, 0),
  );
  final ValueNotifier<DateTimeRange> _selectedDateRange = ValueNotifier(
    DateTimeRange(start: DateTime.now(), end: DateTime.now()),
  );
  final TextEditingController _minController = TextEditingController(text: "0");
  final TextEditingController _maxController = TextEditingController(text: "0");

  RangeValues _amountRange = RangeValues(0, 0);
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  bool isFilterApplied(String filterType) {
    switch (filterType) {
      case "Sort By":
        {
          return !(_selectedSortBy.value == SortBy.dateCreated &&
              _selectedSortRule.value == SortRules.ascending);
        }
      case "Amount":
        {
          return _selectedAmountRange.value.hashCode != _amountRange.hashCode;
        }
      case "Category":
        {
          return _selectedCategory.value.isNotEmpty;
        }
      case "Date Created":
        {
          return _selectedDateRange.value.hashCode != _dateRange.hashCode;
        }
      case "Room":
        {
          return _selectedRoom.value.isNotEmpty;
        }
      case "Type":
        {
          return _selectedLendenType.value != LendenType.none;
        }
      case "Created By":
        {
          return _selectedUser.value.isNotEmpty;
        }
      case "Split With":
        {
          return _selectedSplitWith.value.isNotEmpty;
        }
      case "":
        {
          bool flag = false;
          for (int i = 0; !flag && i < filterSections.length; i++) {
            flag = flag || isFilterApplied(filterSections[i]);
          }
          return flag;
        }
      default:
        {
          return false;
        }
    }
  }

  void resetfilterHandler(String filterType) {
    switch (filterType) {
      case "Sort By":
        {
          _selectedSortBy.value = SortBy.dateCreated;
          _selectedSortRule.value = SortRules.ascending;
        }
      case "Amount":
        {
          _selectedAmountRange.value = _amountRange;
          if (filterType == filterSections[_filterSelectedIndex.value]) {
            _minController.text = "0";
            _maxController.text = _amountRange.end.toInt().toString();
          }
        }
      case "Category":
        {
          _selectedCategory.value = {};
        }
      case "Date Created":
        {
          _selectedDateRange.value = _dateRange;
          if (filterType == filterSections[_filterSelectedIndex.value]) {
            _minController.text = convertInDateFormat(_dateRange.start);
            _maxController.text = convertInDateFormat(_dateRange.end);
          }
        }
      case "Room":
        {
          _selectedRoom.value = {};
        }
      case "Type":
        {
          _selectedLendenType.value = LendenType.none;
        }
      case "Created By":
        {
          _selectedUser.value = {};
        }
      case "Split With":
        {
          _selectedSplitWith.value = {};
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

  void _applyFilter() {
    configureFilter(true);
    context.pop(["Apply"]);
  }

  void _closeFilter(bool popContext) {
    configureFilter(false);
    if (popContext) {
      context.pop(["Close"]);
    }
  }

  void populateData() {
    switch (widget.transactionType) {
      case (TransactionType.personal):
        {
          final state = context.read<PersonalMonthlyExpenseBloc>().state;
          List<PersonalExpenseTransactionModel> data = [];
          roomData = [];

          if (state is PersonalMonthlyExpenseFetchSuccess) {
            data = state.data;
            Set<String> roomIDs = {};
            double maxAmount = 0;
            DateTime minDate = DateTime.now();
            DateTime maxDate = DateTime(1990);

            for (int i = 0; i < data.length; i++) {
              maxAmount = max(maxAmount, data[i].amount);
              if (minDate.millisecondsSinceEpoch >
                  data[i].createdOn.millisecondsSinceEpoch) {
                minDate = data[i].createdOn;
              }
              if (maxDate.millisecondsSinceEpoch <
                  data[i].createdOn.millisecondsSinceEpoch) {
                maxDate = data[i].createdOn;
              }

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
            if (maxAmount == 0) {
              maxAmount = 1;
            }
            if (minDate.isAfter(maxDate)) {
              maxDate = minDate.add(Duration(days: 1));
            }
            _amountRange = RangeValues(0, maxAmount);
            _dateRange = DateTimeRange(start: minDate, end: maxDate);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _selectedAmountRange.value = _amountRange;
              _selectedDateRange.value = _dateRange;
              copyFilter();
            });
          }
        }
      case (TransactionType.lenden):
        {
          final state = context.read<LendenRoomBloc>().state;
          List<LendenTransactionModel> data = [];

          if (state is LendenRoomFetchSuccess) {
            data = state.data;
            double maxAmount = 0;
            DateTime minDate = DateTime.now();
            DateTime maxDate = DateTime(1990);

            for (int i = 0; i < data.length; i++) {
              maxAmount = max(maxAmount, data[i].amount.abs());
              if (minDate.millisecondsSinceEpoch >
                  data[i].createdOn.millisecondsSinceEpoch) {
                minDate = data[i].createdOn;
              }
              if (maxDate.millisecondsSinceEpoch <
                  data[i].createdOn.millisecondsSinceEpoch) {
                maxDate = data[i].createdOn;
              }
            }
            userData = state.roomData.users.map((e) => e as UserModel).toList();
            maxAmount = roundUpToPowerOfTen(maxAmount.toInt()).toDouble();
            if (maxAmount == 0) {
              maxAmount = 1;
            }
            if (minDate.isAfter(maxDate)) {
              maxDate = minDate.add(Duration(days: 1));
            }
            _amountRange = RangeValues(0, maxAmount);
            _dateRange = DateTimeRange(start: minDate, end: maxDate);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _selectedAmountRange.value = _amountRange;
              _selectedDateRange.value = _dateRange;
              copyFilter();
            });
          }
        }
      case (TransactionType.room):
        {
          final state = context.read<RoomBloc>().state;
          final roomInfoState = context.read<RoomInfoCubit>().state;
          List<TransactionModel> data = [];

          if (state is RoomFetchSuccess) {
            data = state.data;
            double maxAmount = 0;
            DateTime minDate = DateTime.now();
            DateTime maxDate = DateTime(1990);

            for (int i = 0; i < data.length; i++) {
              maxAmount = max(maxAmount, data[i].amount);
              if (minDate.millisecondsSinceEpoch >
                  data[i].createdOn.millisecondsSinceEpoch) {
                minDate = data[i].createdOn;
              }
              if (maxDate.millisecondsSinceEpoch <
                  data[i].createdOn.millisecondsSinceEpoch) {
                maxDate = data[i].createdOn;
              }
            }
            if (roomInfoState is RoomInfoSuccess) {
              userData = roomInfoState.data.users.map((e) => e.user).toList();
            }
            maxAmount = roundUpToPowerOfTen(maxAmount.toInt()).toDouble();
            if (maxAmount == 0) {
              maxAmount = 1;
            }
            if (minDate.isAfter(maxDate)) {
              maxDate = minDate.add(Duration(days: 1));
            }
            _amountRange = RangeValues(0, maxAmount);
            _dateRange = DateTimeRange(start: minDate, end: maxDate);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _selectedAmountRange.value = _amountRange;
              _selectedDateRange.value = _dateRange;
              copyFilter();
            });
          }
        }
      default:
        {}
    }
  }

  void filterSectionHandler() {
    switch (widget.transactionType) {
      case (TransactionType.personal):
        {
          filterSections = [
            "Sort By",
            "Amount",
            "Category",
            "Date Created",
            "Room",
          ];
        }
      case (TransactionType.lenden):
        {
          filterSections = [
            "Sort By",
            "Amount",
            "Created By",
            "Date Created",
            "Type",
          ];
        }
      case (TransactionType.room):
        {
          filterSections = [
            "Sort By",
            "Amount",
            "Category",
            "Created By",
            "Date Created",
            "Split With",
          ];
        }
      default:
        {}
    }
  }

  @override
  void initState() {
    super.initState();
    filterSectionHandler();
    populateData();
    final state = context.read<AuthBloc>().state;

    if (state is AuthLoginSuccess) {
      loggedInUserID = state.userData.id;
    }
  }

  void copyFilter() {
    final state = context.read<FilterCubit>().state;

    if (state.id != widget.id) {
      return;
    }

    switch (widget.transactionType) {
      case (TransactionType.personal):
        {
          _selectedSortBy.value = state.sortBy ?? SortBy.dateCreated;
          _selectedSortRule.value = state.sortRule ?? SortRules.ascending;
          _selectedCategory.value = state.selectedCategories;
          _selectedAmountRange.value = state.amountRange ?? _amountRange;
          _selectedDateRange.value = state.dateRange ?? _dateRange;
          _selectedRoom.value = state.selectedRoom;
        }
      case (TransactionType.lenden):
        {
          _selectedSortBy.value = state.sortBy ?? SortBy.dateCreated;
          _selectedSortRule.value = state.sortRule ?? SortRules.ascending;
          _selectedAmountRange.value = state.amountRange ?? _amountRange;
          _selectedDateRange.value = state.dateRange ?? _dateRange;
          _selectedUser.value = state.selectedUsers;
          _selectedLendenType.value = state.lendenType ?? LendenType.none;
        }
      case (TransactionType.room):
        {
          _selectedSortBy.value = state.sortBy ?? SortBy.dateCreated;
          _selectedSortRule.value = state.sortRule ?? SortRules.ascending;
          _selectedAmountRange.value = state.amountRange ?? _amountRange;
          _selectedDateRange.value = state.dateRange ?? _dateRange;
          _selectedUser.value = state.selectedUsers;
          _selectedCategory.value = state.selectedCategories;
          _selectedSplitWith.value = state.splitWith;
        }
      default:
        {}
    }
  }

  void configureFilter(bool updateState) {
    switch (widget.transactionType) {
      case (TransactionType.personal):
        {
          final state = context.read<FilterCubit>().state;
          final expenseState = context.read<PersonalMonthlyExpenseBloc>().state;
          List<PersonalExpenseTransactionModel> data = [];
          if (expenseState is PersonalMonthlyExpenseFetchSuccess) {
            data = expenseState.data;
          }

          if (updateState || state.id != widget.id) {
            context.read<FilterCubit>().updateState(
              FilterState(
                id: widget.id,
                sortBy: _selectedSortBy.value,
                sortRule: _selectedSortRule.value,
                selectedCategories: _selectedCategory.value,
                selectedRoom: _selectedRoom.value,
                amountRange: _selectedAmountRange.value,
                dateRange: _selectedDateRange.value,
                data: data,
                isFilterApplied: isFilterApplied(""),
              ),
              loggedInUserID,
              widget.transactionType,
            );
          } else {
            copyFilter();
          }
        }
      case (TransactionType.lenden):
        {
          final state = context.read<FilterCubit>().state;
          final expenseState = context.read<LendenRoomBloc>().state;
          List<LendenTransactionModel> data = [];
          if (expenseState is LendenRoomFetchSuccess) {
            data = expenseState.data;
          }

          if (updateState || state.id != widget.id) {
            context.read<FilterCubit>().updateState(
              FilterState(
                id: widget.id,
                sortBy: _selectedSortBy.value,
                sortRule: _selectedSortRule.value,
                selectedUsers: _selectedUser.value,
                lendenType: _selectedLendenType.value,
                amountRange: _selectedAmountRange.value,
                dateRange: _selectedDateRange.value,
                data: data,
                isFilterApplied: isFilterApplied(""),
              ),
              loggedInUserID,
              widget.transactionType,
            );
          } else {
            copyFilter();
          }
        }
      case (TransactionType.room):
        {
          final state = context.read<FilterCubit>().state;
          final expenseState = context.read<RoomBloc>().state;
          List<TransactionModel> data = [];
          if (expenseState is RoomFetchSuccess) {
            data = expenseState.data;
          }

          if (updateState || state.id != widget.id) {
            context.read<FilterCubit>().updateState(
              FilterState(
                id: widget.id,
                sortBy: _selectedSortBy.value,
                sortRule: _selectedSortRule.value,
                selectedUsers: _selectedUser.value,
                selectedCategories: _selectedCategory.value,
                amountRange: _selectedAmountRange.value,
                dateRange: _selectedDateRange.value,
                data: data,
                splitWith: _selectedSplitWith.value,
                isFilterApplied: isFilterApplied(""),
              ),
              loggedInUserID,
              widget.transactionType,
            );
          } else {
            copyFilter();
          }
        }
      default:
        {}
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
                            FilterWidget.buildEnumRadioGroup<SortRules>(
                              sortRuleValue.label,
                              sortRuleValue,
                              context,
                              _selectedSortRule,
                            ),
                          ],
                        )
                        : FilterWidget.buildEnumRadioGroup<SortRules>(
                          sortRuleValue.label,
                          sortRuleValue,
                          context,
                          _selectedSortRule,
                        );
                  } else {
                    final sortValue = SortBy.values[i];
                    return FilterWidget.buildEnumRadioGroup<SortBy>(
                      sortValue.label,
                      sortValue,
                      context,
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
          return ValueListenableBuilder(
            valueListenable: _selectedCategory,
            builder: (context, _, _) {
              return ListView.builder(
                itemCount: CategoryParser.expenseCategories.length,
                itemBuilder: (context, i) {
                  return FilterWidget.buildCheckBox<int>(
                    CategoryParser.expenseCategories[i],
                    _selectedCategory,
                    context,
                    i,
                    CategoryParser.expenseCategories.length,
                  );
                },
              );
            },
          );
        }
      case "Room":
        {
          return roomData.isNotEmpty
              ? ValueListenableBuilder(
                valueListenable: _selectedRoom,
                builder: (context, _, _) {
                  return ListView.builder(
                    itemCount: roomData.length,
                    itemBuilder: (context, i) {
                      return FilterWidget.buildCheckBox<String>(
                        "${roomData[i].roomName} ${roomData[i].transactionType == "Quicksplit" ? "" : "(Room)"}",
                        _selectedRoom,
                        context,
                        "${roomData[i].roomName}###${roomData[i].transactionType == "Quicksplit" ? "" : "Room"}",
                        roomData.length,
                      );
                    },
                  );
                },
              )
              : noRecordFoundWidget("No Data Found", context);
        }
      case "Date Created":
        {
          _minController.text = convertInDateFormat(
            _selectedDateRange.value.start,
          );
          _maxController.text = convertInDateFormat(
            _selectedDateRange.value.end,
          );

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
                        suffixIcon: Icon(Iconsax.calendar_copy),
                        inputDecoration: TextFormFieldInputBorder.underLine,
                        borderColor: Colors.black87,
                        onTap: () async {
                          DateTimeRange? updatedRange =
                              await FilterWidget.selectDate(
                                context,
                                _selectedDateRange.value,
                                _dateRange,
                                true,
                              );
                          if (updatedRange != null) {
                            _selectedDateRange.value = updatedRange;
                            _minController.text = convertInDateFormat(
                              updatedRange.start,
                            );
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: CustomFormField.textFormField(
                        _maxController,
                        readOnly: true,
                        labelText: 'To Date',
                        suffixIcon: Icon(Iconsax.calendar_copy),
                        inputDecoration: TextFormFieldInputBorder.underLine,
                        borderColor: Colors.black87,
                        onTap: () async {
                          DateTimeRange? updatedRange =
                              await FilterWidget.selectDate(
                                context,
                                _selectedDateRange.value,
                                _dateRange,
                                false,
                              );
                          if (updatedRange != null) {
                            _selectedDateRange.value = updatedRange;
                            _maxController.text = convertInDateFormat(
                              updatedRange.end,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      case "Type":
        {
          return ValueListenableBuilder(
            valueListenable: _selectedLendenType,
            builder: (context, _, _) {
              return Wrap(
                spacing: UiConstant.spaceBetweenCard,
                children: List.generate(LendenType.values.length, (i) {
                  final value = LendenType.values[i];
                  if (value.label == "None") {
                    return SizedBox.shrink();
                  }
                  return InkWell(
                    borderRadius: BorderRadius.circular(
                      UiConstant.cardBorderRadius,
                    ),
                    onTap: () => _selectedLendenType.value = value,
                    child: FilterWidget.buildCardWidget<LendenType>(
                      value,
                      _selectedLendenType.value,
                      context,
                      value.label,
                    ),
                  );
                }),
              );
            },
          );
        }
      case "Created By":
        {
          return userData.isNotEmpty
              ? ValueListenableBuilder(
                valueListenable: _selectedUser,
                builder: (context, _, _) {
                  return Wrap(
                    spacing: UiConstant.spaceBetweenCard,
                    children: List.generate(userData.length, (index) {
                      bool isSelected = _selectedUser.value.contains(
                        userData[index].id,
                      );
                      return InkWell(
                        borderRadius: BorderRadius.circular(
                          UiConstant.cardBorderRadius,
                        ),
                        onTap: () {
                          Set<String> updatedSet = Set<String>.from(
                            _selectedUser.value,
                          );
                          if (_selectedUser.value.contains(
                            userData[index].id,
                          )) {
                            updatedSet.remove(userData[index].id);
                          } else {
                            updatedSet.add(userData[index].id);
                          }
                          if (updatedSet.length == userData.length) {
                            _selectedUser.value = {};
                          } else {
                            _selectedUser.value = updatedSet;
                          }
                        },
                        child: FilterWidget.buildCardWidget<int>(
                          index,
                          isSelected ? index : -1,
                          context,
                          userData[index].id == loggedInUserID ? "You" : "",
                          user:
                              userData[index].id == loggedInUserID
                                  ? null
                                  : userData[index],
                        ),
                      );
                    }),
                  );
                },
              )
              : noRecordFoundWidget("No Data Found", context);
        }
      case "Split With":
        {
          return userData.isNotEmpty
              ? ValueListenableBuilder(
                valueListenable: _selectedSplitWith,
                builder: (context, _, _) {
                  return Wrap(
                    spacing: UiConstant.spaceBetweenCard,
                    children: List.generate(userData.length, (index) {
                      bool isSelected = _selectedSplitWith.value.contains(
                        userData[index].id,
                      );
                      return InkWell(
                        borderRadius: BorderRadius.circular(
                          UiConstant.cardBorderRadius,
                        ),
                        onTap: () {
                          Set<String> updatedSet = Set<String>.from(
                            _selectedSplitWith.value,
                          );
                          if (_selectedSplitWith.value.contains(
                            userData[index].id,
                          )) {
                            updatedSet.remove(userData[index].id);
                          } else {
                            updatedSet.add(userData[index].id);
                          }
                          if (updatedSet.length == userData.length) {
                            _selectedSplitWith.value = {};
                          } else {
                            _selectedSplitWith.value = updatedSet;
                          }
                        },
                        child: FilterWidget.buildCardWidget<int>(
                          index,
                          isSelected ? index : -1,
                          context,
                          userData[index].id == loggedInUserID ? "You" : "",
                          user:
                              userData[index].id == loggedInUserID
                                  ? null
                                  : userData[index],
                        ),
                      );
                    }),
                  );
                },
              )
              : noRecordFoundWidget("No Data Found", context);
        }
      case "Amount":
        {
          _minController.text =
              _selectedAmountRange.value.start.toInt().toString();
          _maxController.text =
              _selectedAmountRange.value.end.toInt().toString();

          return ValueListenableBuilder(
            valueListenable: _selectedAmountRange,
            builder: (context, _, _) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomFormField.textFormField(
                      _minController,
                      labelText: 'Min Amount',
                      textInputType: TextInputType.number,
                      onChanged: (value) {
                        if (value != null) {
                          String? res = CustomValidator.validateAmount(
                            value,
                            RangeValues(
                              _amountRange.start,
                              min(
                                _amountRange.end,
                                _selectedAmountRange.value.end,
                              ),
                            ),
                          );
                          if (res == null) {
                            double amount = double.parse(value);
                            _selectedAmountRange.value = RangeValues(
                              amount,
                              _selectedAmountRange.value.end,
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
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: CustomFormField.textFormField(
                        _maxController,
                        labelText: 'Max Amount',
                        textInputType: TextInputType.number,
                        onChanged: (value) {
                          if (value != null) {
                            String? res = CustomValidator.validateAmount(
                              value,
                              RangeValues(
                                max(
                                  _amountRange.start,
                                  _selectedAmountRange.value.start,
                                ),
                                _amountRange.end,
                              ),
                            );
                            if (res == null) {
                              double amount = double.parse(value);
                              _selectedAmountRange.value = RangeValues(
                                _selectedAmountRange.value.start,
                                amount,
                              );
                            }
                          }
                        },
                        suffixIcon: UiConstant.indianRupeeSymbol,
                        validator:
                            (value) => CustomValidator.validateAmount(
                              value,
                              _selectedAmountRange.value,
                            ),
                        inputDecoration: TextFormFieldInputBorder.underLine,
                        borderColor: Colors.black87,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Range",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          RangeSlider(
                            values: _selectedAmountRange.value,
                            onChanged: (value) {
                              _selectedAmountRange.value = value;
                              _minController.text =
                                  value.start.toInt().toString();
                              _maxController.text =
                                  value.end.toInt().toString();
                            },
                            min: _amountRange.start,
                            max: _amountRange.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      default:
        {
          return noRecordFoundWidget("Filter Not Found", context);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(child: Container(height: 4, width: 60, color: Colors.grey[300])),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Filters",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    resetfilterHandler(
                      filterSections[_filterSelectedIndex.value],
                    );
                  },
                  icon: Icon(Icons.refresh),
                ),
                IconButton(
                  onPressed: () => _closeFilter(true),
                  icon: Icon(Icons.close),
                ),
              ],
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
                          bool isSelected = index == _filterSelectedIndex.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Stack(
                              children: [
                                CustomButton.customTextButton(
                                  filterSections[index],
                                  buttonWidth: 120,
                                  buttonHeight: 40,
                                  borderRadius: 10,
                                  borderColor:
                                      isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(
                                            context,
                                          ).scaffoldBackgroundColor,
                                  backgroundColor:
                                      isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(
                                            context,
                                          ).scaffoldBackgroundColor,
                                  buttonTextColor:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                  onPressed: () {
                                    _filterSelectedIndex.value = index;
                                  },
                                ),
                                MultiValueListenableBuilder(
                                  listenables: [
                                    _selectedSortBy,
                                    _selectedSortRule,
                                    _selectedLendenType,
                                    _selectedUser,
                                    _selectedAmountRange,
                                    _selectedCategory,
                                    _selectedDateRange,
                                    _selectedRoom,
                                  ],
                                  builder: (context) {
                                    bool haveFilter = isFilterApplied(
                                      filterSections[index],
                                    );
                                    return haveFilter
                                        ? Positioned(
                                          top: 5,
                                          right: 5,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                        : SizedBox();
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 400,
                    child: _filterWidget(
                      filterSections[_filterSelectedIndex.value],
                    ),
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
              onPressed: () {
                resetfilterHandler("");
                configureFilter(true);
              },
            ),
            CustomButton.customTextButton(
              "Apply",
              buttonWidth: 120,
              buttonHeight: 40,
              borderRadius: 10,
              borderColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).primaryColor,
              buttonTextColor: Colors.white,
              onPressed: _applyFilter,
            ),
          ],
        ),
      ],
    );
  }
}
