import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/bloc/auth/auth_bloc.dart';
import 'package:settlenow/cubit/room/create_join_room/create_join_room_cubit.dart';
import 'package:settlenow/provider/screen_size_provider.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/enum/transaction_type.dart';
import 'package:settlenow/util/widgets/snackbar.dart';

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
