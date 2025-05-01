part of 'room_bloc.dart';

@immutable
sealed class RoomEvent {}

class RoomFetch extends RoomEvent {
  final String id;

  RoomFetch(this.id);
}
