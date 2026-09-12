import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/util/util_core.dart';

class RequestNotificationScreen extends StatefulWidget {
  const RequestNotificationScreen({super.key});

  @override
  State<RequestNotificationScreen> createState() =>
      _RequestNotificationScreenState();
}

class _RequestNotificationScreenState extends State<RequestNotificationScreen> {
  UserModel _loggedInUser = UserModel.empty();
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  void _blocListenerHandler(BuildContext context, NotificationState state) {
    if (state is NotificationFailure) {
      showNormalSnackBar(context, state.error);
    }
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

      final state = context.read<NotificationBloc>().state;

      if (state is! NotificationFetchSuccess) {
        context.read<NotificationBloc>().add(NotificationFetch());
      }
    }
  }

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(
        context,
        SnackbarMessageConstant.sessionExpiredMessage,
      );
      return;
    }
    context.read<NotificationBloc>().add(NotificationFetch());
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > UiConstant.maxWidth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
        leading: appBarBackButton(context),
        titleSpacing: _mainScreenPadding.left,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        notificationPredicate: (ScrollNotification notification) {
          return notification.depth == 0;
        },
        child: BlocConsumer<NotificationBloc, NotificationState>(
          listener: _blocListenerHandler,
          builder: (context, state) {
            List<NotificationModel> notificationData = [];
            if (state is NotificationFetchSuccess) {
              notificationData = state.dataList;
            } else if (state is NotificationLoading) {
              notificationData = List.generate(
                11,
                (i) => NotificationModel.empty(),
              );
            }
            if (notificationData.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: freshMessageWidget(
                        FreshScreenMessageConstant.noRequestDashboard,
                      ),
                    ),
                  );
                },
              );
            }

            int noOfCardsToBeShown = notificationData.length;
            if (isWide) {
              noOfCardsToBeShown =
                  (noOfCardsToBeShown / 2).toInt() + noOfCardsToBeShown % 2;
            }

            return Padding(
              padding: _mainScreenPadding.add(
                EdgeInsets.only(top: UiConstant.spaceBetweenCard),
              ),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: noOfCardsToBeShown,
                itemBuilder: (context, index) {
                  if (isWide) {
                    NotificationModel eachNotificationData =
                        notificationData[2 * index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: NotificationCard(
                            data: eachNotificationData,
                            loggedInUserID: _loggedInUser.id,
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
                                  ),
                        ),
                      ],
                    );
                  } else {
                    return NotificationCard(
                      data: notificationData[index],
                      loggedInUserID: _loggedInUser.id,
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
