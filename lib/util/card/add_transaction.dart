import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/input_formatter.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/cubit/new_transaction/new_transaction_cubit.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/card/loading_card.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/gradient_widget.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

enum TransactionType { quicksplit, lenden, room, personal }

extension TransactionTypeExtension on TransactionType {
  static TransactionType fromPath(BuildContext context) {
    String path =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();

    if (path.startsWith(RouterConstants.quickSplitAddExpenseRouteName) ||
        path.startsWith(RouterConstants.quickSplitEditExpenseRouteName)) {
      return TransactionType.quicksplit;
    } else if (path.startsWith(RouterConstants.personalExpenseRouteName)) {
      return TransactionType.personal;
    } else if (path.startsWith(RouterConstants.lendenRouteName)) {
      return TransactionType.lenden;
    }

    switch (path.toLowerCase()) {
      case 'quicksplit':
        return TransactionType.quicksplit;
      case 'lenden':
        return TransactionType.lenden;
      case 'personal':
        return TransactionType.personal;
      default:
        return TransactionType.room;
    }
  }
}

class AddTransaction extends StatefulWidget {
  final TransactionModel? transactionData;
  const AddTransaction({super.key, this.transactionData});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  String _appBarTitle = "";
  UserModel _loggedInUser = UserModel.empty();
  TransactionType transactionType = TransactionType.room;
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final double _headerTextSize = 20;
  final double _userCardWidth = 110;
  final double _userImageRadius = 50;
  List<String> expenseCategories = [];

  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _createdOn = DateTime.now();
  final TextEditingController _creationDateController = TextEditingController(
    text: convertDateTimeFormat(DateTime.now()),
  );

  final List<String> _splitType = ["Equal", "Partial", "Self"];
  final List<String> _lendenTransactionType = ["Gave", "Owe"];
  final ValueNotifier<int> _categoryIndex = ValueNotifier(0);
  final ValueNotifier<int> _splitTypeIndex = ValueNotifier(0);
  final ValueNotifier<int> _lendenTransactionTypeIndex = ValueNotifier(0);
  final ValueNotifier<UserWithEditControlTD> _selectedUserIDs = ValueNotifier(
    {},
  );
  final ValueNotifier<Set<String>> _selectedUserIDSet = ValueNotifier({});

  void _removeUserFromSplitTransaction(UserModel user) {
    {
      final current = UserWithEditControlTD.from(_selectedUserIDs.value);
      final oldUserIDs = Set<String>.from(_selectedUserIDSet.value);

      if (oldUserIDs.contains(user.id)) {
        if (_loggedInUser.id == user.id) {
          showNormalSnackBar(context, "You can't remove yourself");
        } else {
          oldUserIDs.remove(user.id);
          current.removeWhere((k, v) => k.id == user.id);
        }
      } else {
        oldUserIDs.add(user.id);
        current.putIfAbsent(user, () => TextEditingController());
      }

      _selectedUserIDs.value = current;
      _selectedUserIDSet.value = oldUserIDs;
    }
  }

