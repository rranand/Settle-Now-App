part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String otp;

  AuthLoginRequested(this.email, this.otp);
}

final class AuthGoogleSignInRequested extends AuthEvent {}

final class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;

  AuthSignUpRequested(this.name, this.email);
}

final class AuthGoogleSignUpRequested extends AuthEvent {}

final class AuthOTPRequested extends AuthEvent {
  final String email;

  AuthOTPRequested(this.email);
}

final class AuthSignupOTPRequested extends AuthEvent {
  final String token;

  AuthSignupOTPRequested({required this.token});
}

final class AuthSignupOTPValidationRequested extends AuthEvent {
  final String token;
  final String otp;

  AuthSignupOTPValidationRequested({required this.token, required this.otp});
}

final class AuthLogoutRequested extends AuthEvent {}

final class AuthLoggedInUserRequested extends AuthEvent {}

final class AuthProfileUpdateRequested extends AuthEvent {
  final UserModel userData;

  AuthProfileUpdateRequested(this.userData);
}
