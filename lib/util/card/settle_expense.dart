import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/input_formatter.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/room/room_settle_upsert/room_settle_upsert_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/room_settle_model.dart';
import 'package:settlenow_v2/model/room_user_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/loading_card.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/gradient_widget.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class SettleExpense extends StatefulWidget {
  final String roomID;
  final RoomSettleModel? transactionData;
  const SettleExpense({super.key, required this.roomID, this.transactionData});

  @override
  State<SettleExpense> createState() => _SettleExpenseState();
}

class _SettleExpenseState extends State<SettleExpense> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  UserModel _loggedInUser = UserModel.empty();
  final double _headerTextSize = 20;
  final double _userCardWidth = 110;
  final double _userImageRadius = 50;
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final ValueNotifier<String> _selectedUser = ValueNotifier("");
  double userCanPay = 0;

  Widget _userCardWidget(RoomUserModel userData) {
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () {
        _selectedUser.value = userData.user.id;
        _amountController.text =
            min(userCanPay, userData.contribution - userData.spent).toString();
      },
      child: Center(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                overlapUserImageWidget(
                  context,
                  [userData.user],
                  1,
                  imageRadius: 50,
                ),
                SizedBox(height: 8),
                Text(
                  userData.user.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    formatCurrency(
                      userData.contribution - userData.spent,
                      context,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            Positioned(
              left: _userImageRadius / 2 + 10,
              top: 0,
              bottom: 0,
              right: 0,
              child:
                  _selectedUser.value == userData.user.id
                      ? Icon(Icons.check_circle, color: Colors.green, size: 24)
                      : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
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
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _blocListenerHandler(BuildContext context, RoomSettleUpsertState state) {
    if (state is RoomSettleUpsertFailure) {
      showNormalSnackBar(context, state.error);
    } else if (state is RoomSettleUpsertSuccess) {
      _resetForm();
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  _resetForm() {
    _amountController.text = "";
    _selectedUser.value = "";
  }

  void _submitTransactionHandler(List<RoomUserModel> userData) {
    if (_formKey.currentState!.validate()) {
      double amountToBeSettled = double.parse(_amountController.text);
      double userCanReceive = 0;
      UserModel receiverData = UserModel.empty();

      if (_selectedUser.value.isEmpty) {
        showNormalSnackBar(context, "Select User!");
        return;
      } else if (amountToBeSettled <= 0) {
        showNormalSnackBar(context, "Invalid Amount!");
        return;
      }

      for (int i = 0; i < userData.length; i++) {
        if (_selectedUser.value == userData[i].user.id) {
          userCanReceive =
              userData[i].contribution - userData[i].spent + userData[i].settle;
          receiverData = userData[i].user;
          break;
        }
      }
      if (!receiverData.hasData) {
        showNormalSnackBar(context, "Invalid User");
      } else if (amountToBeSettled > userCanPay) {
        showNormalSnackBar(
          context,
          "You can pay ${formatCurrency(userCanPay, context)} at max!",
        );
        return;
      } else if (amountToBeSettled > userCanReceive) {
        showNormalSnackBar(
          context,
          "User can receive ${formatCurrency(userCanReceive, context)} at max!",
        );
        return;
      }

      if (widget.transactionData == null) {
        RoomSettleModel newData = RoomSettleModel(
          id: "",
          recevier: receiverData,
          sender: _loggedInUser,
          amount: amountToBeSettled,
          createdOn: DateTime.now(),
          modifiedOn: DateTime.now(),
        );
        context.read<RoomSettleUpsertCubit>().addNewSettleExpense(newData);
      } else {
        RoomSettleModel updatedData = widget.transactionData!;
        updatedData.amount = amountToBeSettled;
        updatedData.recevier = receiverData;
        context.read<RoomSettleUpsertCubit>().updateSettleExpense(updatedData);
      }
    }
  }

  void _populateEditForm(RoomSettleModel data) {
    _amountController.text = data.amount.toString();
    _selectedUser.value = data.recevier.id;
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
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
    }

    final roomUserState = context.read<RoomUserCubit>().state;
    if (roomUserState is RoomUserInitial || roomUserState is RoomUserFailure) {
      context.read<RoomUserCubit>().fetchData(widget.roomID);
    }

    if (widget.transactionData != null) {
      _populateEditForm(widget.transactionData!);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<RoomUserModel> users = [];
    final roomUserState = context.watch<RoomUserCubit>().state;
    if (roomUserState is RoomUserSuccess) {
      for (int i = 0; i < roomUserState.data.length; i++) {
        double bal =
            roomUserState.data[i].contribution -
            roomUserState.data[i].spent +
            roomUserState.data[i].settle;

        if (roomUserState.data[i].user.id == _loggedInUser.id) {
          userCanPay = bal * -1;
        } else if (roomUserState.data[i].user.id != _loggedInUser.id &&
            bal > 0) {
          users.add(roomUserState.data[i]);
        }
      }
    }

    return BlocConsumer<RoomSettleUpsertCubit, RoomSettleUpsertState>(
      listener: _blocListenerHandler,
      builder: (context, state) {
        if (state is RoomSettleUpsertLoading || users.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Settle Expense"),
              centerTitle: false,
              titleSpacing: _mainScreenPadding.left,
              leading: appBarBackButton(context),
            ),
            body: LoadingPage(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Settle Expense"),
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
                  Column(
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
                              (screenWidth / (_userCardWidth + spacing)).ceil();

                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: users.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisSpacing: spacing,
                                  crossAxisSpacing: spacing,
                                  childAspectRatio: 0.85,
                                ),
                            itemBuilder: (context, index) {
                              RoomUserModel userData = users[index];
                              return ValueListenableBuilder(
                                valueListenable: _selectedUser,
                                builder: (
                                  BuildContext context,
                                  String value,
                                  Widget? child,
                                ) {
                                  return _userCardWidget(userData);
                                },
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(height: UiConstant.spaceBetweenSection),
                      Center(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: () {
                            _submitTransactionHandler(users);
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: GradientBorderCard(
                              borderRadius: 100,
                              borderWidth: 1,
                              gradientColors:
                                  GradientColorConstant.vibrantGradient,
                              child: CustomButton.customOutlinedButton(
                                "${widget.transactionData == null ? "Add" : "Update"} Amount",
                                buttonHeight: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
