import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/lenden_room_model.dart';
import 'package:settlenow_v2/model/transaction_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class LendenExpenseCard extends StatelessWidget {
  final String lendenID;
  final LendenTransactionModel data;
  final UserModel loggedInUser;

  const LendenExpenseCard({
    super.key,
    required this.lendenID,
    required this.data,
    required this.loggedInUser,
  });

  BorderRadius _borderRadius(bool isMe) {
    return BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 0),
      bottomRight: Radius.circular(isMe ? 0 : 16),
    );
  }

  String calculateDirection(bool isMe) {
    if (isMe) {
      return data.amount < 0 ? 'owe' : 'gave';
    } else {
      return data.amount < 0 ? 'gave' : 'owe';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMe = data.createdBy.id == loggedInUser.id;
    final direction = calculateDirection(isMe);
    final bgColor =
        data.hasData
            ? (direction == 'gave'
                ? Colors.green.shade100
                : Colors.red.shade100)
            : Colors.white;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
        onLongPress: () {
          if (data.createdBy.id == loggedInUser.id) {
            context.push(
              "${RouterConstants.lendenRouteName}/$lendenID${RouterConstants.lendenEditExpenseRouteName}",
              extra: TransactionModel.fromLendenTransactionModel(data),
            );
          }
        },
        hoverColor:
            data.createdBy.id == loggedInUser.id ? null : Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: _borderRadius(isMe),
            border: Border.all(color: data.hasData ? bgColor : Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              data.hasData
                  ? Text(
                    '${direction == 'gave' ? 'You gave' : 'You owe'} ${formatCurrency(data.amount.abs(), context)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                  : CustomShimmerEffect.textWidget(width: 90),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child:
                    data.hasData
                        ? Text(data.description, style: TextStyle(fontSize: 13))
                        : CustomShimmerEffect.textWidget(width: 50),
              ),
              SizedBox(height: 6),
              subTextOnCard(
                'Created: ${convertDateTimeFormat(data.createdOn)}',
                fontSize: 11,
                textColor: Colors.grey.shade700,
                isLoaded: data.hasData,
              ),
              data.createdOn != data.modifiedOn
                  ? subTextOnCard(
                    'Updated: ${convertDateTimeFormat(data.modifiedOn)}',
                    fontSize: 11,
                    textColor: Colors.grey.shade700,
                    isLoaded: data.hasData,
                  )
                  : subTextOnCard(""),
            ],
          ),
        ),
      ),
    );
  }
}
