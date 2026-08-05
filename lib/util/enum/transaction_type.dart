import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/router/router_constant.dart';

enum TransactionType { quicksplit, lenden, room, personal }

extension TransactionTypeExtension on TransactionType {
  static TransactionType fromPath(BuildContext context) {
    String path =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();

    if (path.startsWith(RouterConstants.quickSplitAddExpenseRouteName) ||
        path.startsWith(RouterConstants.quickSplitEditExpenseRouteName)) {
      return TransactionType.quicksplit;
    } else if (path.startsWith(RouterConstants.personalExpenseRouteName)) {
      return TransactionType.personal;
    } else if (path.startsWith(RouterConstants.lendenRouteName)) {
      return TransactionType.lenden;
    }

    switch (path.toLowerCase()) {
      case 'quicksplit':
        return TransactionType.quicksplit;
      case 'lenden':
        return TransactionType.lenden;
      case 'personal':
        return TransactionType.personal;
      default:
        return TransactionType.room;
    }
  }

  String get label {
    switch (this) {
      case TransactionType.quicksplit:
        return 'quicksplit';
      case TransactionType.lenden:
        return 'lenden';
      case TransactionType.room:
        return 'room';
      default:
        return 'personal';
    }
  }

  static TransactionType fromString(String transactionType) {
    switch (transactionType.toLowerCase()) {
      case 'quicksplit':
        return TransactionType.quicksplit;
      case 'lenden':
        return TransactionType.lenden;
      case 'personal':
        return TransactionType.personal;
      default:
        return TransactionType.room;
    }
  }
}
