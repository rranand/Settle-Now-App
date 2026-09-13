import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
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
  final ScrollController _gridViewScrollController = ScrollController();

  void _requestBlocListenerHandler(
    BuildContext context,
    NotificationState state,
  ) {
    if (state is NotificationFailure) {
      showNormalSnackBar(context, state.error);
    }
  }

  void _activityBlocListenerHandler(
    BuildContext context,
    ActivityNotificationState state,
  ) {
    if (state is ActivityNotificationFailure) {
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

      final requestState = context.read<NotificationBloc>().state;
      final activityState = context.read<ActivityNotificationBloc>().state;

      if (requestState is! NotificationFetchSuccess) {
        context.read<NotificationBloc>().add(NotificationFetch());
      }

      if (activityState is! ActivityNotificationFetchSuccess) {
        context.read<ActivityNotificationBloc>().add(
          ActivityNotificationFetch(isFreshFetch: true),
        );
      }

      addPaginationListener<
        ActivityNotificationBloc,
        ActivityNotificationState
      >(
        scrollController: _gridViewScrollController,
        context: context,
        hasMore:
            (state) =>
                state is ActivityNotificationFetchSuccess && state.hasMoreData,
        isLoadingMore:
            (state) =>
                state is ActivityNotificationFetchSuccess &&
                state.isLoadingMore,
        onFetch:
            () => context.read<ActivityNotificationBloc>().add(
              ActivityNotificationFetch(isFreshFetch: false),
            ),
      );
    }
  }

  @override
  void dispose() {
    _gridViewScrollController.dispose();
    super.dispose();
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
    context.read<ActivityNotificationBloc>().add(
      ActivityNotificationFetch(isFreshFetch: true),
    );
    context.read<UnreadNotificationCountCubit>().fetchUnreadNotificationCount();
  }

  Widget _builderFooter(BuildContext context, ActivityNotificationState state) {
    if (state is ActivityNotificationFetchSuccess) {
      return buildFooter(context, state.isLoadingMore, state.hasMoreData);
    }

    return const SizedBox.shrink();
  }

  Widget _showTagsOnActivityNotificationCard(DateTime recentlyReadTimestamp) {
    return Consumer<UnreadNotificationCountCubit>(
      builder: (context, unreadNotificationCountCubit, _) {
        final state = unreadNotificationCountCubit.state;

        if (state is UnreadNotificationCountSuccess && state.count > 0) {
          if (state.count > 0) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: tagOnCard(
                    "${state.count} Unread",
                    context,
                    textColor: UiConstant.colors[0],
                    backgroundColor: UiConstant.colorsWithShade50[0],
                    isLoaded: true,
                  ),
                ),
                CustomButton.customTextButton(
                  'Mark all as read',
                  onPressed: () {
                    context.read<ActivityNotificationBloc>().add(
                      ActivityNotificationMarkAllAsRead(
                        recentlyReadTimestamp: recentlyReadTimestamp,
                        scaffoldMessenger: ScaffoldMessenger.of(context),
                      ),
                    );
                  },
                ),
              ],
            );
          }
        }

        return SizedBox.shrink();
      },
    );
  }

  Widget _buildRequestNotificationSection() {
    return BlocConsumer<NotificationBloc, NotificationState>(
      listener: _requestBlocListenerHandler,
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
            EdgeInsets.only(top: UiConstant.spaceBetweenCard),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (state is NotificationFetchSuccess) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
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
    );
  }

  Widget _buildActivityNotificationSection() {
    bool isWide = MediaQuery.of(context).size.width > UiConstant.maxWidth;

    return BlocConsumer<ActivityNotificationBloc, ActivityNotificationState>(
      listener: _activityBlocListenerHandler,
      builder: (context, state) {
        List<ActivityNotificationModel> notificationData = [];

        if (state is ActivityNotificationFetchSuccess) {
          notificationData = state.dataList;
        } else if (state is ActivityNotificationLoading) {
          notificationData = List.generate(
            11,
            (index) => ActivityNotificationModel.empty(),
          );
        }

        if (notificationData.isEmpty) {
          return SliverFillRemaining(
            child: freshMessageWidget(
              FreshScreenMessageConstant.noActivityNotification,
            ),
          );
        }

        int noOfCardsToBeShown = notificationData.length;
        if (isWide) {
          noOfCardsToBeShown =
              (noOfCardsToBeShown / 2).toInt() + noOfCardsToBeShown % 2;
        }

        return SliverPadding(
          padding: _mainScreenPadding.add(
            EdgeInsets.only(
              top: UiConstant.spaceBetweenCard,
              bottom: UiConstant.spaceAtBottom,
            ),
          ),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      'Activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (state is ActivityNotificationFetchSuccess &&
                        notificationData.isNotEmpty) ...[
                      Expanded(
                        child: _showTagsOnActivityNotificationCard(
                          notificationData.first.createdOn,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SliverList.builder(
                itemCount: noOfCardsToBeShown,
                itemBuilder: (context, index) {
                  if (isWide) {
                    final eachNotificationData = notificationData[2 * index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ActivityNotificationCard(
                            data: eachNotificationData,
                          ),
                        ),
                        Expanded(
                          child:
                              (index == noOfCardsToBeShown - 1 &&
                                      notificationData.length % 2 > 0)
                                  ? SizedBox()
                                  : ActivityNotificationCard(
                                    data: notificationData[2 * index + 1],
                                  ),
                        ),
                      ],
                    );
                  } else {
                    return ActivityNotificationCard(
                      data: notificationData[index],
                    );
                  }
                },
              ),
              genericFooterForDashboard(
                ValueNotifier<bool>(false),
                _builderFooter,
                context,
                state,
                isFilterApplied: false,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        notificationPredicate: (ScrollNotification notification) {
          return notification.depth == 0;
        },
        child: CustomScrollView(
          controller: _gridViewScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildRequestNotificationSection(),
            _buildActivityNotificationSection(),
          ],
        ),
      ),
    );
  }
}
