part of 'user_login_activity_cubit.dart';

@immutable
sealed class UserLoginActivityState {}

final class UserLoginActivityInitial extends UserLoginActivityState {}

final class UserLoginActivityLoading extends UserLoginActivityState {}

final class UserLoginActivitySuccess extends UserLoginActivityState {
  final List<LoginActivityModel> data;

  UserLoginActivitySuccess(this.data);
}

final class UserLoginActivityFailure extends UserLoginActivityState {
  final String error;

  UserLoginActivityFailure(this.error);
}
