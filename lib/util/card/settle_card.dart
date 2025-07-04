import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/room_settle_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

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
              : CustomShimmerEffect.textWidget(width: 90),
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
        elevation: UiConstant.cardElevation,
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(UiConstant.cardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
            border: Border.all(color: Colors.grey.withAlpha(51)),
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
                  Icon(Iconsax.arrow_right_14),
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
                        ? Text(
                          formatCurrency(data.amount.abs(), context),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        )
                        : CustomShimmerEffect.textWidget(
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
                    fontSize: 14,
                    isLoaded: data.hasData,
                  ),
                  Row(
                    children: [
                      subTextOnCard(
                        _getAddedByString(),
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
