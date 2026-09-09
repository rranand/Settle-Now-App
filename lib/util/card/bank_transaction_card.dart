import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class BankTransactionCard extends StatelessWidget {
  final BankTransactionModel data;
  final VoidCallback? onTap;

  const BankTransactionCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = data.type == BankTransactionType.credit;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TransactionIcon(isCredit: isCredit),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCredit ? 'Received from' : 'Paid to',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),

                        const SizedBox(height: 3),

                        Text(
                          data.receiver,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          '${data.bank.label} • ${data.mode.label}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    '${isCredit ? '+' : '-'}₹${data.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),

              const SizedBox(height: 12),

              // Row(
              //   children: [
              //     Icon(
              //       Icons.schedule_outlined,
              //       size: 15,
              //       color: Theme.of(context).colorScheme.onSurfaceVariant,
              //     ),

              //     const SizedBox(width: 5),

              //     Text(
              //       DateFormat('dd MMM yyyy, h:mm a').format(data.date),
              //       style: Theme.of(context).textTheme.bodySmall,
              //     ),

              //     const Spacer(),

              //     _ConfidenceBadge(confidence: data.confidence),
              //   ],
              // ),

              // if (data.transactionID.isNotEmpty &&
              //     data.transactionID != 'Unknown') ...[
              //   const SizedBox(height: 8),

              //   Align(
              //     alignment: Alignment.centerLeft,
              //     child: Text(
              //       'Ref: ${data.transactionID}',
              //       maxLines: 1,
              //       overflow: TextOverflow.ellipsis,
              //       style: Theme.of(context).textTheme.labelSmall?.copyWith(
              //         color: Theme.of(context).colorScheme.onSurfaceVariant,
              //       ),
              //     ),
              //   ),
              // ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  final bool isCredit;

  const _TransactionIcon({required this.isCredit});

  @override
  Widget build(BuildContext context) {
    final color =
        isCredit ? Colors.green : Theme.of(context).colorScheme.primary;

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
