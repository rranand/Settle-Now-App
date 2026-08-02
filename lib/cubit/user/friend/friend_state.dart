part of 'friend_cubit.dart';

@immutable
sealed class FriendState {}

final class FriendInitial extends FriendState {}

final class FriendLoading extends FriendState {}

final class FriendSuccess extends FriendState {
  final List<FriendUserModel> data;

  FriendSuccess({required this.data});
}

final class FriendFailure extends FriendState {
  final String error;

  FriendFailure({required this.error});
}
