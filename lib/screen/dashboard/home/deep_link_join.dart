import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/util_core.dart';

class DeepLinkJoin extends StatefulWidget {
  final TransactionType transactionType;
  final String id;

  const DeepLinkJoin({
    super.key,
    required this.transactionType,
    required this.id,
  });

  @override
  State<DeepLinkJoin> createState() => _DeepLinkJoinState();
}

class _DeepLinkJoinState extends State<DeepLinkJoin> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

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
      switch (widget.transactionType) {
        case TransactionType.room:
          {
            context.read<CreateJoinRoomCubit>().joinNewRoom(
              widget.id,
              ScaffoldMessenger.of(context),
            );
            break;
          }
        default:
          {
            context.pushReplacement(RouterConstants.dashboardRouteName);
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateJoinRoomCubit, CreateJoinRoomState>(
      listener: (context, state) {
        if (state is CreateJoinRoomSuccess) {
          context.pushReplacement(RouterConstants.dashboardRouteName);
        } else if (state is CreateJoinRoomFailure) {
          showNormalSnackBar(context, state.error);
          context.pushReplacement(RouterConstants.dashboardRouteName);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text("Settle Now"),
            titleSpacing: _mainScreenPadding.left,
            centerTitle: false,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 10),
                Text("Joining Room...", style: TextStyle(fontSize: 22)),
              ],
            ),
          ),
        );
      },
    );
  }
}
