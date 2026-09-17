import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class BankTransactionCard extends StatelessWidget {
  final BankTransactionModel data;
  final VoidCallback? onAddPressed;

  const BankTransactionCard({super.key, required this.data, this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCredit = data.type == BankTransactionType.credit;
    final isConsumed = data.transactionConsumed != null;

    final amountColor = isCredit ? Colors.green : Colors.red;

    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: UiConstant.cardPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
          boxShadow: getContainerBoxShadow(context),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  data.hasData
                      ? _TransactionIcon(isCredit: isCredit)
                      : CustomShimmerEffect.imageWidget(
                        context,
                        shape: BoxShape.circle,
                        radius: 50,
                      ),
              title:
                  data.hasData
                      ? Text(
                        data.receiver,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                      : CustomShimmerEffect.textWidget(context),
              subtitle:
                  data.hasData
                      ? Row(
                        children: [
                          subTextOnCard(
                            data.bank.label,
                            context,
                            fontSize: 14,
                            isLoaded: true,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 6),
                          subTextOnCard(
                            data.mode.label,
                            context,
                            fontSize: 14,
                            isLoaded: true,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 6),
                          subTextOnCard(
                            convertToMoment(data.date),
                            context,
                            fontSize: 14,
                            isLoaded: true,
                          ),
                        ],
                      )
                      : Align(
                        alignment: Alignment.centerLeft,
                        child: CustomShimmerEffect.textWidget(
                          context,
                          fontSize: 10,
                          width: 120,
                        ),
                      ),
              trailing:
                  data.hasData
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isCredit ? '+' : '-'}₹${data.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: amountColor,
                            ),
                          ),
                          _ConfidenceBadge(confidence: data.confidence),
                        ],
                      )
                      : CustomShimmerEffect.textWidget(
                        context,
                        fontSize: 16,
                        width: 50,
                      ),
            ),
            if (data.hasData) ...[
              const Divider(),
              !isConsumed
                  ? _buildConsumedRow(
                    context,
                    BankTransactionConsumedModel(
                      roomType: RoomType.room,
                      roomId: "dwada",
                      transactionId: null,
                      id: "iddd12",
                    ),
                  )
                  : CustomButton.customTextButton(
                    "Add to expense",
                    buttonTextColor: Theme.of(context).primaryColor,
                    onPressed: onAddPressed,
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConsumedRow(
    BuildContext context,
    BankTransactionConsumedModel consumed,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton.customTextButton(
          'Added to ${consumed.roomType.label}',
          buttonTextColor: Theme.of(context).primaryColor,
          onPressed: () {
            _navigateToConsumedEntity(context, consumed);
          },
        ),
        Icon(
          Icons.chevron_right,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  void _navigateToConsumedEntity(
    BuildContext context,
    BankTransactionConsumedModel consumed,
  ) {
    switch (consumed.roomType) {
      case RoomType.room:
        context.push('/room/${consumed.roomId}');
      case RoomType.lenden:
        context.push('/lenden/${consumed.roomId}');
      case RoomType.quicksplit:
        context.push('/quicksplit/${consumed.roomId}');
      case RoomType.personal:
        context.push('/personal-expense');
      case RoomType.none:
        break;
    }
  }
}

class _TransactionIcon extends StatelessWidget {
  final bool isCredit;

  const _TransactionIcon({required this.isCredit});

  @override
  Widget build(BuildContext context) {
    final color = isCredit ? Colors.green : Colors.red;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
        color: color,
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 13),
          const SizedBox(width: 4),
          Text(
            '$percentage%',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
