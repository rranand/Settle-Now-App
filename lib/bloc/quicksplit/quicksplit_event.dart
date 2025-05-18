part of 'quicksplit_bloc.dart';

@immutable
sealed class QuicksplitEvent {}

final class QuicksplitFetch extends QuicksplitEvent {}

final class QuicksplitAddNewTransaction extends QuicksplitEvent {
  final TransactionModel data;

  QuicksplitAddNewTransaction(this.data);
}
