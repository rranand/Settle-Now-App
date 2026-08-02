import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    }
  }

  void _blocListenerHandler(BuildContext context, RoomActivityState state) {
    if (state is RoomActivityFailure) {
      showNormalSnackBar(context, state.error);
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
    context.read<RoomActivityCubit>().fetchData(widget.id, forceRefresh: true);
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
          Map<String, String> userMapping = {};

          if (infoState is RoomInfoSuccess) {
            for (int i = 0; i < infoState.data.users.length; i++) {
              if (infoState.data.users[i].id == _loggedInUser.id) {
                userMapping[infoState.data.users[i].id] = "you";
              } else {
                userMapping[infoState.data.users[i].id] =
                    infoState.data.users[i].name.split(' ').first;
              }
            }
          }

          return RefreshIndicator(
            onRefresh: onRefresh,
            child: BlocConsumer<RoomActivityCubit, RoomActivityState>(
              listener: _blocListenerHandler,
              builder: (context, state) {
                List<ActivityModel> data = List.filled(
                  10,
                  ActivityModel.empty(),
                );

                if (state is RoomActivitySuccess) {
                  data = state.data;
                }

                if (data.isEmpty) {
                  return noRecordFoundWidget(
                    "Something Went Wrong, Refresh!",
                    context,
                  );
                }

                return ListView.builder(
                  padding: _mainScreenPadding.add(
                    EdgeInsets.only(
                      top: UiConstant.spaceBetweenSection,
                      bottom: UiConstant.spaceAtBottom,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    ActivityModel activityData = data[data.length - index - 1];

                    if (widget.transactionID != null) {
                      if (widget.transactionID == activityData.entityId) {
                        return ActivityCard(
                          data: activityData,
                          userMapping: userMapping,
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    } else {
                      return ActivityCard(
                        data: activityData,
                        userMapping: userMapping,
                      );
                    }
                  },
                  itemCount: data.length,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
