import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/util_core.dart';

class RoomTransactionCard extends StatefulWidget {
  final String roomID;
  final RoomTransactionModel data;
  final UserModel loggedInUser;

  const RoomTransactionCard({
    super.key,
    required this.roomID,
    required this.data,
    required this.loggedInUser,
  });

  @override
  State<RoomTransactionCard> createState() => _RoomTransactionCardState();
}

class _RoomTransactionCardState extends State<RoomTransactionCard> {
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);
  final ValueNotifier<bool> userPartOfTransaction = ValueNotifier(false);

  List<String> createTags() {
    List<String> tags = [widget.data.category];
    if (widget.data.splitType != SplitType.equal) {
      tags.add(widget.data.splitType.label);
    }
    if (!isDateTimeSame(widget.data.createdOn, widget.data.modifiedOn)) {
      tags.add("Edited");
    }
    return tags;
  }

  String getName(String createdBy) {
    return widget.data.users
        .firstWhere(
          (element) => element.id == createdBy,
          orElse: () => UserAmountModel.empty(),
        )
        .name;
  }

  Widget extendedTransactionWidget() {
    return Column(
      children: [
        Divider(),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: widget.data.users.length,
          itemBuilder: (BuildContext context, int index) {
            UserAmountModel user = widget.data.users[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      overlapUserImageWidget(context, [user], 1),
                      SizedBox(width: 8),
                      Text(
                        "${user.name}${widget.loggedInUser.id == user.id ? " (You)" : ""}",
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
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(thickness: 0.3);
          },
        ),
      ],
    );
  }

  Widget addToPersonalExpenseWidget() {
    if (widget.data.hasData && widget.data.personalExpenseId.isEmpty) {
      return BlocBuilder<AddToPersonalExpenseBloc, AddToPersonalExpenseState>(
        builder: (context, state) {
          if (state.addingExpenseToPersonalExpense.contains(widget.data.id)) {
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: CustomShimmerEffect.loadingShimmerEffect(
                Icon(Iconsax.profile_add_copy),
              ),
            );
          } else {
            return ValueListenableBuilder(
              valueListenable: userPartOfTransaction,
              builder: (context, _, child) {
                if (userPartOfTransaction.value) {
                  return child!;
                } else {
                  return SizedBox.shrink();
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    UiConstant.cardBorderRadius,
                  ),
                  child: Icon(Iconsax.profile_add_copy, color: Colors.grey),
                  onTap: () {
                    context.read<AddToPersonalExpenseBloc>().add(
                      AddToPersonalExpenseRequested(
                        transactionType: TransactionType.room,
                        transactionID: widget.data.id,
                        roomID: widget.roomID,
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget showTimeline() {
    if (widget.data.hasData) {
      return BlocBuilder<RoomActivityCubit, RoomActivityState>(
        builder: (context, state) {
          if (state is RoomActivitySuccess) {
            List<ActivityModel>? data =
                state.transactionWiseActivity[widget.data.id];

            if (data != null && data.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    UiConstant.cardBorderRadius,
                  ),
                  child: Icon(Icons.timeline_outlined, color: Colors.grey),
                  onTap: () {
                    context.push(
                      "${RouterConstants.roomRouteName}/${widget.roomID}${RouterConstants.roomActivityRouteName}/${widget.data.id}",
                    );
                  },
                ),
              );
            }
          }
          return SizedBox.shrink();
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.data.hasData) {
      if (widget.data.createdBy == widget.loggedInUser.id) {
        userPartOfTransaction.value = true;
      } else {
        for (int i = 0; i < widget.data.users.length; i++) {
          if (widget.data.users[i].id == widget.loggedInUser.id) {
            userPartOfTransaction.value = true;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> tags = createTags();
    int categoryIndex = CategoryParser.indexOfCategory(widget.data.category);
    bool isManualSplit = false;
    if (widget.data.users.isNotEmpty) {
      isManualSplit = true;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () {
        if (widget.loggedInUser.id == widget.data.createdBy) {
          context.push(
            "${RouterConstants.roomRouteName}/${widget.roomID}${RouterConstants.roomEditExpenseRouteName}",
            extra: widget.data,
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(UiConstant.cardPadding),
        margin: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
          boxShadow: getContainerBoxShadow(context),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: widget.data.hasData,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      tags.length,
                      (index) => tagOnCard(
                        tags[index],
                        context,
                        textColor:
                            UiConstant.colors[index % UiConstant.colors.length],
                        backgroundColor:
                            UiConstant.colorsWithShade50[index %
                                UiConstant.colors.length],
                        isLoaded: widget.data.hasData,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    addToPersonalExpenseWidget(),
                    showTimeline(),
                    Visibility(
                      visible: isManualSplit,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          UiConstant.cardBorderRadius,
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: isExpanded,
                          builder: (context, _, _) {
                            return Icon(
                              isExpanded.value
                                  ? Icons.keyboard_arrow_up_outlined
                                  : Icons.keyboard_arrow_down_outlined,
                              size: 28,
                              color: Colors.grey,
                            );
                          },
                        ),
                        onTap: () {
                          isExpanded.value = !isExpanded.value;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  widget.data.hasData
                      ? colouredIcon(
                        CategoryParser.expenseCategoryIcons[categoryIndex %
                            CategoryParser.expenseCategoryIcons.length],
                        UiConstant.colorsWithShade100[categoryIndex %
                            CategoryParser.expenseCategoryIcons.length],
                      )
                      : CustomShimmerEffect.imageWidget(
                        context,
                        shape: BoxShape.circle,
                        radius: 50,
                      ),
              title:
                  widget.data.hasData
                      ? Text(widget.data.description)
                      : CustomShimmerEffect.textWidget(context, width: 125),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  subTextOnCard(
                    "Created By ${widget.loggedInUser.id == widget.data.createdBy ? "You" : getName(widget.data.createdBy)}",
                    context,
                    isLoaded: widget.data.hasData,
                  ),
                  subTextOnCard(
                    "Created ${convertDateTimeFormat(widget.data.createdOn)}",
                    context,
                    isLoaded: widget.data.hasData,
                  ),
                  !isDateTimeSame(widget.data.createdOn, widget.data.modifiedOn)
                      ? subTextOnCard(
                        "Updated ${convertDateTimeFormat(widget.data.modifiedOn)}",
                        context,
                        isLoaded: widget.data.hasData,
                      )
                      : subTextOnCard(
                        "",
                        context,
                        isLoaded: widget.data.hasData,
                      ),
                ],
              ),
              trailing:
                  widget.data.hasData
                      ? Text(
                        formatCurrency(widget.data.amount, context),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                      : CustomShimmerEffect.textWidget(
                        context,
                        width: 50,
                        fontSize: 16,
                      ),
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
      ),
    );
  }
}
