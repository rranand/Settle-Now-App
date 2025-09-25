import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow/bloc/auth/auth_bloc.dart';
import 'package:settlenow/constant/ui_constant.dart';
import 'package:settlenow/cubit/new_transaction/new_transaction_cubit.dart';
import 'package:settlenow/cubit/room/room_info/room_info_cubit.dart';
import 'package:settlenow/model/bulk_transaction_model.dart';
import 'package:settlenow/model/new_transaction_model.dart';
import 'package:settlenow/model/room_user_model.dart';
import 'package:settlenow/model/user_model.dart';
import 'package:settlenow/provider/screen_size_provider.dart';
import 'package:settlenow/util/card/bulk_transaction_card.dart';
import 'package:settlenow/util/card/loading_card.dart';
import 'package:settlenow/util/custom/category_parser.dart';
import 'package:settlenow/util/enum/enums.dart';
import 'package:settlenow/util/enum/format_selection.dart';
import 'package:settlenow/util/enum/transaction_type.dart';
import 'package:settlenow/util/filter/filter_widget.dart';
import 'package:settlenow/util/widgets/custom_button.dart';
import 'package:settlenow/util/widgets/custom_form_field.dart';
import 'package:settlenow/util/widgets/snackbar.dart';
import 'package:settlenow/util/widgets/widgets.dart';

class BulkTransaction extends StatefulWidget {
  const BulkTransaction({super.key});

  @override
  State<BulkTransaction> createState() => _BulkTransactionState();
}

class _BulkTransactionState extends State<BulkTransaction> {
  UserModel _loggedInUser = UserModel.empty();
  final int _maxTransactionCount = 100;
  TransactionType transactionType = TransactionType.room;
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  String currentRoute = "";
  final List<String> seperator = ["-", ":", ",", "|"];
  final List<String> seperatorWithDesc = [
    "Hyphen (-)",
    "Colon (:)",
    "Comma (,)",
    "Pipe (|)",
  ];

  final ValueNotifier<FormatSelection> _selectedFormatSelection = ValueNotifier(
    FormatSelection.amountDescription,
  );
  final ValueNotifier<int> _selectedSeperator = ValueNotifier(0);
  final ValueNotifier<int> _selectedCategory = ValueNotifier(0);
  final ValueNotifier<String> _errorText = ValueNotifier("");
  final ValueNotifier<List<BulkTransactionModel>> _transactionArr =
      ValueNotifier([]);

  final TextEditingController _inputTextController = TextEditingController();

