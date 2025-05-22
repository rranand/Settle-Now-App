part of 'lenden_room_bloc.dart';

@immutable
sealed class LendenRoomEvent {}

final class LendenRoomFetch extends LendenRoomEvent {
  final String id;

  LendenRoomFetch({required this.id});
}

final class LendenAddNewTransaction extends LendenRoomEvent {
  final LendenRoomModel data;

  LendenAddNewTransaction(this.data);
}

final class LendenUpdateTransaction extends LendenRoomEvent {
  final LendenRoomModel data;

  LendenUpdateTransaction(this.data);
}

final class LendenDeleteTransaction extends LendenRoomEvent {
  final String expenseID;

  LendenDeleteTransaction(this.expenseID);
}
