import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/room/each_room/room_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/util/card/room_transaction_card.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class RoomTransactionScreen extends StatefulWidget {
  final String roomID;
  const RoomTransactionScreen({super.key, required this.roomID});

  @override
  State<RoomTransactionScreen> createState() => _RoomTransactionScreenState();
}

class _RoomTransactionScreenState extends State<RoomTransactionScreen> {
  UserModel _loggedInUser = UserModel.empty();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > UiConstant.maxWidth;

    return BlocConsumer<RoomBloc, RoomState>(
      builder: (context, state) {
        List<TransactionModel> data = [];
        if (state is RoomFetchSuccess) {
          data = state.data;
        } else {
          data = List.filled(11, TransactionModel.empty());
        }
        int noOfCardsToBeShown = (data.length / 2).toInt() + data.length % 2;
        return data.isEmpty
            ? SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: noRecordFoundWidget("No Transaction Found"),
              ),
            )
            : SliverList.builder(
              itemCount: isWide ? noOfCardsToBeShown : data.length,
              itemBuilder: (BuildContext context, int index) {
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RoomTransactionCard(
                          roomID: widget.roomID,
                          data: data[index],
                          loggedInUser: _loggedInUser,
                        ),
                      ),
                      Expanded(
                        child:
                            (index == noOfCardsToBeShown - 1 &&
                                    data.length % 2 > 0)
                                ? SizedBox()
                                : RoomTransactionCard(
                                  roomID: widget.roomID,
                                  data: data[index],
                                  loggedInUser: _loggedInUser,
                                ),
                      ),
                    ],
                  );
                } else {
                  return RoomTransactionCard(
                    roomID: widget.roomID,
                    data: data[index],
                    loggedInUser: _loggedInUser,
                  );
                }
              },
            );
      },
      listener: (BuildContext context, RoomState state) {
        if (state is RoomFailure) {
          showNormalSnackBar(context, state.error);
        }
      },
    );
  }
}
