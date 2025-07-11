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
import 'package:settlenow_v2/util/enum/enums.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<String> _selectedUser = ValueNotifier("");
  double userCanPay = 0;

  Widget _userCardWidget(RoomUserModel userData) {
    double unSettledAmount =
        userData.contribution - userData.spent + userData.settle;
    double payableAmount = min(userCanPay.abs(), unSettledAmount.abs());
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () {
        _selectedUser.value = userData.user.id;
        if (_amountController.text.isEmpty) {
          _amountController.text = formatCurrency(
            payableAmount,
            context,
          ).substring(1).replaceAll(",", "");
        }
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
                    formatCurrency(payableAmount, context),
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
                context.read<RoomSettleUpsertCubit>().deleteSettleExpense(
                  widget.roomID,
                  widget.transactionData!.id,
                  widget.transactionData!.sender.id,
                  widget.transactionData!.receiver.id,
                  _loggedInUser.authToken,
                );
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

  void _resetForm() {
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
      } else if (amountToBeSettled > userCanPay.abs()) {
        showNormalSnackBar(
          context,
          "You can pay ${formatCurrency(userCanPay.abs(), context)} at max!",
        );
        return;
      } else if (amountToBeSettled > userCanReceive.abs()) {
        showNormalSnackBar(
          context,
          "User can receive ${formatCurrency(userCanReceive.abs(), context)} at max!",
        );
        return;
      }

      if (widget.transactionData == null) {
        RoomSettleModel newData = RoomSettleModel(
          id: "",
          receiver: receiverData,
          sender: _loggedInUser,
          amount: (userCanPay > 0 ? -1 : 1) * amountToBeSettled.abs(),
          createdOn: DateTime.now(),
          modifiedOn: DateTime.now(),
        );
        context.read<RoomSettleUpsertCubit>().addNewSettleExpense(
          widget.roomID,
          newData,
          _loggedInUser.authToken,
        );
      } else {
        RoomSettleModel updatedData = RoomSettleModel(
          id: widget.transactionData!.id,
          receiver: receiverData,
          sender: _loggedInUser,
          amount: (userCanPay > 0 ? -1 : 1) * amountToBeSettled.abs(),
          createdOn: widget.transactionData!.createdOn,
          modifiedOn: widget.transactionData!.modifiedOn,
        );
        context.read<RoomSettleUpsertCubit>().updateSettleExpense(
          widget.roomID,
          updatedData,
          _loggedInUser.authToken,
        );
      }
    }
  }

  List<RoomUserModel> getSettleMember(List<RoomUserModel> data) {
    List<RoomUserModel> users = [];
    for (int i = 0; i < data.length; i++) {
      double bal = data[i].contribution - data[i].spent + data[i].settle;

      if (data[i].user.id == _loggedInUser.id) {
        userCanPay = bal;
        break;
      }
    }
    bool isNega = false;
    if (userCanPay < 0) {
      isNega = true;
    }
    for (int i = 0; i < data.length; i++) {
      if (widget.transactionData != null) {
        if (widget.transactionData!.receiver.id == data[i].user.id) {
          users.add(data[i]);
          break;
        }
      } else {
        double bal = data[i].contribution - data[i].spent + data[i].settle;
        bool isNega2 = false;
        if (bal < 0) {
          isNega2 = true;
        }
        if (bal.abs() < 0.2) {
          continue;
        } else if (data[i].user.id != _loggedInUser.id && isNega2 != isNega) {
          users.add(data[i]);
        }
      }
    }

    return users;
  }

  Widget _loadingScreen({Widget child = const LoadingPage()}) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settle Expense"),
        centerTitle: false,
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
      ),
      body: child,
    );
  }

  void _populateEditForm(RoomSettleModel data) {
    _amountController.text = data.amount.toString();
    _selectedUser.value = data.receiver.id;
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

      if (widget.transactionData != null) {
        _populateEditForm(widget.transactionData!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomUserCubit, RoomUserState>(
      listener: (context, state) {
        if (state is RoomUserFailure) {
          showNormalSnackBar(context, state.error);
        }
      },
      builder: (context, state) {
        List<RoomUserModel> users = [];
        if (state is RoomUserSuccess) {
          users = getSettleMember(state.data);
        } else {
          return _loadingScreen();
        }
        if (users.isEmpty) {
          return _loadingScreen(child: noRecordFoundWidget("No User Found"));
        }
        return BlocConsumer<RoomSettleUpsertCubit, RoomSettleUpsertState>(
          listener: _blocListenerHandler,
          builder: (context, state) {
            if (state is RoomSettleUpsertLoading) {
              return _loadingScreen();
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
                      ValueListenableBuilder(
                        valueListenable: _selectedUser,
                        builder: (context, _, _) {
                          if (_selectedUser.value.isNotEmpty &&
                              userCanPay > 0) {
                            RoomUserModel userToBePaid = users.firstWhere(
                              (ele) => ele.user.id == _selectedUser.value,
                              orElse: () => RoomUserModel.empty(),
                            );
                            if (userToBePaid.hasData) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    "Settling on ${userToBePaid.user.name}'s behalf",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          } else {
                            return SizedBox.shrink();
                          }
                        },
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
                                  (screenWidth / (_userCardWidth + spacing))
                                      .ceil();

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
      },
    );
  }
}
