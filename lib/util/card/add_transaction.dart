import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/util_core.dart';

class AddTransaction extends StatefulWidget {
  final BaseTransactionModel? transactionData;
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
  List<String> expenseCategories = [];
  int oldTransHashcode = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _expressionKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _partialFormKey = GlobalKey<FormState>();
  final TextEditingController _expressionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DateTime _currentDate = DateTime.now();
  DateTime _createdOn = DateTime.now();
  final TextEditingController _creationDateController = TextEditingController(
    text: convertDateTimeFormat(DateTime.now()),
  );
  bool _isNewExpense = true;
  String expenseType = "";

  final List<SplitType> _splitType = SplitType.values;
  final ValueNotifier<int> _categoryIndex = ValueNotifier(0);
  final ValueNotifier<int> _splitTypeIndex = ValueNotifier(0);
  final ValueNotifier<LendenType> _lendenTransactionType = ValueNotifier(
    LendenType.gave,
  );
  final ValueNotifier<UserWithEditControlTD> _selectedUserIDs = ValueNotifier(
    {},
  );
  String currentRoute = "";
  final ValueNotifier<Set<String>> _selectedUserIDSet = ValueNotifier({});
  final ValueNotifier<bool> _futureJoinerBool = ValueNotifier(true);

  final List<String> _gotoSplitType = [
    "Split Equally",
    "Split Equally (Exclude You)",
  ];

  void _handleGoToSplitType(int index) {
    Decimal? amount = Decimal.tryParse(_amountController.text);
    int userCount = _selectedUserIDs.value.length;

    if (amount == null || amount == Decimal.zero) {
      return;
    }

    int amountInPaisa = (amount * Decimal.fromInt(100)).toBigInt().toInt();

    switch (index) {
      case 0:
        {
          int remaining = amountInPaisa % userCount;
          int equalSplit = (amountInPaisa / userCount).toInt();
          UserWithEditControlTD newUserTDMap = {};

          for (MapEntry<BaseUserModel, TextEditingController> eachEntry
              in _selectedUserIDs.value.entries) {
            newUserTDMap.putIfAbsent(
              eachEntry.key,
              () => TextEditingController(
                text: ((equalSplit + (remaining > 0 ? 1 : 0)) / 100)
                    .toStringAsFixed(2),
              ),
            );
            remaining--;
          }

          _selectedUserIDs.value = newUserTDMap;
        }
      case 1:
        {
          if (userCount == 1) {
            showNormalSnackBar(context, "Add another user");
          } else {
            int remaining = amountInPaisa % (userCount - 1);
            int equalSplit = (amountInPaisa / (userCount - 1)).toInt();
            UserWithEditControlTD newUserTDMap = {};

            for (MapEntry<BaseUserModel, TextEditingController> eachEntry
                in _selectedUserIDs.value.entries) {
              newUserTDMap.putIfAbsent(
                eachEntry.key,
                () => TextEditingController(
                  text:
                      _loggedInUser.id == eachEntry.key.id
                          ? "0"
                          : ((equalSplit + (remaining > 0 ? 1 : 0)) / 100)
                              .toStringAsFixed(2),
                ),
              );
              if (_loggedInUser.id != eachEntry.key.id) {
                remaining--;
              }
            }

            _selectedUserIDs.value = newUserTDMap;
          }
        }
      default:
        {}
    }
  }

