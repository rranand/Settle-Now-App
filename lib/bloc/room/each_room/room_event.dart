part of 'room_bloc.dart';

@immutable
sealed class RoomEvent {}

class RoomFetch extends RoomEvent {
  final String id;
  final bool isFreshFetch;

  RoomFetch({required this.id, required this.isFreshFetch});
}

final class RoomAddNewTransaction extends RoomEvent {
  final List<RoomTransactionModel> data;

  RoomAddNewTransaction({required this.data});
}

final class RoomUpdateTransaction extends RoomEvent {
  final RoomTransactionModel data;

  RoomUpdateTransaction({required this.data});
}

final class RoomDeleteTransaction extends RoomEvent {
  final String expenseID;

  RoomDeleteTransaction({required this.expenseID});
}

final class RoomBlocReset extends RoomEvent {
  RoomBlocReset();
}

final class RoomAddToPersonalExpense extends RoomEvent {
  final String id;
  final String expenseID;
  final String personalExpenseID;

  RoomAddToPersonalExpense({
    required this.id,
    required this.expenseID,
    required this.personalExpenseID,
  });
}
