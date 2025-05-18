part of 'quicksplit_new_transaction_cubit.dart';

@immutable
sealed class QuicksplitNewTransactionState {}

final class QuicksplitNewTransactionInitial
    extends QuicksplitNewTransactionState {}

final class QSNTransactionLoading extends QuicksplitNewTransactionState {}

final class QSNTransactionSuccess extends QuicksplitNewTransactionState {
  final TransactionModel data;

  QSNTransactionSuccess(this.data);
}

final class QSNTransactionFailure extends QuicksplitNewTransactionState {
  final String error;

  QSNTransactionFailure(this.error);
}