  Widget _userCardWidget(UserModel user) {
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () => _removeUserFromSplitTransaction(user),
      child: Center(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                overlapUserImageWidget(context, [user], 1, imageRadius: 50),
                SizedBox(height: 8),
                Text(
                  user.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            Positioned(
              left: _userImageRadius / 2 + 10,
              top: 0,
              bottom: 0,
              right: 0,
              child:
                  _selectedUserIDSet.value.contains(user.id)
                      ? Icon(Icons.check_circle, color: Colors.green, size: 24)
                      : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userCardWithAmountWidget(UserModel user) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8.0,
      ).add(EdgeInsets.symmetric(horizontal: 8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              overlapUserImageWidget(context, [user], 1),
              SizedBox(width: 8),
              Text(user.name, style: TextStyle()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 130,
                child: CustomFormField.textFormField(
                  _selectedUserIDs.value[user]!,
                  textInputType: TextInputType.numberWithOptions(decimal: true),
                  labelText: "",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Invalid Amount";
                    }
                    return null;
                  },
                  inputFormatters: [AmountInputFormatter()],
                  inputDecoration: TextFormFieldInputBorder.underLine,
                  borderColor: Colors.black54,
                  suffixIcon: UiConstant.indianRupeeSymbol,
                ),
              ),
              InkWell(
                hoverColor:
                    user.id == _loggedInUser.id ? Colors.transparent : null,
                onTap: () {
                  if (user.id != _loggedInUser.id) {
                    _removeUserFromSplitTransaction(user);
                  }
                },
                child: Icon(
                  Icons.close,
                  color:
                      user.id == _loggedInUser.id ? Colors.transparent : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardWidget(int index, int currentInd, String text, IconData? icon) {
    return GradientBorderCard(
      borderRadius: 100,
      borderWidth: 1,
      gradientColors:
          index == currentInd
              ? GradientColorConstant.vibrantGradient
              : [Colors.grey.shade300, Colors.grey.shade300],
      child: Padding(
        padding: EdgeInsets.all(8),
        child:
            icon == null
                ? Padding(padding: const EdgeInsets.all(8.0), child: Text(text))
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    colouredIcon(
                      Icon(icon),
                      UiConstant.colorsWithShade100[index],
                      radius: 40,
                    ),
                    SizedBox(width: 8),
                    Text(text),
                  ],
                ),
      ),
    );
  }

  Widget _categoryWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Category", style: TextStyle(fontSize: _headerTextSize)),
        SizedBox(height: .5 * UiConstant.spaceBetweenSection),
        ValueListenableBuilder(
          valueListenable: _categoryIndex,
          builder: (context, value, _) {
            return Wrap(
              spacing: UiConstant.spaceBetweenCard,
              runSpacing: UiConstant.spaceBetweenCard,
              children: List.generate(
                CategoryParser.expenseCategoryIcons.length,
                (index) => InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => _categoryIndex.value = index,
                  child: _cardWidget(
                    index,
                    value,
                    expenseCategories[index],
                    CategoryParser.expenseCategoryIcons[index],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _splitTypeCardWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: UiConstant.spaceBetweenSection),
        Text("Split Type", style: TextStyle(fontSize: _headerTextSize)),
        SizedBox(height: .5 * UiConstant.spaceBetweenSection),
        ValueListenableBuilder(
          valueListenable: _splitTypeIndex,
          builder: (context, value, _) {
            return Wrap(
              spacing: UiConstant.spaceBetweenCard,
              runSpacing: UiConstant.spaceBetweenCard,
              children: List.generate(
                _splitType.length,
                (index) => InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => _splitTypeIndex.value = index,
                  child: GradientBorderCard(
                    borderRadius: 100,
                    borderWidth: 1,
                    gradientColors:
                        index == value
                            ? GradientColorConstant.vibrantGradient
                            : [Colors.grey.shade300, Colors.grey.shade300],
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(_splitType[index]),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    expenseCategories = CategoryParser.getCategoryList();
    if (mounted) {
      setState(() {});
    }
  }

  void _resetForm() {
    _amountController.text = "";
    _descriptionController.text = "";
    _createdOn = DateTime.now();
    _creationDateController.text = convertDateTimeFormat(_createdOn);
    _selectedUserIDs.value = {};
    _selectedUserIDs.value = {};
    _categoryIndex.value = 0;

    if (_splitTypeIndex.value == 1) {
      _selectedUserIDs.value.putIfAbsent(
        _loggedInUser,
        () => TextEditingController(),
      );
    }
  }

  void _populateEditForm(TransactionModel transactionData) {
    if (transactionType == TransactionType.lenden &&
        transactionData.amount < 0) {
      _lendenTransactionTypeIndex.value = 1;
    }
    _amountController.text = transactionData.amount.abs().toString();
    _descriptionController.text = transactionData.description;
    _createdOn = transactionData.createdOn;
    _creationDateController.text = convertDateTimeFormat(_createdOn);
    _categoryIndex.value = CategoryParser.expenseCategories.indexOf(
      transactionData.category,
    );

    _selectedUserIDs.value = {};
    _selectedUserIDSet.value = {};

    UserWithEditControlTD tempMap = {};
    Set<String> tempUserIDs = {};

    tempMap[transactionData.createdBy as UserModel] = TextEditingController(
      text: transactionData.createdBy.amount.toString(),
    );
    tempUserIDs.add(transactionData.createdBy.id);

    for (UserAmountModel ele in transactionData.users) {
      tempMap[ele as UserModel] = TextEditingController(
        text: ele.amount.toString(),
      );
      tempUserIDs.add(ele.id);
    }

    _selectedUserIDs.value = tempMap;
    _selectedUserIDSet.value = tempUserIDs;
  }

  void _deleteExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Expense"),
          content: Text("Are You Sure?", style: TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                context.read<NewTransactionCubit>().deleteExpense(
                  context,
                  widget.transactionData!.id,
                  transactionType,
                );
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
    }

    transactionType = TransactionTypeExtension.fromPath(context);

    switch (transactionType) {
      case TransactionType.quicksplit:
        {
          _splitTypeIndex.value = 1;
          if (widget.transactionData == null) {
            _selectedUserIDs.value.putIfAbsent(
              _loggedInUser,
              () => TextEditingController(),
            );
            _selectedUserIDSet.value.add(_loggedInUser.id);
          }
        }
      default:
        {}
    }
    if (widget.transactionData != null) {
      _appBarTitle = "Update Expense";
      _populateEditForm(widget.transactionData!);
    } else {
      _appBarTitle = "Add New Expense";
    }
  }

  void _blocListenerHandler(BuildContext context, NewTransactionState state) {
    if (state is NewTransactionFailure) {
      showNormalSnackBar(context, state.error);
    } else if (state is NewTransactionSuccess) {
      _resetForm();
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  void _submitTransactionHandler() {
    if (_formKey.currentState!.validate()) {
      double sumAmount = 0;
      double totalAmount = double.parse(_amountController.text);
      List<UserAmountModel> userWithAmount = [];
      UserAmountModel createdBy = UserAmountModel.copyFromUser(
        _loggedInUser,
        0,
      );
      _selectedUserIDs.value.forEach((userData, amountTxt) {
        double tempAmount = double.parse(amountTxt.text);
        sumAmount += tempAmount;

        if (userData.id == _loggedInUser.id) {
          createdBy = UserAmountModel.copyFromUser(_loggedInUser, tempAmount);
        } else {
          userWithAmount.add(
            UserAmountModel.copyFromUser(userData, tempAmount),
          );
        }
      });
      NewTransactionModel data = NewTransactionModel(
        amount: totalAmount,
        description: _descriptionController.text,
        createdOn: _createdOn,
        members: userWithAmount,
        createdBy: createdBy,
        category: expenseCategories[max(0, _categoryIndex.value)],
      );
      bool flag = false;

      switch (transactionType) {
        case TransactionType.lenden:
          {
            if (_lendenTransactionTypeIndex.value == 1) {
              data.amount = -1 * data.amount;
            }
          }
        default:
          {}
      }

      switch (_splitTypeIndex.value) {
        case 1:
          {
            if (userWithAmount.isEmpty) {
              showNormalSnackBar(context, "Add Atleast One Member");
            } else if (totalAmount != sumAmount) {
              showNormalSnackBar(context, "Total Amount does not match");
            } else if (!createdBy.hasData) {
              showNormalSnackBar(context, "You can't remove yourself");
            } else {
              flag = true;
            }
          }
        default:
          {
            flag = true;
          }
      }

      if (flag) {
        if (widget.transactionData == null) {
          context.read<NewTransactionCubit>().createNewExpense(
            context,
            data,
            transactionType,
          );
        } else {
          data.id = widget.transactionData!.id;
          context.read<NewTransactionCubit>().updateExpense(
            context,
            data,
            transactionType,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewTransactionCubit, NewTransactionState>(
      listener: _blocListenerHandler,
      builder: (context, state) {
        if (state is NewTransactionLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_appBarTitle),
              centerTitle: false,
              titleSpacing: _mainScreenPadding.left,
              leading: appBarBackButton(context),
            ),
            body: LoadingPage(),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(_appBarTitle),
            centerTitle: false,
            titleSpacing: _mainScreenPadding.left,
            leading: appBarBackButton(context),
            actions:
                widget.transactionData == null
                    ? null
                    : [
                      IconButton(
                        onPressed: () {
                          _deleteExpenseDialog();
                        },
                        icon: Icon(Icons.delete_outline),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFormField.textFormField(
                    _amountController,
                    textInputType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [AmountInputFormatter()],
                    hintText: 'Amount',
                    labelText: 'Amount',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter a amount.";
                      }
                      return null;
                    },
                    inputDecoration: TextFormFieldInputBorder.underLine,
                    borderColor: Colors.black87,
                    suffixIcon: UiConstant.indianRupeeSymbol,
                  ),
                  SizedBox(height: UiConstant.spaceBetweenSection),
                  CustomFormField.textFormField(
                    _descriptionController,
                    hintText: 'Description',
                    labelText: 'Description',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter a description.";
                      } else if (value.trim().length < 3) {
                        return "Description must be at least 3 characters long.";
                      }
                      return null;
                    },
                    inputDecoration: TextFormFieldInputBorder.underLine,
                    borderColor: Colors.black87,
                    maxLines: 2,
                  ),
                  Visibility(
                    visible: _appBarTitle.contains("Add"),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: UiConstant.spaceBetweenSection,
                      ),
                      child: CustomFormField.textFormField(
                        _creationDateController,
                        readOnly: true,
                        labelText: 'Creation Date',
                        hintText: 'Creation Date',
                        inputDecoration: TextFormFieldInputBorder.underLine,
                        borderColor: Colors.black87,
                        suffixIcon: Icon(Iconsax.calendar),
                        onTap: () async {
                          DateTime? dateTime = await showOmniDateTimePicker(
                            context: context,
                            is24HourMode: false,
                            isShowSeconds: false,
                            lastDate: DateTime.now(),
                            initialDate: _createdOn,
                            borderRadius: BorderRadius.circular(16.0),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          );
                          if (dateTime != null && mounted) {
                            _creationDateController
                                .text = convertDateTimeFormat(dateTime);
                            _createdOn = dateTime;
                          }
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: TransactionType.room == transactionType,
                    child: _splitTypeCardWidget(),
                  ),
                  SizedBox(height: UiConstant.spaceBetweenSection),
                  ValueListenableBuilder(
                    valueListenable: _splitTypeIndex,
                    builder: (context, value, child) {
                      if (_splitType[value].contains("Partial")) {
                        return child!;
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Members",
                          style: TextStyle(fontSize: _headerTextSize),
                        ),
                        SizedBox(height: .5 * UiConstant.spaceBetweenSection),
                        LayoutBuilder(
                          builder: (context, constraint) {
                            final double screenWidth = constraint.maxWidth;
                            final double spacing = 8.0;
                            final int columns =
                                (screenWidth / (_userCardWidth + spacing))
                                    .ceil();
                            return GridView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: UiConstant.users.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    mainAxisSpacing: spacing,
                                    crossAxisSpacing: spacing,
                                  ),
                              itemBuilder: (context, index) {
                                UserModel user = UiConstant.users[index];
                                return ValueListenableBuilder(
                                  valueListenable: _selectedUserIDs,
                                  builder: (
                                    BuildContext context,
                                    UserWithEditControlTD value,
                                    Widget? child,
                                  ) {
                                    return _userCardWidget(user);
                                  },
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: UiConstant.spaceBetweenSection),
                        ValueListenableBuilder(
                          valueListenable: _selectedUserIDs,
                          builder: (
                            BuildContext context,
                            UserWithEditControlTD userWithEditControlTD,
                            Widget? _,
                          ) {
                            List<UserModel> selectedUsers =
                                userWithEditControlTD.keys.toList();
                            if (userWithEditControlTD.isEmpty) {
                              return SizedBox.shrink();
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Members With Amount",
                                    style: TextStyle(fontSize: _headerTextSize),
                                  ),
                                  SizedBox(
                                    height: .5 * UiConstant.spaceBetweenSection,
                                  ),
                                  ...List.generate(selectedUsers.length, (i) {
                                    return _userCardWithAmountWidget(
                                      selectedUsers[i],
                                    );
                                  }),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: transactionType != TransactionType.lenden,
                    child: _categoryWidget(),
                  ),
                  Visibility(
                    visible: transactionType == TransactionType.lenden,
                    child: ValueListenableBuilder(
                      valueListenable: _lendenTransactionTypeIndex,
                      builder: (context, value, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Type",
                              style: TextStyle(fontSize: _headerTextSize),
                            ),
                            SizedBox(
                              height: .5 * UiConstant.spaceBetweenSection,
                            ),
                            Wrap(
                              spacing: UiConstant.spaceBetweenCard,
                              runSpacing: UiConstant.spaceBetweenCard,
                              children: List.generate(
                                _lendenTransactionType.length,
                                (index) => InkWell(
                                  borderRadius: BorderRadius.circular(100),
                                  onTap:
                                      () =>
                                          _lendenTransactionTypeIndex.value =
                                              index,
                                  child: _cardWidget(
                                    index,
                                    value,
                                    _lendenTransactionType[index],
                                    null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: UiConstant.spaceBetweenSection),
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: _submitTransactionHandler,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: GradientBorderCard(
                          borderRadius: 100,
                          borderWidth: 1,
                          gradientColors: GradientColorConstant.vibrantGradient,
                          child: CustomButton.customOutlinedButton(
                            "Add Expense",
                            buttonHeight: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