  void _blocListenerHandler(BuildContext context, NewTransactionState state) {
    if (state is NewTransactionFailure) {
      showNormalSnackBar(context, state.error);
    } else if (state is NewTransactionSuccess) {
      if (context.canPop()) {
        context.pop();
      }
    }
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
    currentRoute =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
      transactionType = TransactionTypeExtension.fromPath(context);
    }
  }

  void _resetForm() {
    _inputTextController.text = "";
    _selectedFormatSelection.value = FormatSelection.amountDescription;
    _selectedSeperator.value = 0;
    _selectedCategory.value = 0;
    _transactionArr.value = [];
  }

  void _addExpenseHandler() {
    final roomInfoState = context.read<RoomInfoCubit>().state;

    if (roomInfoState is RoomInfoSuccess) {
      List<RoomUserModel> activeUsers = [];
      for (int i = 0; i < roomInfoState.data.users.length; i++) {
        if (roomInfoState.data.users[i].active) {
          activeUsers.add(roomInfoState.data.users[i]);
        }
      }

      List<NewTransactionModel> transData = [];

      for (int i = 0; i < _transactionArr.value.length; i++) {
        transData.add(
          NewTransactionModel.fromBulkTransaction(
            _transactionArr.value[i],
            i.toString(),
            _loggedInUser.id,
            activeUsers,
          ),
        );
      }

      context.read<NewTransactionCubit>().createBulkExpense(
        context,
        transData,
      );
    } else {
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  List<BulkTransactionModel> parseExpenseFromText() {
    String normalized = _inputTextController.text.replaceAll(r'\n', '\n');
    List<String> lines =
        normalized.split('\n').where((line) => line.trim().isNotEmpty).toList();

    if (lines.length > _maxTransactionCount) {
      throw Exception(
        "You can’t create more than $_maxTransactionCount transactions at a time.",
      );
    }

    final List<BulkTransactionModel> result = [];
    final String sep = seperator[_selectedSeperator.value];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      List<String> parts = line.split(sep);

      if (parts.length < 2) {
        throw Exception("Line ${i + 1}: Missing separator '$sep' → \"$line\"");
      }

      double? amount;
      String description = "";

      if (_selectedFormatSelection.value == FormatSelection.amountDescription) {
        amount = double.tryParse(parts[0].trim());
        description = parts.sublist(1).join(sep).trim();
      } else {
        amount = double.tryParse(parts.last.trim());
        description = parts.sublist(0, parts.length - 1).join(sep).trim();
      }

      if (amount == null || description.isEmpty) {
        throw Exception(
          "Line ${i + 1}: Invalid format → \"$line\" (expected amount and description)",
        );
      }

      result.add(
        BulkTransactionModel(
          amount: amount,
          description: description,
          category: CategoryParser.expenseCategories[_selectedCategory.value],
        ),
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewTransactionCubit, NewTransactionState>(
      listener: _blocListenerHandler,
      builder: (context, state) {
        if (state is NewTransactionLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Add Bulk Transaction"),
              centerTitle: false,
              titleSpacing: _mainScreenPadding.left,
              leading: appBarBackButton(context),
            ),
            body: LoadingPage(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Add Bulk Transaction"),
            centerTitle: false,
            titleSpacing: _mainScreenPadding.left,
            leading: appBarBackButton(context),
            actions: [
              IconButton(
                onPressed: () => _resetForm(),
                icon: Icon(Iconsax.refresh_copy),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: _mainScreenPadding.add(
              EdgeInsets.only(
                top: UiConstant.spaceBetweenSection,
                bottom: UiConstant.spaceAtBottom,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: subTextOnCard(
                      "Note: Bulk transactions only support equal splits.",
                      context,
                      textColor: Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize: kDefaultFontSize,
                    ),
                  ),
                ),
                CustomFormField.textFormField(
                  _inputTextController,
                  hintText: "Paste your transactions",
                  minLines: 4,
                  maxLines: 10,
                  textInputType: TextInputType.multiline,
                  inputDecoration: TextFormFieldInputBorder.outlineInputBorder,
                  borderColor:
                      Theme.of(
                        context,
                      ).inputDecorationTheme.outlineBorder!.color,
                ),
                ValueListenableBuilder(
                  valueListenable: _errorText,
                  builder: (context, _, _) {
                    if (_errorText.value.isEmpty) {
                      return SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(left: 2.0, top: 5),
                      child: Text(
                        _errorText.value,
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: UiConstant.spaceBetweenSection,
                  ),
                  child: Text(
                    "Format Selection",
                    style: TextStyle(
                      fontSize: UiConstant.cardTitleTextSize,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _selectedFormatSelection,
                  builder: (context, _, _) {
                    return Column(
                      children: [
                        FilterWidget.buildEnumRadioGroup(
                          FormatSelection.amountDescription.label,
                          FormatSelection.amountDescription,
                          context,
                          _selectedFormatSelection,
                        ),
                        FilterWidget.buildEnumRadioGroup(
                          FormatSelection.descriptionAmount.label,
                          FormatSelection.descriptionAmount,
                          context,
                          _selectedFormatSelection,
                        ),
                      ],
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Seperator Selection",
                      style: TextStyle(
                        fontSize: UiConstant.cardTitleTextSize,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedSeperator,
                      builder: (context, _, _) {
                        return DropdownButton<String>(
                          underline: SizedBox.shrink(),
                          value: seperator[_selectedSeperator.value],
                          items: List.generate(
                            seperatorWithDesc.length,
                            (index) => DropdownMenuItem(
                              value: seperator[index],
                              child: Text(seperatorWithDesc[index]),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              _selectedSeperator.value = seperator.indexOf(
                                value,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Category Selection",
                      style: TextStyle(
                        fontSize: UiConstant.cardTitleTextSize,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedCategory,
                      builder: (context, _, _) {
                        return DropdownButton<String>(
                          underline: SizedBox.shrink(),
                          value:
                              CategoryParser.expenseCategories[_selectedCategory
                                  .value],
                          items: List.generate(
                            CategoryParser.expenseCategories.length,
                            (index) => DropdownMenuItem(
                              value: CategoryParser.expenseCategories[index],
                              child: Text(
                                CategoryParser.expenseCategories[index],
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              _selectedCategory.value = CategoryParser
                                  .expenseCategories
                                  .indexOf(value);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
                ValueListenableBuilder(
                  valueListenable: _transactionArr,
                  builder: (context, _, _) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              _transactionArr.value.isEmpty
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: CustomButton.customElevatedButton(
                                "Preview",
                                buttonWidth: 155,
                                buttonHeight: 40,
                                onPressed: () {
                                  try {
                                    _transactionArr.value =
                                        parseExpenseFromText();
                                    _errorText.value = "";
                                  } catch (e) {
                                    _errorText.value = e.toString();
                                    _transactionArr.value = [];
                                  }
                                },
                              ),
                            ),
                            Visibility(
                              visible: _transactionArr.value.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: CustomButton.customElevatedButton(
                                  "Add Expense",
                                  buttonWidth: 155,
                                  buttonHeight: 40,
                                  onPressed: _addExpenseHandler,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: _transactionArr.value.isNotEmpty,
                          child: ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.only(
                              bottom: UiConstant.spaceAtBottom,
                            ),
                            itemBuilder:
                                (context, index) => BulkTransactionCard(
                                  data: _transactionArr,
                                  index: index,
                                ),
                            separatorBuilder: (
                              BuildContext context,
                              int index,
                            ) {
                              return SizedBox(
                                height: .5 * UiConstant.spaceBetweenSection,
                              );
                            },
                            itemCount: _transactionArr.value.length,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
