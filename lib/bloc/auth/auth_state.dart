part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoginLoading extends AuthState {}

final class AuthLoginFailure extends AuthState {
  final String error;

  AuthLoginFailure(this.error);
}

final class AuthLoginSuccess extends AuthState {
  final UserModel userData;

  AuthLoginSuccess(this.userData);
}

final class AuthSignUpLoading extends AuthState {}

final class AuthSignUpFailure extends AuthState {
  final String error;

  AuthSignUpFailure(this.error);
}

final class AuthSignUpSuccess extends AuthState {
  AuthSignUpSuccess();
}

final class AuthOTPSendSuccess extends AuthState {
  AuthOTPSendSuccess();
}

final class AuthOTPSendFailure extends AuthState {
  final String error;

  AuthOTPSendFailure(this.error);
}

final class AuthOTPSendLoading extends AuthState {}

final class AuthLogoutLoading extends AuthLoginSuccess {
  AuthLogoutLoading(super.userData);
}

final class AuthLogoutFailure extends AuthLoginSuccess {
  final String error;

  AuthLogoutFailure(super.userData, this.error);
}

final class AuthProfileUpdateSuccess extends AuthState {
  final UserModel userData;

  AuthProfileUpdateSuccess(this.userData);
}
