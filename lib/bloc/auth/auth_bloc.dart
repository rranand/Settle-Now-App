import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow_v2/data/repository/auth_repository.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/handler/local_storage_preference.dart';
import 'package:settlenow_v2/util/oAuth/google_oauth.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';

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
    on<AuthProfileDeleteRequested>(_authProfileDeleteRequested);
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
        await additionalLogoutAction();
        return emit(AuthLoginFailure("Google SignIn Failed"));
      }

      UserModel authUserData = await repo.loginUsingGoogle(email, idToken);
      return emit(AuthLoginSuccess(authUserData));
    } catch (e) {
      await additionalLogoutAction();
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
  ) async {
    emit(AuthSignUpLoading());

    try {
      GoogleSignInAccount? userData = await GoogleOauth.login();
      if (userData == null) {
        return emit(AuthSignUpFailure("Google Signup Failed"));
      }
      final GoogleSignInAuthentication googleAuth =
          await userData.authentication;
      final String email = userData.email;
      final String idToken = googleAuth.idToken ?? "";

      if (idToken.isEmpty) {
        await additionalLogoutAction();
        return emit(AuthSignUpFailure("Google Signup Failed"));
      }
      UserModel authUserData = await repo.signupUsingGoogle(email, idToken);
      return emit(AuthLoginSuccess(authUserData));
    } catch (e) {
      await additionalLogoutAction();
      return emit(AuthSignUpFailure(e.toString()));
    }
  }

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
      await Future.wait([
        repo.logoutUser(userData.authToken),
        additionalLogoutAction(),
      ]);

      return emit(AuthInitial());
    } catch (e) {
      emit(AuthLogoutFailure(userData, e.toString()));
      return emit(AuthLoginSuccess(userData));
    }
  }

  void _authProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) {
    return emit(AuthLoginSuccess(event.userData));
  }

  void _authProfileDeleteRequested(
    AuthProfileDeleteRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthLoginSuccess) {
      return emit(
        AuthLogoutFailure(UserModel.empty(), "Invalid Logout Request"),
      );
    }
    showSnackbarWithChildWidget(
      "Requesting Account Delete",
      child: CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
      duration: Duration(minutes: 2),
      scaffoldMessenger: event.scaffoldMessenger,
    );
    final userData = (state as AuthLoginSuccess).userData;
    emit(AuthLogoutLoading(userData));

    try {
      await repo.deleteAccount(userData.authToken);
      event.scaffoldMessenger.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        "Account Delete Requested",
        child: Icon(Iconsax.tick_circle_copy, color: Colors.green),
        scaffoldMessenger: event.scaffoldMessenger,
      );
    } catch (e) {
      emit(AuthLogoutFailure(userData, e.toString()));
    }
    return emit(AuthLoginSuccess(userData));
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
      if (e.toString().toLowerCase() == "unauthorized access") {
        try {
          await additionalLogoutAction();
        } catch (_) {}
        return emit(AuthInitial());
      } else {
        return emit(AuthLoginFailure(e.toString()));
      }
    }
  }

  Future<void> additionalLogoutAction() async {
    try {
      await Future.wait([
        GoogleOauth.logout(),
        FirebaseMessaging.instance.deleteToken(),
        LocalStoragePreference.clearAllPreferences(),
      ]);
    } catch (_) {}
  }
}
