import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/util_core.dart';

class SettleCard extends StatelessWidget {
  final String roomID;
  final double screenWidth;
  final RoomSettleModel data;
  final UserModel loggedInUser;

  const SettleCard({
    super.key,
    required this.roomID,
    required this.screenWidth,
    required this.data,
    required this.loggedInUser,
  });

  Widget _userCard(BuildContext context, UserModel user, bool isLast) {
    final userCardWidth = (screenWidth - 2 * UiConstant.cardPadding - 36) * .5;
    return SizedBox(
      width: userCardWidth,
      child: Row(
        mainAxisAlignment:
            isLast ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          user.hasData
              ? overlapUserImageWidget(context, [user], 1, imageRadius: 40)
              : CustomShimmerEffect.overlapImageWidget(
                context,
                noOfImages: 1,
                imageRadius: 40,
              ),
          SizedBox(width: 8),
          user.hasData
              ? Flexible(
                child: Text(
                  user.name,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              )
              : CustomShimmerEffect.textWidget(context, width: 90),
        ],
      ),
    );
  }

  String _getAddedByString() {
    String str = "Added By ";
    if (data.sender.id == loggedInUser.id) {
      str += "You";
    } else {
      str += data.sender.name.split(" ").first;
    }
    return str;
  }

  Widget showTimeline() {
    return BlocBuilder<RoomActivityCubit, RoomActivityState>(
      builder: (context, state) {
        if (state is RoomActivitySuccess) {
          List<ActivityModel>? activityData =
              state.transactionWiseActivity[data.id];

          if (activityData != null && activityData.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  UiConstant.cardBorderRadius,
                ),
                child: Icon(Icons.timeline_outlined, color: Colors.grey),
                onTap: () {
                  context.push(
                    "${RouterConstants.roomRouteName}/$roomID${RouterConstants.roomActivityRouteName}/${data.id}",
                  );
                },
              ),
            );
          }
        }
        return SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () {
        if (loggedInUser.id == data.sender.id) {
          context.push(
            "${RouterConstants.roomRouteName}/$roomID${RouterConstants.roomSettleEditRouteName}",
            extra: data,
          );
        }
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(UiConstant.cardPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
            boxShadow: getContainerBoxShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _userCard(
                    context,
                    data.amount > 0 ? data.sender : data.receiver,
                    false,
                  ),
                  Icon(Iconsax.arrow_right_1_copy),
                  _userCard(
                    context,
                    data.amount > 0 ? data.receiver : data.sender,
                    true,
                  ),
                ],
              ),
              SizedBox(height: UiConstant.spaceBetweenSection),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child:
                    data.hasData
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatCurrency(data.amount.abs(), context),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            showTimeline(),
                          ],
                        )
                        : CustomShimmerEffect.textWidget(
                          context,
                          fontSize: 20,
                          width: 80,
                        ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  subTextOnCard(
                    convertDateTimeFormat(data.modifiedOn),
                    context,
                    fontSize: 14,
                    isLoaded: data.hasData,
                  ),
                  Row(
                    children: [
                      subTextOnCard(
                        _getAddedByString(),
                        context,
                        fontSize: 14,
                        isLoaded: data.hasData,
                      ),
                      Visibility(
                        visible: data.sender.id == loggedInUser.id,
                        child: Container(
                          width: 8,
                          height: 8,
                          margin: EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
