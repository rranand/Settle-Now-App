part of 'lenden_room_bloc.dart';

@immutable
sealed class LendenRoomEvent {}

final class LendenRoomFetch extends LendenRoomEvent {
  final String id;

  LendenRoomFetch({required this.id});
}

final class LendenAddNewTransaction extends LendenRoomEvent {
  final LendenTransactionModel data;

  LendenAddNewTransaction({required this.data});
}

final class LendenCloseRoom extends LendenRoomEvent {
  final String uid;

  LendenCloseRoom({required this.uid});
}

final class LendenFetchTransaction extends LendenRoomEvent {}

final class LendenUpdateTransaction extends LendenRoomEvent {
  final LendenTransactionModel data;

  LendenUpdateTransaction({required this.data});
}

final class LendenDeleteTransaction extends LendenRoomEvent {
  final String expenseID;

  LendenDeleteTransaction({required this.expenseID});
}

final class LendenRoomReset extends LendenRoomEvent {}

final class LendenRoomUpdate extends LendenRoomEvent {
  final String roomName;
  final ScaffoldMessengerState scaffoldMessengerState;

  LendenRoomUpdate({
    required this.roomName,
    required this.scaffoldMessengerState,
  });
}

final class LendenRoomDelete extends LendenRoomEvent {
  final String id;
  final bool isRemoving;
  final ScaffoldMessengerState scaffoldMessengerState;

  LendenRoomDelete({
    required this.id,
    required this.isRemoving,
    required this.scaffoldMessengerState,
  });
}
