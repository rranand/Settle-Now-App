part of 'quicksplit_bloc.dart';

@immutable
sealed class QuicksplitEvent {}

final class QuicksplitFetch extends QuicksplitEvent {
  final bool isFreshFetch;

  QuicksplitFetch({required this.isFreshFetch});
}

final class QuicksplitAddNewTransaction extends QuicksplitEvent {
  final QuicksplitTransactionModel data;

  QuicksplitAddNewTransaction(this.data);
}

final class QuicksplitUpdateTransaction extends QuicksplitEvent {
  final QuicksplitTransactionModel data;

  QuicksplitUpdateTransaction(this.data);
}

final class QuicksplitDeleteTransaction extends QuicksplitEvent {
  final String transactionID;

  QuicksplitDeleteTransaction(this.transactionID);
}

final class QuicksplitAddToPersonalExpense extends QuicksplitEvent {
  final String transactionID;

  QuicksplitAddToPersonalExpense(this.transactionID);
}

final class QuicksplitSettleRequest extends QuicksplitEvent {
  final String transactionID;
  final String uid;

  QuicksplitSettleRequest(this.transactionID, this.uid);
}

final class QuicksplitReset extends QuicksplitEvent {}
