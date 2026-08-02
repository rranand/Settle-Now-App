part of 'room_bloc.dart';

@immutable
sealed class RoomEvent {}

class RoomFetch extends RoomEvent {
  final String id;
  final List<RoomUserModel> users;

  RoomFetch({required this.id, required this.users});
}

final class RoomAddNewTransaction extends RoomEvent {
  final List<RoomTransactionModel> data;

  RoomAddNewTransaction(this.data);
}

final class RoomUpdateTransaction extends RoomEvent {
  final RoomTransactionModel data;

  RoomUpdateTransaction(this.data);
}

final class RoomDeleteTransaction extends RoomEvent {
  final String expenseID;

  RoomDeleteTransaction(this.expenseID);
}

final class RoomBlocReset extends RoomEvent {
  RoomBlocReset();
}

final class RoomAddToPersonalExpense extends RoomEvent {
  final String id;
  final String expenseID;

  RoomAddToPersonalExpense(this.id, this.expenseID);
}
