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
  final PreferenceModel preferenceData;

  AuthLoginSuccess(this.userData, this.preferenceData);
}

final class AuthSignUpLoading extends AuthState {}

final class AuthSignUpFailure extends AuthState {
  final String error;

  AuthSignUpFailure(this.error);
}

final class AuthSignUpSuccess extends AuthState {
  final bool isSuccess;
  AuthSignUpSuccess({required this.isSuccess});
}

final class AuthOTPSendSuccess extends AuthState {
  final bool isSuccess;
  AuthOTPSendSuccess(this.isSuccess);
}

final class AuthOTPSendFailure extends AuthState {
  final String error;

  AuthOTPSendFailure(this.error);
}

final class AuthOTPSendLoading extends AuthState {}

final class AuthLogoutLoading extends AuthLoginSuccess {
  AuthLogoutLoading(super.userData, super.preferenceData);
}

final class AuthLogoutFailure extends AuthLoginSuccess {
  final String error;

  AuthLogoutFailure(super.userData, super.preferenceData, this.error);
}

final class AuthProfileUpdateSuccess extends AuthState {
  final UserModel userData;

  AuthProfileUpdateSuccess(this.userData);
}
