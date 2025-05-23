part of 'room_bloc.dart';

@immutable
sealed class RoomEvent {}

class RoomFetch extends RoomEvent {
  final String id;

  RoomFetch(this.id);
}

final class RoomAddNewTransaction extends RoomEvent {
  final TransactionModel data;

  RoomAddNewTransaction(this.data);
}

final class RoomUpdateTransaction extends RoomEvent {
  final TransactionModel data;

  RoomUpdateTransaction(this.data);
}

final class RoomDeleteTransaction extends RoomEvent {
  final String expenseID;

  RoomDeleteTransaction(this.expenseID);
}
