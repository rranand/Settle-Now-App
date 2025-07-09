import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:settlenow_v2/data/repository/auth_repository.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/oAuth/google_oauth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    on<AuthLoginRequested>(_authLoginRequested);
    on<AuthGoogleSignInRequested>(_authGoogleSignInRequested);
    on<AuthSignUpRequested>(_authSignUpRequested);
    on<AuthGoogleSignUpRequested>(_authGoogleSignUpRequested);
    on<AuthOTPRequested>(_authOTPRequested);
    on<AuthLogoutRequested>(_authLogoutRequested);
    on<AuthProfileUpdateRequested>(_authProfileUpdateRequested);
    on<AuthLoggedInUserRequested>(_authLoggedInUserRequested);
    on<AuthSignupOTPRequested>(_authSignupOTPRequested);
    on<AuthSignupOTPValidationRequested>(_authSignupOTPValidationRequested);
  }

  void _authLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoginLoading());

    try {
      UserModel userData = await repo.loginUser(event.email, event.otp);

      return emit(AuthLoginSuccess(userData));
    } catch (e) {
      return emit(AuthLoginFailure(e.toString()));
    }
  }

  void _authGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoginLoading());

    try {
      GoogleSignInAccount? userData = await GoogleOauth.login();
      if (userData == null) {
        return emit(AuthLoginFailure("Google SignIn Failed"));
      }
      final GoogleSignInAuthentication googleAuth =
          await userData.authentication;
      final String email = userData.email;
      final String idToken = googleAuth.idToken ?? "";

      if (idToken.isEmpty) {
        return emit(AuthLoginFailure("Google SignIn Failed"));
      }

      UserModel authUserData = await repo.loginUsingGoogle(email, idToken);

      return emit(AuthLoginSuccess(authUserData));
    } catch (e) {
      return emit(AuthLoginFailure(e.toString()));
    }
  }

  void _authSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthSignUpLoading());

    try {
      String signupToken = await repo.signUpUser(event.name, event.email);
      return emit(AuthSignUpSuccess(token: signupToken));
    } catch (e) {
      return emit(AuthSignUpFailure(e.toString()));
    }
  }

  void _authGoogleSignUpRequested(
    AuthGoogleSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {}

  void _authOTPRequested(
    AuthOTPRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthOTPSendLoading());
    try {
      await repo.sendOTP(event.email);
      return emit(AuthOTPSendSuccess());
    } catch (e) {
      emit(AuthOTPSendFailure(e.toString()));
      return emit(AuthOTPSendSuccess());
    }
  }

  void _authSignupOTPRequested(
    AuthSignupOTPRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthOTPSendLoading());
    try {
      await repo.sendSignupOTP(event.token);
      emit(AuthOTPSendSuccess());
      return emit(AuthSignUpSuccess(token: event.token));
    } catch (e) {
      emit(AuthOTPSendFailure(e.toString()));
      return emit(AuthSignUpSuccess(token: event.token));
    }
  }

  void _authSignupOTPValidationRequested(
    AuthSignupOTPValidationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthOTPSendLoading());
    try {
      UserModel userData = await repo.validateSignupOTP(event.token, event.otp);
      return emit(AuthLoginSuccess(userData));
    } catch (e) {
      emit(AuthOTPSendFailure(e.toString()));
      return emit(AuthSignUpSuccess(token: event.token));
    }
  }

  void _authLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthLoginSuccess) {
      return emit(
        AuthLogoutFailure(UserModel.empty(), "Invalid Logout Request"),
      );
    }

    final userData = (state as AuthLoginSuccess).userData;
    emit(AuthLogoutLoading(userData));
    try {
      bool isLogoutSuccessful = await repo.logoutUser(userData.authToken);
      if (userData.isGoogle) {
        await GoogleOauth.logout();
      }
      if (isLogoutSuccessful) {
        return emit(AuthInitial());
      } else {
        return emit(AuthLogoutFailure(userData, "Logout Failed"));
      }
    } catch (e) {
      return emit(AuthLogoutFailure(userData, e.toString()));
    }
  }

  void _authProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) {
    UserModel newUserData = UserModel.fromMap(event.userData.toMap());
    return emit(AuthLoginSuccess(newUserData));
  }

  void _authLoggedInUserRequested(
    AuthLoggedInUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoginLoading());
    try {
      UserModel userData = await repo.getLoggedInUser();
      if (userData.hasData) {
        return emit(AuthLoginSuccess(userData));
      } else {
        return emit(AuthInitial());
      }
    } catch (e) {
      return emit(AuthInitial());
    }
  }
}
