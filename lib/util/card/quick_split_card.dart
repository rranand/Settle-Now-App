import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/add_to_personal_expense/add_to_personal_expense_bloc.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/quicksplit/settle/settle_cubit.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/transaction_model.dart';
import 'package:settlenow_v2/model/user_amount_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/enum/enums.dart';
import 'package:settlenow_v2/util/enum/transaction_type.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/button_with_shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class QuickSplitCard extends StatefulWidget {
  final TransactionModel data;
  const QuickSplitCard({super.key, required this.data});

  @override
  State<QuickSplitCard> createState() => _QuickSplitCardState();
}

class _QuickSplitCardState extends State<QuickSplitCard> {
  UserModel _loggedInUser = UserModel.empty();
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);
  final ValueNotifier<bool> isSettledByYou = ValueNotifier(false);

  List<String> createTags() {
    List<String> tags = [widget.data.category];
    if (!isDateTimeSame(widget.data.createdOn, widget.data.modifiedOn)) {
      tags.add("Edited");
    }
    if (!widget.data.active) {
      tags.add("Settled");
    } else if (widget.data.isClosedAny) {
      tags.add("Partial Settled");
    }
    return tags;
  }

  Widget transactionInfoWidget(bool value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: !value,
          child: const SizedBox(height: UiConstant.cardSpaceAfterSubText),
        ),
        widget.data.hasData
            ? Visibility(
              visible: !value,
              child: overlapUserImageWidget(
                context,
                [widget.data.createdBy, ...widget.data.users],
                4,
                imageRadius: 30,
                nextImageOffset: 24,
              ),
            )
            : CustomShimmerEffect.overlapImageWidget(),
        Visibility(
          visible: !value,
          child: const SizedBox(height: UiConstant.cardSpaceAfterSubText),
        ),
        subTextOnCard(
          "Created By ${widget.data.createdBy.id == _loggedInUser.id ? "You" : widget.data.createdBy.name}",
          isLoaded: widget.data.hasData,
        ),
        subTextOnCard(
          "Created ${convertDateTimeFormat(widget.data.createdOn)}",
          isLoaded: widget.data.hasData,
        ),
        Visibility(
          visible:
              !isDateTimeSame(widget.data.createdOn, widget.data.modifiedOn),
          child: subTextOnCard(
            "Updated ${convertDateTimeFormat(widget.data.modifiedOn)}",
            isLoaded: widget.data.hasData,
          ),
        ),
      ],
    );
  }

  Widget extendedTransactionWidget() {
    return Column(
      children: [
        Divider(),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: widget.data.users.length + 1,
          itemBuilder: (BuildContext context, int index) {
            UserAmountModel user = UserAmountModel.empty();
            if (index == 0) {
              user = widget.data.createdBy;
            } else {
              user = widget.data.users[index - 1];
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    overlapUserImageWidget(context, [user], 1),
                    SizedBox(width: 8),
                    Text(user.name),
                    Visibility(
                      visible: user.isSettled,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Icon(Iconsax.tick_circle, color: Colors.green),
                      ),
                    ),
                  ],
                ),
                Text(
                  formatCurrency(user.amount, context),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: user.amount < 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(thickness: 0.3);
          },
        ),
        ValueListenableBuilder(
          valueListenable: isSettledByYou,
          builder: (context, _, _) {
            return BlocBuilder<SettleCubit, SettleState>(
              builder: (context, state) {
                bool isLoading = false;
                if (state.settlingExpense.contains(widget.data.id)) {
                  isLoading = true;
                }
                return Visibility(
                  visible: widget.data.hasData && !isSettledByYou.value,
                  child: Column(
                    children: [
                      Divider(thickness: 0.3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ButtonWithShimmerEffect(
                            isLoaded: isLoading,
                            buttonText: "Settle",
                            buttonType: CustomButtonType.customElevatedButton,
                            buttonHeight: 40,
                            buttonWidth: 110,
                            borderRadius: 100,
                            buttonTextColor: Colors.green.shade400,
                            backgroundColor: Colors.white,
                            borderColor: Colors.green.shade400,
                            onPressed: () {
                              context.read<SettleCubit>().settleExpense(
                                widget.data.id,
                                _loggedInUser.id,
                                _loggedInUser.authToken,
                                context,
                              );
                            },
                          ),
                          ButtonWithShimmerEffect(
                            isLoaded: isLoading,
                            buttonText:
                                _loggedInUser.id == widget.data.createdBy.id
                                    ? "Delete"
                                    : "Opt Out",
                            buttonType: CustomButtonType.customElevatedButton,
                            buttonHeight: 40,
                            buttonWidth: 110,
                            borderRadius: 100,
                            buttonTextColor: Colors.red.shade400,
                            backgroundColor: Colors.white,
                            borderColor: Colors.red.shade400,
                            onPressed: () {
                              if (_loggedInUser.id ==
                                  widget.data.createdBy.id) {
                                context.read<SettleCubit>().delete(
                                  widget.data.id,
                                  _loggedInUser.id,
                                  _loggedInUser.authToken,
                                  context,
                                );
                              } else {
                                context.read<SettleCubit>().optout(
                                  widget.data.id,
                                  _loggedInUser.id,
                                  _loggedInUser.authToken,
                                  context,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget addToPersonalExpenseWidget() {
    if (widget.data.hasData && !widget.data.isAddedToPersonalExpense) {
      return BlocBuilder<AddToPersonalExpenseBloc, AddToPersonalExpenseState>(
        builder: (context, state) {
          if (state.addingExpenseToPersonalExpense.contains(widget.data.id)) {
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: CustomShimmerEffect.loadingShimmerEffect(
                Icon(Iconsax.profile_add5),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  UiConstant.cardBorderRadius,
                ),
                child: Icon(Iconsax.profile_add, color: Colors.grey),
                onTap: () {
                  context.read<AddToPersonalExpenseBloc>().add(
                    AddToPersonalExpenseRequested(
                      transactionType: TransactionType.quicksplit,
                      transactionID: widget.data.id,
                      authToken: _loggedInUser.authToken,
                    ),
                  );
                },
              ),
            );
          }
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  bool calculateSettledFlag() {
    if (_loggedInUser.id == widget.data.createdBy.id) {
      return widget.data.createdBy.isSettled;
    } else {
      for (int i = 0; i < widget.data.users.length; i++) {
        if (widget.data.users[i].id == _loggedInUser.id) {
          return widget.data.users[i].isSettled;
        }
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> tags = createTags();
    isSettledByYou.value = calculateSettledFlag();

    return Container(
      padding: EdgeInsets.all(UiConstant.cardPadding),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
        border: Border.all(color: Colors.grey.withAlpha(51)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  tags.length,
                  (index) => tagOnCard(
                    tags[index],
                    textColor:
                        UiConstant.colors[index % UiConstant.colors.length],
                    backgroundColor:
                        UiConstant.colorsWithShade50[index %
                            UiConstant.colors.length],
                    isLoaded: widget.data.hasData,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ValueListenableBuilder(
                    valueListenable: isSettledByYou,
                    builder: (context, _, _) {
                      return Visibility(
                        visible: isSettledByYou.value,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Icon(Iconsax.tick_circle, color: Colors.green),
                        ),
                      );
                    },
                  ),
                  addToPersonalExpenseWidget(),
                  Visibility(
                    visible:
                        widget.data.hasData &&
                        widget.data.createdBy.id == _loggedInUser.id &&
                        !isSettledByYou.value,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          UiConstant.cardBorderRadius,
                        ),
                        child: Icon(Iconsax.edit, color: Colors.grey),
                        onTap: () {
                          context.push(
                            RouterConstants.quickSplitEditExpenseRouteName,
                            extra: widget.data,
                          );
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.data.hasData,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        UiConstant.cardBorderRadius,
                      ),
                      child: Icon(Iconsax.info_circle, color: Colors.grey),
                      onTap: () {
                        isExpanded.value = !isExpanded.value;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: UiConstant.cardSpaceBetweenSubText,
                        ),
                        widget.data.hasData
                            ? Text(
                              widget.data.description,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                            : CustomShimmerEffect.textWidget(width: 250),
                        ValueListenableBuilder(
                          valueListenable: isExpanded,
                          builder: (
                            BuildContext context,
                            bool value,
                            Widget? child,
                          ) {
                            return transactionInfoWidget(value);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (context) {
                  if (widget.data.hasData) {
                    UserAmountModel userData = widget.data.users.firstWhere(
                      (user) => user.id == _loggedInUser.id,
                      orElse: () => widget.data.createdBy,
                    );
                    return Text(
                      formatCurrency(userData.amount, context),
                      style: TextStyle(
                        color: userData.amount < 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  } else {
                    return CustomShimmerEffect.textWidget(
                      width: 50,
                      fontSize: 16,
                    );
                  }
                },
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: isExpanded,
            builder: (context, value, child) {
              if (value) {
                return child!;
              } else {
                return SizedBox.shrink();
              }
            },
            child: extendedTransactionWidget(),
          ),
        ],
      ),
    );
  }
}
