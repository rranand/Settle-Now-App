import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class NotificationCard extends StatefulWidget {
  final String loggedInUserID;
  final NotificationModel data;
  const NotificationCard({
    super.key,
    required this.loggedInUserID,
    required this.data,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  Widget leadingIcon() {
    if (!widget.data.hasData) {
      return CustomShimmerEffect.imageWidget(
        context,
        shape: BoxShape.circle,
        radius: 50,
      );
    }
    if (widget.data.invitedBy.id == widget.data.invitedUser.id) {
      if (widget.data.invitedBy.id != widget.loggedInUserID) {
        return imageWidgetForCachedNetworkImage(
          widget.data.invitedBy.profileImage,
          context,
          boxShape: BoxShape.circle,
          width: 50,
          height: 50,
        );
      } else if (widget.data.type == RoomType.room) {
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
    } else if (widget.data.invitedBy.id == widget.loggedInUserID) {
      return imageWidgetForCachedNetworkImage(
        widget.data.invitedUser.profileImage,
        context,
        boxShape: BoxShape.circle,
        width: 50,
        height: 50,
      );
    } else {
      return imageWidgetForCachedNetworkImage(
        widget.data.invitedBy.profileImage,
        context,
        boxShape: BoxShape.circle,
        width: 50,
        height: 50,
      );
    }
  }

  Widget title() {
    if (widget.data.invitedBy.id == widget.data.invitedUser.id) {
      if (widget.data.invitedBy.id == widget.loggedInUserID) {
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
            text: widget.data.invitedBy.name,
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
    } else if (widget.data.invitedBy.id == widget.loggedInUserID) {
      return Text.rich(
        TextSpan(
          text: "You invited ",
          children: [
            TextSpan(
              text: widget.data.invitedUser.name,
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
          text: widget.data.invitedBy.name,
          style: TextStyle(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: " invited ",
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            TextSpan(
              text: widget.data.invitedUser.name,
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
                    (widget.data.invitedUser.id != widget.data.invitedBy.id &&
                        widget.data.invitedUser.id == widget.loggedInUserID) ||
                    (widget.data.invitedUser.id == widget.data.invitedBy.id &&
                        widget.data.invitedUser.id != widget.loggedInUserID),
                child: Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: InkWell(
                    onTap: () {
                      context.read<NotificationActionBloc>().add(
                        NotificationActionAcceptRequested(id: widget.data.id),
                      );
                    },
                    child: Icon(Icons.check, color: Colors.green),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  context.read<NotificationActionBloc>().add(
                    NotificationActionDeclineRequested(id: widget.data.id),
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
      child: Container(
        padding: const EdgeInsets.all(UiConstant.cardPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
          boxShadow: getContainerBoxShadow(context),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: leadingIcon(),
              title:
                  widget.data.hasData
                      ? title()
                      : CustomShimmerEffect.textWidget(context, width: 80),
              subtitle:
                  widget.data.hasData
                      ? Text(
                        widget.data.type.label,
                        style: TextStyle(color: Colors.grey[600]),
                      )
                      : CustomShimmerEffect.textWidget(
                        context,
                        fontSize: 10,
                        width: 80,
                      ),
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
