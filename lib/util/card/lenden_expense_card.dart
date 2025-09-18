import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/constant/ui_constant.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/lenden_room_model.dart';
import 'package:settlenow/model/transaction_model.dart';
import 'package:settlenow/model/user_model.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/functions/additional_function.dart';
import 'package:settlenow/util/functions/text_function.dart';
import 'package:settlenow/util/widgets/shimmer_effect.dart';
import 'package:settlenow/util/widgets/widgets.dart';

class LendenExpenseCard extends StatelessWidget {
  final String lendenID;
  final LendenTransactionModel data;
  final UserModel loggedInUser;
  final bool isEditable;

  const LendenExpenseCard({
    super.key,
    required this.lendenID,
    required this.data,
    required this.loggedInUser,
    required this.isEditable,
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
                ? Colors.green.shade300
                : Colors.red.shade300)
            : Colors.white;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
        onTap: () {
          if (data.createdBy.id == loggedInUser.id && isEditable) {
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                  : CustomShimmerEffect.textWidget(context, width: 90),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child:
                    data.hasData
                        ? Text(
                          data.description,
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        )
                        : CustomShimmerEffect.textWidget(context, width: 50),
              ),
              SizedBox(height: 6),
              subTextOnCard(
                'Created: ${convertDateTimeFormat(data.createdOn)}',
                context,
                fontSize: 11,
                textColor: Colors.white,
                isLoaded: data.hasData,
              ),
              isDateTimeSame(data.createdOn, data.modifiedOn)
                  ? subTextOnCard("", context)
                  : subTextOnCard(
                    'Updated: ${convertDateTimeFormat(data.modifiedOn)}',
                    context,
                    fontSize: 11,
                    textColor: Colors.white,
                    isLoaded: data.hasData,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
