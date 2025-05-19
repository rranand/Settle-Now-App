part of 'quicksplit_bloc.dart';

@immutable
sealed class QuicksplitEvent {}

final class QuicksplitFetch extends QuicksplitEvent {}

final class QuicksplitAddNewTransaction extends QuicksplitEvent {
  final TransactionModel data;

  QuicksplitAddNewTransaction(this.data);
}

final class QuicksplitUpdateTransaction extends QuicksplitEvent {
  final TransactionModel data;

  QuicksplitUpdateTransaction(this.data);
}