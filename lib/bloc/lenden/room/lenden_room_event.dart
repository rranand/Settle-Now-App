part of 'lenden_room_bloc.dart';

@immutable
sealed class LendenRoomEvent {}

final class LendenRoomFetch extends LendenRoomEvent {
  final String id;
  final String authToken;

  LendenRoomFetch({required this.id, required this.authToken});
}

final class LendenAddNewTransaction extends LendenRoomEvent {
  final LendenTransactionModel data;

  LendenAddNewTransaction(this.data);
}

final class LendenCloseRoom extends LendenRoomEvent {
  final String uid;
  final String authToken;

  LendenCloseRoom({required this.uid, required this.authToken});
}

final class LendenUpdateTransaction extends LendenRoomEvent {
  final LendenTransactionModel data;

  LendenUpdateTransaction(this.data);
}

final class LendenDeleteTransaction extends LendenRoomEvent {
  final String expenseID;

  LendenDeleteTransaction(this.expenseID);
}

final class LendenRoomReset extends LendenRoomEvent {}

final class LendenRoomUpdate extends LendenRoomEvent {
  final String roomName;
  final String authToken;
  final ScaffoldMessengerState scaffoldMessengerState;

  LendenRoomUpdate({
    required this.roomName,
    required this.authToken,
    required this.scaffoldMessengerState,
  });
}

final class LendenRoomDelete extends LendenRoomEvent {
  final String id;
  final String authToken;
  final bool isRemoving;
  final ScaffoldMessengerState scaffoldMessengerState;

  LendenRoomDelete({
    required this.id,
    required this.authToken,
    required this.isRemoving,
    required this.scaffoldMessengerState,
  });
}
