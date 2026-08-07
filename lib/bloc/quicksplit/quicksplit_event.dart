part of 'quicksplit_bloc.dart';

@immutable
sealed class QuicksplitEvent {}

final class QuicksplitFetch extends QuicksplitEvent {
  final bool isFreshFetch;

  QuicksplitFetch({required this.isFreshFetch});
}

final class QuicksplitAddNewTransaction extends QuicksplitEvent {
  final QuicksplitTransactionModel data;

  QuicksplitAddNewTransaction({required this.data});
}

final class QuicksplitUpdateTransaction extends QuicksplitEvent {
  final QuicksplitTransactionModel data;

  QuicksplitUpdateTransaction({required this.data});
}

final class QuicksplitDeleteTransaction extends QuicksplitEvent {
  final String transactionID;

  QuicksplitDeleteTransaction({required this.transactionID});
}

final class QuicksplitAddToPersonalExpense extends QuicksplitEvent {
  final String transactionID;
  final String personalExpenseID;

  QuicksplitAddToPersonalExpense({
    required this.transactionID,
    required this.personalExpenseID,
  });
}

final class QuicksplitSettleRequest extends QuicksplitEvent {
  final String transactionID;
  final String uid;

  QuicksplitSettleRequest({required this.transactionID, required this.uid});
}

final class QuicksplitReset extends QuicksplitEvent {}
