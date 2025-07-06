part of 'add_to_personal_expense_bloc.dart';

@immutable
sealed class AddToPersonalExpenseEvent {}

class AddToPersonalExpenseRequested extends AddToPersonalExpenseEvent {
  final TransactionType transactionType;
  final String roomID;
  final String transactionID;
  final String authToken;

  AddToPersonalExpenseRequested({
    required this.transactionType,
    required this.transactionID,
    required this.authToken,
    this.roomID = "",
  });
}
