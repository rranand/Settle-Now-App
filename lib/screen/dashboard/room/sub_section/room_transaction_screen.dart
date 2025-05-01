import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/util/card/room_transaction_card.dart';

class RoomTransactionScreen extends StatefulWidget {
  const RoomTransactionScreen({super.key});

  @override
  State<RoomTransactionScreen> createState() => _RoomTransactionScreenState();
}

class _RoomTransactionScreenState extends State<RoomTransactionScreen> {
  final List<int> transactionArr = List.generate(11, (i) => i);
  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > UiConstant.maxWidth;
    int noOfCardsToBeShown =
        (transactionArr.length / 2).toInt() + transactionArr.length % 2;

    return SliverList.builder(
      itemCount: isWide ? noOfCardsToBeShown : transactionArr.length,
      itemBuilder: (BuildContext context, int index) {
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RoomTransactionCard(data: TransactionModel.empty()),
              ),
              Expanded(
                child:
                    (index == noOfCardsToBeShown - 1 &&
                            transactionArr.length % 2 > 0)
                        ? SizedBox()
                        : RoomTransactionCard(data: TransactionModel.empty()),
              ),
            ],
          );
        } else {
          return RoomTransactionCard(data: TransactionModel.empty());
        }
      },
    );
  }
}
