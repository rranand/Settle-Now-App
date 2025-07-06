part of 'quicksplit_bloc.dart';

@immutable
sealed class QuicksplitEvent {}

final class QuicksplitFetch extends QuicksplitEvent {
  final String authToken;

  QuicksplitFetch(this.authToken);
}

final class QuicksplitAddNewTransaction extends QuicksplitEvent {
  final TransactionModel data;

  QuicksplitAddNewTransaction(this.data);
}

final class QuicksplitUpdateTransaction extends QuicksplitEvent {
  final TransactionModel data;

  QuicksplitUpdateTransaction(this.data);
}

final class QuicksplitDeleteTransaction extends QuicksplitEvent {
  final String expenseID;

  QuicksplitDeleteTransaction(this.expenseID);
}

final class QuicksplitAddToPersonalExpense extends QuicksplitEvent {
  final String expenseID;

  QuicksplitAddToPersonalExpense(this.expenseID);
}
