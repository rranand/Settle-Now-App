import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/auth_repository.dart';
import 'package:settlenow_v2/model/user_model.dart';

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
  }

  void _authLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoginLoading());

    try {
      UserModel userData = await repo.getLoginToken(event.email, event.otp);

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
      UserModel authUserData = UserModel.empty();

      // GoogleSignInAccount? userData = await GoogleSignIN.login();
      // if (userData == null) {
      //   return emit(AuthLoginFailure("Google SignIn Failed"));
      // }

      // authUserData = UserModel.onLogin(
      //   username: userData.email,
      //   name: userData.displayName ?? userData.email.split('@')[0],
      //   profileImage: [userData.photoUrl ?? ""],
      // );

      // if (!authUserData.hasData) {
      //   return emit(AuthLoginFailure("Google SignIn Failed"));
      // }

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
      bool isSignUpSuccess = await repo.signUpUser(event.name, event.email);
      if (isSignUpSuccess) {
        return emit(AuthSignUpSuccess(isSignUpSuccess));
      } else {
        return emit(AuthSignUpFailure("SignUp Failed"));
      }
    } catch (e) {
      return emit(AuthSignUpFailure("Something Went Wrong!"));
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
      bool isOTPSend = await repo.sendOTP(event.email);
      if (isOTPSend) {
        return emit(AuthOTPSendSuccess());
      } else {
        return emit(AuthOTPSendFailure("Email Sent Failed"));
      }
    } catch (e) {
      return emit(AuthOTPSendFailure(e.toString()));
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
      bool isLogoutSuccessful = await repo.logoutUser(userData.email);
      // if (GoogleSignIN.getCurrentUser() != null) {
      //   await GoogleSignIN.logout();
      // } else if (await FacebookLogin.getAccessToken() != null) {
      //   await FacebookLogin.logout();
      // }
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
      return emit(AuthLoginSuccess(userData));
    } catch (e) {
      return emit(AuthInitial());
    }
  }
}