  void _removeUserFromSplitTransaction(BaseUserModel user, bool skipRemoval) {
    {
      final current = UserWithEditControlTD.from(_selectedUserIDs.value);
      final oldUserIDs = Set<String>.from(_selectedUserIDSet.value);

      if (oldUserIDs.contains(user.id)) {
        if (skipRemoval) {
          return;
        } else if (_loggedInUser.id == user.id) {
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

  Widget _userCardWithAmountWidget(BaseUserModel user) {
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
                    return CustomValidator.validateAmount(value, null);
                  },
                  inputDecoration: TextFormFieldInputBorder.underLine,
                  borderColor:
                      Theme.of(
                        context,
                      ).inputDecorationTheme.enabledBorder!.borderSide.color,
                  suffixIcon: UiConstant.indianRupeeSymbol,
                ),
              ),
              InkWell(
                hoverColor:
                    user.id == _loggedInUser.id ? Colors.transparent : null,
                onTap: () {
                  if (user.id != _loggedInUser.id) {
                    _removeUserFromSplitTransaction(user, false);
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
                ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    colouredIcon(
                      icon,
                      UiConstant.colorsWithShade100[index],
                      radius: 40,
                    ),
                    SizedBox(width: 8),
                    Text(
                      text,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
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
                  onTap: () {
                    if (_splitTypeIndex.value != index) {
                      if (_splitType[index] == SplitType.partial) {
                        _selectedUserIDs.value.clear();
                        _selectedUserIDSet.value.clear();
                        _selectedUserIDs.value.putIfAbsent(
                          _loggedInUser,
                          () => TextEditingController(),
                        );
                        _selectedUserIDSet.value.add(_loggedInUser.id);
                      }
                      _splitTypeIndex.value = index;
                    }
                  },
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
                      child: Text(
                        _splitType[index].label,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
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
    _expressionController.text = "";
    _createdOn = DateTime.now();
    _creationDateController.text = convertDateTimeFormat(_createdOn);
    _selectedUserIDs.value = {};
    _selectedUserIDs.value = {};
    _categoryIndex.value = 0;
    _splitTypeIndex.value = _splitType.indexOf(SplitType.equal);

    if (transactionType == TransactionType.quicksplit) {
      _splitTypeIndex.value = _splitType.indexOf(SplitType.partial);
      _selectedUserIDs.value.putIfAbsent(
        _loggedInUser,
        () => TextEditingController(),
      );
    }
  }

  void _populateEditForm(BaseTransactionModel transactionData) {
    _isNewExpense = false;

    _amountController.text = transactionData.amount.abs().toStringAsFixed(2);
    _descriptionController.text = transactionData.description;
    _createdOn = transactionData.createdOn;
    _creationDateController.text = convertDateTimeFormat(_createdOn);

    List<UserAmountModel> users = [];

    switch (transactionType) {
      case TransactionType.lenden:
        {
          final transTemp = transactionData as LendenTransactionModel;
          if (transactionData.amount < 0) {
            _lendenTransactionType.value = LendenType.owe;
          }
          oldTransHashcode = transTemp.hashCode;
        }
      case TransactionType.room:
        {
          final transTemp = transactionData as RoomTransactionModel;
          users = [...transTemp.users];
          _splitTypeIndex.value = _splitType.indexOf(transTemp.splitType);
          _categoryIndex.value = CategoryParser.expenseCategories.indexOf(
            transTemp.category,
          );
          oldTransHashcode = transTemp.hashCode;
        }
      case TransactionType.personal:
        {
          final transTemp = transactionData as RoomTransactionModel;
          expenseType = "Personal";
          _categoryIndex.value = CategoryParser.expenseCategories.indexOf(
            transTemp.category,
          );
          oldTransHashcode = transTemp.hashCode;
        }
      case TransactionType.quicksplit:
        {
          final transTemp = transactionData as QuicksplitTransactionModel;
          users = [...transTemp.users];
          _categoryIndex.value = CategoryParser.expenseCategories.indexOf(
            transTemp.category,
          );
          oldTransHashcode = transTemp.hashCode;
        }
    }

    _selectedUserIDs.value = {};
    _selectedUserIDSet.value = {};

    UserWithEditControlTD tempMap = {};
    Set<String> tempUserIDs = {};

    for (int i = 0; i < users.length; i++) {
      final userWithAmountData = <BaseUserModel, TextEditingController>{
        users[i]: TextEditingController(
          text: users[i].amount.toStringAsFixed(2),
        ),
      };
      tempMap.addAll(userWithAmountData);
      tempUserIDs.add(users[i].id);
    }

    _selectedUserIDs.value = tempMap;
    _selectedUserIDSet.value = tempUserIDs;
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

      switch (transactionType) {
        case TransactionType.quicksplit:
          {
            _splitTypeIndex.value = _splitType.indexOf(SplitType.partial);
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
    if (_splitType[_splitTypeIndex.value] == SplitType.partial &&
        !_partialFormKey.currentState!.validate()) {
      return;
    }
    if (_formKey.currentState!.validate()) {
      int sumAmount = 0;
      int amountInPaisa =
          (Decimal.parse(_amountController.text) * Decimal.fromInt(100))
              .toBigInt()
              .toInt();
      double totalAmount = double.parse(_amountController.text);
      List<UserAmountModel> userWithAmount = [];
      UserAmountModel createdBy = UserAmountModel.fromBaseObject(
        _loggedInUser,
        amount:
            _splitTypeIndex.value == _splitType.indexOf(SplitType.self)
                ? totalAmount
                : 0,
      );

      SplitType expenseSplitType = _splitType[_splitTypeIndex.value];

      if (_splitType[_splitTypeIndex.value] == SplitType.partial) {
        _selectedUserIDs.value.forEach((userData, amountTxt) {
          double tempAmount = double.parse(amountTxt.text);
          sumAmount +=
              (Decimal.parse(amountTxt.text) * Decimal.fromInt(100))
                  .toBigInt()
                  .toInt();

          userWithAmount.add(
            UserAmountModel.fromBaseObject(userData, amount: tempAmount),
          );
        });
      } else if (transactionType == TransactionType.room &&
          (_splitType[_splitTypeIndex.value] == SplitType.equal ||
              !_futureJoinerBool.value)) {
        if (!_futureJoinerBool.value) {
          expenseSplitType = SplitType.partial;
        }
        final roomInfoState = context.read<RoomInfoCubit>().state;

        if (roomInfoState is RoomInfoSuccess) {
          int activeUserCount = 0;

          for (int i = 0; i < roomInfoState.data.users.length; i++) {
            if (roomInfoState.data.users[i].active) {
              activeUserCount++;
            }
          }

          int remaining = amountInPaisa % activeUserCount;
          int eachAmount = (amountInPaisa / activeUserCount).toInt();

          for (int i = 0; i < roomInfoState.data.users.length; i++) {
            if (roomInfoState.data.users[i].active) {
              userWithAmount.add(
                UserAmountModel.fromBaseObject(
                  roomInfoState.data.users[i],
                  amount: ((eachAmount + (remaining > 0 ? 1 : 0)) / 100),
                ),
              );
              remaining--;
            }
          }
        }
      }

      BaseTransactionModel? data;

      bool flag = false;

      switch (transactionType) {
        case TransactionType.lenden:
          {
            data = LendenTransactionModel(
              id: "",
              amount: totalAmount,
              description: _descriptionController.text.trim(),
              createdOn: _createdOn,
              modifiedOn: _createdOn,
              createdBy: createdBy.id,
            );
            if (_lendenTransactionType.value == LendenType.owe) {
              data.amount = -1 * data.amount;
            }
            break;
          }
        case TransactionType.personal:
          {
            data = PersonalExpenseTransactionModel(
              id: "",
              amount: totalAmount,
              description: _descriptionController.text.trim(),
              createdOn: _createdOn,
              modifiedOn: _createdOn,
              createdBy: createdBy.id,
              category: expenseCategories[max(0, _categoryIndex.value)],
              roomData: RoomLinkedModel.empty(),
            );
            if (_lendenTransactionType.value == LendenType.owe) {
              data.amount = -1 * data.amount;
            }
            break;
          }
        case TransactionType.quicksplit:
          {
            data = QuicksplitTransactionModel(
              id: "",
              amount: totalAmount,
              description: _descriptionController.text.trim(),
              createdOn: _createdOn,
              modifiedOn: _createdOn,
              createdBy: createdBy.id,
              category: expenseCategories[max(0, _categoryIndex.value)],
              users:
                  userWithAmount
                      .map(
                        (element) =>
                            QuicksplitUserModel.fromUserAmountObject(element),
                      )
                      .toList(),
              personalExpenseId: '',
              active: true,
              isClosedAny: false,
            );
            if (_lendenTransactionType.value == LendenType.owe) {
              data.amount = -1 * data.amount;
            }
            break;
          }
        case TransactionType.room:
          {
            data = RoomTransactionModel(
              id: "",
              amount: totalAmount,
              description: _descriptionController.text.trim(),
              createdOn: _createdOn,
              modifiedOn: _createdOn,
              createdBy: createdBy.id,
              category: expenseCategories[max(0, _categoryIndex.value)],
              users: userWithAmount,
              splitType: expenseSplitType,
              personalExpenseId: '',
            );
            if (_lendenTransactionType.value == LendenType.owe) {
              data.amount = -1 * data.amount;
            }
            break;
          }
      }

      switch (_splitType[_splitTypeIndex.value]) {
        case SplitType.partial:
          {
            if (userWithAmount.isEmpty) {
              showNormalSnackBar(context, "Add Atleast One Member");
            } else if (amountInPaisa != sumAmount) {
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
          if (oldTransHashcode != data.hashCode) {
            data.id = widget.transactionData!.id;
            context.read<NewTransactionCubit>().updateExpense(
              context,
              data,
              transactionType,
              expenseType: expenseType,
            );
          } else {
            showNormalSnackBar(context, "No Change Detected");
          }
        }
      }
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Expression",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Form(
                  key: _expressionKey,
                  child: CustomFormField.textFormField(
                    _expressionController,
                    hintText: "(3 + 5) * (2 - 1) / 4 + 7 - 2^3",
                    labelText: "Expression",
                    validator: CustomValidator.validateExpression,
                    inputDecoration:
                        TextFormFieldInputBorder.outlineInputBorder,
                    borderColor: GradientColorConstant.coolIndigoToBlue.last,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: subTextOnCard(
                    "Supported Characters: 0123456789+-*/^().",
                    context,
                    fontSize: kDefaultFontSize,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    UiConstant.cardBorderRadius,
                  ),
                  onTap: () {
                    if (_expressionKey.currentState!.validate()) {
                      ExpressionParser parser = ShuntingYardParser();
                      Expression exp = parser.parse(_expressionController.text);
                      var evaluator = RealEvaluator();
                      _amountController.text = evaluator
                          .evaluate(exp)
                          .toStringAsFixed(2);

                      context.pop();
                    }
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: GradientWidget(
                      text: "Calculate",
                      gradientColors: GradientColorConstant.coolIndigoToBlue,
                      textSize: 14,
                      textColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                    ? [
                      IconButton(
                        onPressed: () => _showBottomSheet(context),
                        icon: Icon(Iconsax.calculator_copy),
                      ),
                    ]
                    : [
                      IconButton(
                        onPressed: () async {
                          final NewTransactionCubit newTransactionCubit =
                              context.read<NewTransactionCubit>();
                          bool isDeletePermitted = await deleteExpenseDialog(
                            context,
                          );
                          if (context.mounted && isDeletePermitted) {
                            newTransactionCubit.deleteExpense(
                              context,
                              widget.transactionData!.id,
                              transactionType,
                              expenseType: expenseType,
                            );
                          }
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
                    hintText: 'Amount',
                    labelText: 'Amount',
                    validator: (value) {
                      return CustomValidator.validateAmount(value, null);
                    },
                    inputDecoration: TextFormFieldInputBorder.underLine,
                    borderColor:
                        Theme.of(
                          context,
                        ).inputDecorationTheme.enabledBorder!.borderSide.color,
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
                    borderColor:
                        Theme.of(
                          context,
                        ).inputDecorationTheme.enabledBorder!.borderSide.color,
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
                        borderColor:
                            Theme.of(context)
                                .inputDecorationTheme
                                .enabledBorder!
                                .borderSide
                                .color,
                        suffixIcon: Icon(Iconsax.calendar_copy),
                        onTap: () async {
                          DateTime? dateTime = await showOmniDateTimePicker(
                            context: context,
                            is24HourMode: false,
                            isShowSeconds: false,
                            firstDate:
                                TransactionType.personal == transactionType
                                    ? DateTime(
                                      _currentDate.year,
                                      _currentDate.month,
                                      1,
                                    )
                                    : null,
                            lastDate: DateTime.now(),
                            initialDate: _createdOn,
                            theme: ThemeData.from(
                              colorScheme: ColorScheme.fromSeed(
                                seedColor: Theme.of(context).primaryColor,
                                brightness: Theme.brightnessOf(context),
                              ),
                            ),
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
                    visible:
                        TransactionType.room == transactionType &&
                        _isNewExpense,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _splitTypeIndex,
                          builder: (context, value, child) {
                            if (_splitType[value] == SplitType.equal) {
                              return child!;
                            } else {
                              return SizedBox(
                                height: UiConstant.spaceBetweenSection,
                              );
                            }
                          },
                          child: ValueListenableBuilder(
                            valueListenable: _futureJoinerBool,
                            builder: (context, _, _) {
                              return SwitchListTile(
                                title: Text(
                                  "Include Future Participants",
                                  style: TextStyle(
                                    fontSize: _headerTextSize - 4,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.only(
                                  top: 0.25 * UiConstant.spaceBetweenSection,
                                ),
                                inactiveThumbColor: Colors.black38,
                                inactiveTrackColor: Colors.white,
                                value: _futureJoinerBool.value,
                                onChanged: (updatedValue) {
                                  _futureJoinerBool.value = updatedValue;
                                },
                              );
                            },
                          ),
                        ),
                        _splitTypeCardWidget(),
                      ],
                    ),
                  ),
                  SizedBox(height: .5 * UiConstant.spaceBetweenSection),
                  ValueListenableBuilder(
                    valueListenable: _splitTypeIndex,
                    builder: (context, value, child) {
                      if (_splitType[value] == SplitType.partial) {
                        return child!;
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Members",
                              style: TextStyle(fontSize: _headerTextSize),
                            ),
                            IconButton(
                              onPressed: () async {
                                final userDataFromScreen =
                                    await context.push(
                                          currentRoute +
                                              RouterConstants.inviteMember,
                                          extra: {
                                            "userID":
                                                _selectedUserIDSet.value
                                                    .toList(),
                                            "transactionType": transactionType,
                                          },
                                        )
                                        as List<BaseUserModel>?;
                                if (userDataFromScreen != null) {
                                  for (
                                    int i = 0;
                                    i < userDataFromScreen.length;
                                    i++
                                  ) {
                                    _removeUserFromSplitTransaction(
                                      userDataFromScreen[i],
                                      true,
                                    );
                                  }
                                }
                              },
                              icon: Icon(Iconsax.profile_add_copy),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: UiConstant.spaceBetweenCard,
                              children: List.generate(
                                _gotoSplitType.length,
                                (index) => InkWell(
                                  onTap: () => _handleGoToSplitType(index),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(_gotoSplitType[index]),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (_partialFormKey.currentState!.validate()) {
                                  Decimal amount = Decimal.zero;
                                  _selectedUserIDs.value.forEach((
                                    userData,
                                    amountTxt,
                                  ) {
                                    amount += Decimal.parse(amountTxt.text);
                                  });
                                  _amountController.text = amount.toString();
                                }
                              },
                              tooltip: "Set total to sum of splits",
                              icon: Icon(Icons.functions_outlined),
                            ),
                          ],
                        ),
                        SizedBox(height: .5 * UiConstant.spaceBetweenSection),
                        Form(
                          key: _partialFormKey,
                          child: ValueListenableBuilder(
                            valueListenable: _selectedUserIDs,
                            builder: (
                              BuildContext context,
                              UserWithEditControlTD userWithEditControlTD,
                              Widget? _,
                            ) {
                              List<BaseUserModel> selectedUsers =
                                  userWithEditControlTD.keys.toList();
                              if (userWithEditControlTD.isEmpty) {
                                return SizedBox.shrink();
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                      valueListenable: _lendenTransactionType,
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
                                LendenType.values.length,
                                (index) {
                                  final value = LendenType.values[index];
                                  if (value == LendenType.none) {
                                    return SizedBox.shrink();
                                  }
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(100),
                                    onTap:
                                        () =>
                                            _lendenTransactionType.value =
                                                value,
                                    child: _cardWidget(
                                      index,
                                      LendenType.values.indexOf(
                                        _lendenTransactionType.value,
                                      ),
                                      value.label,
                                      null,
                                    ),
                                  );
                                },
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
                            "${widget.transactionData == null ? "Add" : "Update"} Expense",
                            buttonHeight: 40,
                            buttonTextColor:
                                Theme.of(context).textTheme.bodyLarge!.color!,
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
