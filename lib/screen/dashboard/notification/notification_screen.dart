import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/notification/notification_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/notification_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/card/notification_card.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  UserModel _loggedInUser = UserModel.empty();

  void _blocListenerHandler(BuildContext context, NotificationState state) {
    if (state is NotificationFailure) {
      showNormalSnackBar(context, state.error);
    }
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      final state = context.read<NotificationBloc>().state;

      if (state is! NotificationFetchSuccess) {
        context.read<NotificationBloc>().add(
          NotificationFetch(authToken: _loggedInUser.authToken),
        );
      }
    }
  }

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(context, "Please re-login...Session expired!");
      return;
    }
    context.read<NotificationBloc>().add(
      NotificationFetch(authToken: _loggedInUser.authToken),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > UiConstant.maxWidth;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: BlocConsumer<NotificationBloc, NotificationState>(
          listener: _blocListenerHandler,
          builder: (context, state) {
            List<NotificationModel> notificationData = [];
            if (state is NotificationFetchSuccess) {
              notificationData = state.data;
            } else if (state is NotificationLoading) {
              notificationData = List.generate(
                11,
                (i) => NotificationModel.empty(),
              );
            }
            if (notificationData.isEmpty) {
              return noRecordFoundWidget("No Notification Found", context);
            }
            int noOfCardsToBeShown = notificationData.length;
            if (isWide) {
              noOfCardsToBeShown =
                  (noOfCardsToBeShown / 2).toInt() + noOfCardsToBeShown % 2;
            }
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: UiConstant.spaceBetweenCard,
                bottom: UiConstant.spaceAtBottom,
              ),
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: noOfCardsToBeShown,
                itemBuilder: (context, index) {
                  NotificationModel eachNotificationData =
                      notificationData[index];
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: NotificationCard(
                            data: eachNotificationData,
                            loggedInUserID: _loggedInUser.id,
                            authToken: _loggedInUser.authToken,
                          ),
                        ),
                        Expanded(
                          child:
                              (index == noOfCardsToBeShown - 1 &&
                                      notificationData.length % 2 > 0)
                                  ? SizedBox()
                                  : NotificationCard(
                                    data: notificationData[2 * index + 1],
                                    loggedInUserID: _loggedInUser.id,
                                    authToken: _loggedInUser.authToken,
                                  ),
                        ),
                      ],
                    );
                  } else {
                    return NotificationCard(
                      data: eachNotificationData,
                      loggedInUserID: _loggedInUser.id,
                      authToken: _loggedInUser.authToken,
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
