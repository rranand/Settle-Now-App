import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/notification_action/notification_action_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/notification_model.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/image_widget.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class NotificationCard extends StatefulWidget {
  final String loggedInUserID;
  final String authToken;
  final NotificationModel data;
  const NotificationCard({
    super.key,
    required this.loggedInUserID,
    required this.authToken,
    required this.data,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  Widget leadingIcon() {
    if (!widget.data.hasData) {
      return CustomShimmerEffect.imageWidget(
        shape: BoxShape.circle,
        radius: 50,
      );
    }
    if (widget.data.by.id == widget.data.user.id) {
      if (widget.data.by.id != widget.loggedInUserID) {
        return imageWidgetForCachedNetworkImage(
          widget.data.by.profileImage,
          boxShape: BoxShape.circle,
          width: 50,
          height: 50,
        );
      } else if (widget.data.type == "Room") {
        return colouredIcon(
          Icons.groups_outlined,
          iconSize: 30,
          Colors.redAccent.shade100,
        );
      } else {
        return colouredIcon(
          Icons.group,
          iconSize: 30,
          Colors.blueAccent.shade100,
        );
      }
    } else if (widget.data.by.id == widget.loggedInUserID) {
      return imageWidgetForCachedNetworkImage(
        widget.data.user.profileImage,
        boxShape: BoxShape.circle,
        width: 50,
        height: 50,
      );
    } else {
      return imageWidgetForCachedNetworkImage(
        widget.data.by.profileImage,
        boxShape: BoxShape.circle,
        width: 50,
        height: 50,
      );
    }
  }

  Widget title() {
    if (widget.data.by.id == widget.data.user.id) {
      if (widget.data.by.id == widget.loggedInUserID) {
        return Text.rich(
          TextSpan(
            text: "You requested to join",
            children: [
              TextSpan(text: " "),
              TextSpan(
                text: widget.data.roomName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      } else {
        return Text.rich(
          TextSpan(
            text: widget.data.by.name,
            style: TextStyle(fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: " wants to join ",
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              TextSpan(text: widget.data.roomName),
            ],
          ),
        );
      }
    } else if (widget.data.by.id == widget.loggedInUserID) {
      return Text.rich(
        TextSpan(
          text: "You invited ",
          children: [
            TextSpan(
              text: widget.data.user.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: " to join ",
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            TextSpan(
              text: widget.data.roomName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      return Text.rich(
        TextSpan(
          text: widget.data.by.name,
          style: TextStyle(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: " invited ",
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            TextSpan(
              text: widget.data.user.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: " to join ",
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            TextSpan(text: widget.data.roomName),
          ],
        ),
      );
    }
  }

  Widget actionButton() {
    return BlocConsumer<NotificationActionBloc, NotificationActionState>(
      listener: (context, state) {
        if (state.error != null) {
          showNormalSnackBar(context, state.error!);
        }
      },
      builder: (context, state) {
        if (state.processingNotification.contains(widget.data.id)) {
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: CustomShimmerEffect.shimmerCircularProgressIndicator(
              radius: 24,
            ),
          );
        } else {
          return Row(
            children: [
              Visibility(
                visible:
                    (widget.data.user.id != widget.data.by.id &&
                        widget.data.user.id == widget.loggedInUserID) ||
                    (widget.data.user.id == widget.data.by.id &&
                        widget.data.user.id != widget.loggedInUserID),
                child: Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: InkWell(
                    onTap: () {
                      context.read<NotificationActionBloc>().add(
                        NotificationActionAcceptRequested(
                          id: widget.data.id,
                          authToken: widget.authToken,
                        ),
                      );
                    },
                    child: Icon(Icons.check, color: Colors.green),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  context.read<NotificationActionBloc>().add(
                    NotificationActionDeclineRequested(
                      id: widget.data.id,
                      authToken: widget.authToken,
                    ),
                  );
                },
                child: Icon(Icons.close, color: Colors.red),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiConstant.cardPadding),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: leadingIcon(),
              title:
                  widget.data.hasData
                      ? title()
                      : CustomShimmerEffect.textWidget(width: 80),
              subtitle:
                  widget.data.hasData
                      ? Text(
                        widget.data.type,
                        style: TextStyle(color: Colors.grey[600]),
                      )
                      : CustomShimmerEffect.textWidget(fontSize: 10, width: 80),
            ),
            Visibility(
              visible: widget.data.hasData,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      convertToMoment(widget.data.createdOn),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  actionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
