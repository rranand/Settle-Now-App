import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/util/card/settle_card.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';

class RoomSettleScreen extends StatefulWidget {
  const RoomSettleScreen({super.key});

  @override
  State<RoomSettleScreen> createState() => _RoomSettleScreenState();
}

class _RoomSettleScreenState extends State<RoomSettleScreen> {
  final List<int> tempArr = List.generate(11, (i) => i);
  List<String> statusList = ["Open", "Closed", "Partially Closed"];

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraint) {
        final cardSizeInfo = calculateCrossAspectRatio(
          constraint.crossAxisExtent,
          EdgeInsets.zero,
        );

        return SliverGrid.builder(
          itemCount: tempArr.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: cardSizeInfo[0],
            mainAxisSpacing: UiConstant.spaceBetweenCard,
            crossAxisSpacing: UiConstant.spaceBetweenCard,
            childAspectRatio: cardSizeInfo[1],
          ),
          itemBuilder: (BuildContext context, int index) {
            return SettleCard(screenWidth: cardSizeInfo[0]);
          },
        );
      },
    );
  }
}
