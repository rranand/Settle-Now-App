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

enum TransactionType { quicksplit, lenden, room }

extension TransactionTypeExtension on TransactionType {
  static TransactionType fromPath(BuildContext context) {
    String path =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();

    if (path.startsWith(RouterConstants.quickSplitAddExpenseRouteName)) {
      return TransactionType.quicksplit;
    }
    switch (path.toLowerCase()) {
      case 'quicksplit':
        return TransactionType.quicksplit;
      case 'lenden':
        return TransactionType.lenden;
      default:
        return TransactionType.room;
    }
  }
}

class AddTransaction extends StatefulWidget {
  final NewTransactionModel? transactionData;
  const AddTransaction({super.key, this.transactionData});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  UserModel _loggedInUser = UserModel.empty();
  TransactionType transactionType = TransactionType.room;
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
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
  final ValueNotifier<int> _categoryIndex = ValueNotifier(0);
  final ValueNotifier<int> _splitTypeIndex = ValueNotifier(0);
  final ValueNotifier<UserWithEditControlTD> _selectedUserIDs = ValueNotifier(
    {},
  );

  void resetForm() {
    _amountController.text = "";
    _descriptionController.text = "";
    _createdOn = DateTime.now();
    _creationDateController.text = convertDateTimeFormat(_createdOn);
    _selectedUserIDs.value.clear();
    _categoryIndex.value = 0;

    if (transactionType == TransactionType.quicksplit) {
      _selectedUserIDs.value.putIfAbsent(
        _loggedInUser,
        () => TextEditingController(),
      );
    }
  }

  Widget _userCardWidget(
    UserModel user,
    UserWithEditControlTD selectedUserIDs,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () {
        final current = UserWithEditControlTD.from(_selectedUserIDs.value);
        if (current.containsKey(user)) {
          current.remove(user);
        } else {
          current.putIfAbsent(user, () => TextEditingController());
        }
        _selectedUserIDs.value = current;
      },
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
                  selectedUserIDs.containsKey(user)
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
        ],
      ),
    );
  }

  Widget _categoryWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Category", style: TextStyle(fontSize: 20)),
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
                  child: GradientBorderCard(
                    borderRadius: 100,
                    borderWidth: 1,
                    gradientColors:
                        index == value
                            ? GradientColorConstant.vibrantGradient
                            : [Colors.grey.shade300, Colors.grey.shade300],
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          colouredIcon(
                            Icon(CategoryParser.expenseCategoryIcons[index]),
                            UiConstant.colorsWithShade100[index],
                            radius: 40,
                          ),
                          SizedBox(width: 8),
                          Text(expenseCategories[index]),
                        ],
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

  Widget _splitTypeCardWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: UiConstant.spaceBetweenSection),
        Text("Split Type", style: TextStyle(fontSize: 20)),
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

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
    }

    transactionType = TransactionTypeExtension.fromPath(context);
    if (transactionType == TransactionType.quicksplit) {
      _splitTypeIndex.value = 1;
      _selectedUserIDs.value.putIfAbsent(
        _loggedInUser,
        () => TextEditingController(),
      );
    }
  }

  void _blocListenerHandler(BuildContext context, NewTransactionState state) {
    if (state is NewTransactionFailure) {
      showNormalSnackBar(context, state.error);
    } else if (state is NewTransactionSuccess) {
      resetForm();
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  void _newTransactionHandler() {
    if (_formKey.currentState!.validate()) {
      double sumAmount = 0;
      double totalAmount = double.parse(_amountController.text);
      List<UserAmountModel> userWithAmount = [];
      UserAmountModel createdBy = UserAmountModel.empty();
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
        category: expenseCategories[_categoryIndex.value],
      );
      bool flag = false;

      switch (transactionType) {
        case TransactionType.quicksplit:
          {
            if (userWithAmount.isEmpty) {
              showNormalSnackBar(context, "Add Atleast One Member");
            } else if (totalAmount != sumAmount) {
              showNormalSnackBar(context, "Total Amount does not match");
            } else {
              flag = true;
            }
          }
        default:
          debugPrint("Unidenified Transaction");
      }

      if (flag) {
        context.read<NewTransactionCubit>().createNewExpense(context, data);
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
              title: Text("Add New Expense"),
              centerTitle: false,
              titleSpacing: _mainScreenPadding.left,
              leading: appBarBackButton(context),
            ),
            body: LoadingPage(),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text("Add New Expense"),
            centerTitle: false,
            titleSpacing: _mainScreenPadding.left,
            leading: appBarBackButton(context),
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
                  SizedBox(height: UiConstant.spaceBetweenSection),
                  CustomFormField.textFormField(
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
                        borderRadius: BorderRadius.circular(16.0),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      );
                      if (dateTime != null && mounted) {
                        _creationDateController.text = convertDateTimeFormat(
                          dateTime,
                        );
                        _createdOn = dateTime;
                      }
                    },
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
                        Text("Members", style: TextStyle(fontSize: 20)),
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
                                    return _userCardWidget(user, value);
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
                                    style: TextStyle(fontSize: 20),
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
                  _categoryWidget(),
                  SizedBox(height: UiConstant.spaceBetweenSection),
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: _newTransactionHandler,
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
