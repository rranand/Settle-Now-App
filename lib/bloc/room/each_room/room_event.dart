part of 'room_bloc.dart';

@immutable
sealed class RoomEvent {}

class RoomFetch extends RoomEvent {
  final String id;
  final String authToken;
  final List<RoomUserModel> users;

  RoomFetch({required this.id, required this.authToken, required this.users});
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

final class RoomBlocReset extends RoomEvent {
  RoomBlocReset();
}
