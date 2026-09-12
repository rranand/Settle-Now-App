import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/util_core.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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
      body: RefreshIndicator(
        onRefresh: onRefresh,
        notificationPredicate: (ScrollNotification notification) {
          return notification.depth == 0;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BlocConsumer<NotificationBloc, NotificationState>(
              listener: _blocListenerHandler,
              builder: (context, state) {
                List<NotificationModel> notificationData = [];

                if (state is NotificationFetchSuccess) {
                  notificationData = state.dataList;
                } else if (state is NotificationLoading) {
                  notificationData = List.generate(
                    2,
                    (index) => NotificationModel.empty(),
                  );
                }

                if (notificationData.isEmpty) {
                  return SliverToBoxAdapter(child: SizedBox.shrink());
                }

                final previewData = notificationData.take(3).toList();

                return SliverPadding(
                  padding: _mainScreenPadding.add(
                    EdgeInsets.only(
                      top: UiConstant.spaceBetweenCard,
                      bottom: UiConstant.spaceAtBottom,
                    ),
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Text(
                              'Requests',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (state is NotificationFetchSuccess) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  notificationData.length.toString(),
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: [
                            for (
                              int index = 0;
                              index < previewData.length;
                              index++
                            ) ...[
                              NotificationCard(
                                data: previewData[index],
                                loggedInUserID: _loggedInUser.id,
                                isPreview: true,
                              ),
                            ],
                          ],
                        ),
                        if (state is NotificationFetchSuccess) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: CustomButton.customTextButton(
                              'View all ${notificationData.length} requests',
                              onPressed: () {
                                context.push(
                                  RouterConstants.requestNotificationRouteName,
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
