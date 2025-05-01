part of 'lenden_room_bloc.dart';

@immutable
sealed class LendenRoomEvent {}

final class LendenRoomFetch extends LendenRoomEvent {
  final String id;

  LendenRoomFetch({required this.id});
}
