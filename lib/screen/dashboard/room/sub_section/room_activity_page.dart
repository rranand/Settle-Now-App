import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';

import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/util/util_core.dart';

class RoomActivityPage extends StatefulWidget {
  final String id;
  final String? transactionID;
  const RoomActivityPage({super.key, required this.id, this.transactionID});

  @override
  State<RoomActivityPage> createState() => _RoomActivityPageState();
}

class _RoomActivityPageState extends State<RoomActivityPage> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  UserModel _loggedInUser = UserModel.empty();
  final ScrollController _gridViewScrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;

    if (mounted) {
      setState(() {});
    }
  }

  void _dataFetchNormal() {
    final oldState = context.read<RoomActivityCubit>().state;
    bool toBeFetched =
        !(oldState is RoomActivitySuccess && oldState.id == widget.id);

    context.read<RoomActivityCubit>().fetchData(widget.id, toBeFetched);

    addPaginationListener<RoomActivityCubit, RoomActivityState>(
      scrollController: _gridViewScrollController,
      context: context,
      hasMore: (state) => state is RoomActivitySuccess && state.hasMoreData,
      isLoadingMore:
          (state) => state is RoomActivitySuccess && state.isLoadingMore,
      onFetch:
          () => context.read<RoomActivityCubit>().fetchData(widget.id, false),
    );
  }

  void _dataFetchEntityWise(BuildContext context) {
    final oldState = context.read<RoomActivityCubit>().state;
    final roomOldState = context.read<RoomBloc>().state;
    final roomSettleOldState = context.read<RoomSettleCubit>().state;

    int activityCount = -1;

    if (roomOldState is RoomFetchSuccess && roomOldState.id == widget.id) {
      final transactionData = roomOldState.data[widget.transactionID!];

      if (transactionData != null) {
        activityCount = transactionData.activityCount;
      }
    }

    if (activityCount == -1 &&
        roomSettleOldState is RoomSettleSuccess &&
        roomSettleOldState.id == widget.id) {
      final settleData = roomSettleOldState.data[widget.transactionID!];

      if (settleData != null) {
        activityCount = settleData.activityCount;
      }
    }

    if (activityCount <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && context.canPop()) {
          context.pop();
        }
      });
      return;
    }

    int currentActivityCount = 0;
    if (oldState is RoomActivitySuccess && oldState.id == widget.id) {
      currentActivityCount =
          oldState.transactionWiseActivity[widget.transactionID!]?.length ?? 0;
    }

    if (currentActivityCount < activityCount) {
      context.read<RoomActivityCubit>().fetchDataByEntityID(
        widget.id,
        widget.transactionID!,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      if (widget.transactionID != null) {
        _dataFetchEntityWise(context);
      } else {
        _dataFetchNormal();
      }
    }
  }

  @override
  void dispose() {
    _gridViewScrollController.dispose();
    super.dispose();
  }

  void _blocListenerHandler(BuildContext context, RoomActivityState state) {
    if (state is RoomActivityFailure) {
      showNormalSnackBar(context, state.error);
    } else if (state is RoomActivitySuccess && state.error != null) {
      showNormalSnackBar(context, state.error!);
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
    if (widget.transactionID != null) {
      context.read<RoomActivityCubit>().fetchDataByEntityID(
        widget.id,
        widget.transactionID!,
      );
    } else {
      context.read<RoomActivityCubit>().fetchData(widget.id, true);
    }
  }

  Widget _builderFooter(BuildContext context, RoomActivityState state) {
    if (state is RoomActivitySuccess) {
      return buildFooter(context, state.isLoadingMore, state.hasMoreData);
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Activity"),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
      ),
      body: BlocBuilder<RoomInfoCubit, RoomInfoState>(
        builder: (context, infoState) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            notificationPredicate: (ScrollNotification notification) {
              return notification.depth == 0;
            },
            child: Padding(
              padding: _mainScreenPadding,
              child: BlocConsumer<RoomActivityCubit, RoomActivityState>(
                listener: _blocListenerHandler,
                builder: (context, state) {
                  List<ActivityModel> data = List.filled(
                    10,
                    ActivityModel.empty(),
                  );

                  if (state is! RoomActivityLoading) {
                    data = [];
                  }

                  if (state is RoomActivitySuccess) {
                    if (widget.transactionID != null) {
                      data =
                          state.transactionWiseActivity[widget
                              .transactionID!] ??
                          [];
                    } else {
                      data = state.data;
                    }
                  }

                  return CustomScrollView(
                    controller: _gridViewScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers:
                        data.isEmpty
                            ? [
                              SliverFillRemaining(
                                child: noRecordFoundWidget(
                                  "No Activity Found",
                                  context,
                                ),
                              ),
                            ]
                            : [
                              SliverList.builder(
                                itemBuilder: (context, index) {
                                  return ActivityCard(data: data[index]);
                                },
                                itemCount: data.length,
                              ),
                              genericFooterForDashboard(
                                ValueNotifier<bool>(
                                  widget.transactionID != null,
                                ),
                                _builderFooter,
                                context,
                                state,
                              ),
                            ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
