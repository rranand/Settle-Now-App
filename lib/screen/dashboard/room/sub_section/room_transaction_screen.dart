import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/room/each_room/room_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/util/card/room_transaction_card.dart';

class RoomTransactionScreen extends StatefulWidget {
  const RoomTransactionScreen({super.key});

  @override
  State<RoomTransactionScreen> createState() => _RoomTransactionScreenState();
}

class _RoomTransactionScreenState extends State<RoomTransactionScreen> {
  final UserModel loggedInUser = UserModel.fromMap({
    'id': 'user_1',
    'name': 'Rohit Anand',
  });

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > UiConstant.maxWidth;

    return BlocBuilder<RoomBloc, RoomState>(
      builder: (context, state) {
        List<TransactionModel> data = [];
        if (state is RoomFetchSuccess) {
          data = state.data;
        } else {
          data = List.filled(11, TransactionModel.empty());
        }
        int noOfCardsToBeShown = (data.length / 2).toInt() + data.length % 2;
        return SliverList.builder(
          itemCount: isWide ? noOfCardsToBeShown : data.length,
          itemBuilder: (BuildContext context, int index) {
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RoomTransactionCard(
                      data: data[index],
                      loggedInUser: loggedInUser,
                    ),
                  ),
                  Expanded(
                    child:
                        (index == noOfCardsToBeShown - 1 && data.length % 2 > 0)
                            ? SizedBox()
                            : RoomTransactionCard(
                              data: data[index],
                              loggedInUser: loggedInUser,
                            ),
                  ),
                ],
              );
            } else {
              return RoomTransactionCard(
                data: data[index],
                loggedInUser: loggedInUser,
              );
            }
          },
        );
      },
    );
  }
}
