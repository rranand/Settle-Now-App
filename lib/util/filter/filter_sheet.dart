import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/constant/input_formatter.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/filter/filter_cubit.dart';
import 'package:settlenow_v2/model/personal_expense_transaction_model.dart';
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
  final List<String> filterSections;
  final String id;
  final TransactionType transactionType;

  const FilterSheet({
    super.key,
    required this.filterSections,
    required this.id,
    required this.transactionType,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  List<RoomLinkedModel> roomData = [];
  final ValueNotifier<int> _filterSelectedIndex = ValueNotifier(0);
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
              _selectedSortRule.value == SortRules.mostRecent);
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
      case "":
        {
          bool flag = false;
          for (int i = 0; !flag && i < widget.filterSections.length; i++) {
            flag = flag || isFilterApplied(widget.filterSections[i]);
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
          _selectedSortRule.value = SortRules.mostRecent;
        }
      case "Amount":
        {
          _selectedAmountRange.value = _amountRange;
          if (filterType == widget.filterSections[_filterSelectedIndex.value]) {
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
          if (filterType == widget.filterSections[_filterSelectedIndex.value]) {
            _minController.text = convertInDateFormat(_dateRange.start);
            _maxController.text = convertInDateFormat(_dateRange.end);
          }
        }
      case "Room":
        {
          _selectedRoom.value = {};
        }
      case "":
        {
          for (int i = 0; i < widget.filterSections.length; i++) {
            resetfilterHandler(widget.filterSections[i]);
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

  @override
  void initState() {
    super.initState();
    populateData();
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
          _selectedSortRule.value = state.sortRule ?? SortRules.mostRecent;
          _selectedCategory.value = state.selectedCategories;
          _selectedAmountRange.value = state.amountRange ?? _amountRange;
          _selectedDateRange.value = state.dateRange ?? _dateRange;
          _selectedRoom.value = state.selectedRoom;
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
          final personalExpState =
              context.read<PersonalMonthlyExpenseBloc>().state;
          List<PersonalExpenseTransactionModel> data = [];
          if (personalExpState is PersonalMonthlyExpenseFetchSuccess) {
            data = personalExpState.data;
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
                              SortRules.values[newIndex].label,
                              sortRuleValue,
                              _selectedSortRule,
                            ),
                          ],
                        )
                        : FilterWidget.buildEnumRadioGroup<SortRules>(
                          SortRules.values[newIndex].label,
                          sortRuleValue,
                          _selectedSortRule,
                        );
                  } else {
                    final sortValue = SortBy.values[i];
                    return FilterWidget.buildEnumRadioGroup<SortBy>(
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
          return ValueListenableBuilder(
            valueListenable: _selectedCategory,
            builder: (context, _, _) {
              return ListView.builder(
                itemCount: CategoryParser.expenseCategories.length,
                itemBuilder: (context, i) {
                  return FilterWidget.buildCheckBox<int>(
                    CategoryParser.expenseCategories[i],
                    _selectedCategory,
                    i,
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
                        "${roomData[i].roomName}###${roomData[i].transactionType == "Quicksplit" ? "" : "Room"}",
                      );
                    },
                  );
                },
              )
              : noRecordFoundWidget("No Data Found", context);
        }
      case "Date Created":
        {
          final state = context.read<PersonalMonthlyExpenseBloc>().state;
          _minController.text = convertInDateFormat(
            _selectedDateRange.value.start,
          );
          _maxController.text = convertInDateFormat(
            _selectedDateRange.value.end,
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
                          suffixIcon: Icon(Iconsax.calendar),
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
          } else {
            return noRecordFoundWidget("No Data Found", context);
          }
        }
      case "Amount":
        {
          final state = context.read<PersonalMonthlyExpenseBloc>().state;
          _minController.text =
              _selectedAmountRange.value.start.toInt().toString();
          _maxController.text =
              _selectedAmountRange.value.end.toInt().toString();

          if (state is PersonalMonthlyExpenseFetchSuccess) {
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
                        inputFormatters: [AmountInputFormatter()],
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
                          inputFormatters: [AmountInputFormatter()],
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
                      widget.filterSections[_filterSelectedIndex.value],
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
                        List.generate(widget.filterSections.length, (index) {
                          bool isSelected = index == _filterSelectedIndex.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Stack(
                              children: [
                                CustomButton.customTextButton(
                                  widget.filterSections[index],
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
                                      isSelected ? Colors.white : Colors.black,
                                  onPressed: () {
                                    _filterSelectedIndex.value = index;
                                  },
                                ),
                                MultiValueListenableBuilder(
                                  listenables: [
                                    _selectedSortBy,
                                    _selectedSortRule,
                                    _selectedAmountRange,
                                    _selectedCategory,
                                    _selectedDateRange,
                                    _selectedRoom,
                                  ],
                                  builder: (context) {
                                    bool haveFilter = isFilterApplied(
                                      widget.filterSections[index],
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
                      widget.filterSections[_filterSelectedIndex.value],
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
              borderColor: Colors.deepPurpleAccent,
              backgroundColor: Colors.deepPurpleAccent,
              buttonTextColor: Colors.white,
              onPressed: _applyFilter,
            ),
          ],
        ),
      ],
    );
  }
}
