part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String otp;

  AuthLoginRequested(this.email, this.otp);
}

final class AuthGoogleSignInRequested extends AuthEvent {}

final class AuthWebGoogleSignInRequested extends AuthEvent {
  final GoogleSignInAuthenticationEvent authEvent;

  AuthWebGoogleSignInRequested(this.authEvent);
}

final class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;

  AuthSignUpRequested(this.name, this.email);
}

final class AuthWebGoogleSignUpRequested extends AuthEvent {
  final GoogleSignInAuthenticationEvent authEvent;

  AuthWebGoogleSignUpRequested(this.authEvent);
}

final class AuthGoogleSignUpRequested extends AuthEvent {}

final class AuthOTPRequested extends AuthEvent {
  final String email;

  AuthOTPRequested(this.email);
}

final class AuthSignupOTPRequested extends AuthEvent {}

final class AuthSignupOTPValidationRequested extends AuthEvent {
  final String otp;

  AuthSignupOTPValidationRequested({required this.otp});
}

final class AuthLogoutRequested extends AuthEvent {}

final class AuthRevokeSessionRequested extends AuthEvent {}

final class AuthLoggedInUserRequested extends AuthEvent {}

final class AuthProfileUpdateRequested extends AuthEvent {
  final UserModel userData;
  final PreferenceModel preferenceData;

  AuthProfileUpdateRequested(this.userData, this.preferenceData);
}

final class AuthProfileDeleteRequested extends AuthEvent {
  final ScaffoldMessengerState scaffoldMessenger;

  AuthProfileDeleteRequested(this.scaffoldMessenger);
}
