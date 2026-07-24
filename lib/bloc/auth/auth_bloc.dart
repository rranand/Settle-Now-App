import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:settlenow/constant/api_constant.dart';
import 'package:settlenow/data/repository/auth_repository.dart';
import 'package:settlenow/model/preference_model.dart';
import 'package:settlenow/model/user_model.dart';
import 'package:settlenow/util/custom/pair.dart';
import 'package:settlenow/util/handler/local_storage_preference.dart';
import 'package:settlenow/util/oAuth/google_oauth.dart';
import 'package:settlenow/util/token_manager/auth_event_bus.dart';
import 'package:settlenow/util/token_manager/session_manager.dart';
import 'package:settlenow/util/widgets/shimmer_effect.dart';
import 'package:settlenow/util/widgets/snackbar.dart';
import 'package:settlenow/util/widgets/widgets.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    AuthEventBus.instance.stream.listen((event) {
      if (event == AuthEventEnum.sessionExpired) {
        add(AuthRevokeSessionRequested());
      }
    });
    on<AuthLoginRequested>(_authLoginRequested);
    on<AuthGoogleSignInRequested>(_authGoogleSignInRequested);
    on<AuthWebGoogleSignInRequested>(_authWebGoogleSignInRequested);
    on<AuthSignUpRequested>(_authSignUpRequested);
    on<AuthGoogleSignUpRequested>(_authGoogleSignUpRequested);
    on<AuthWebGoogleSignUpRequested>(_authWebGoogleSignUpRequested);
    on<AuthOTPRequested>(_authOTPRequested);
    on<AuthLogoutRequested>(_authLogoutRequested);
    on<AuthRevokeSessionRequested>(_authRevokeSessionRequested);
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
      Pair<UserModel, PreferenceModel> pairData = await repo.loginUser(
        event.email,
        event.otp,
      );
      return emit(AuthLoginSuccess(pairData.first, pairData.second));
    } catch (e) {
      return emit(AuthLoginFailure(e.toString()));
    }
  }

  void _authWebGoogleSignInRequested(
    AuthWebGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    final ev = event.authEvent;

    if (ev is GoogleSignInAuthenticationEventSignIn) {
      emit(AuthLoginLoading());

      try {
        GoogleSignInAccount userData = ev.user;

        final GoogleSignInAuthentication googleAuth = userData.authentication;
        final String email = userData.email;
        final String idToken = googleAuth.idToken ?? "";

        if (idToken.isEmpty) {
          await additionalLogoutAction();
          return emit(AuthLoginFailure("Google SignIn Failed"));
        }

        Pair<UserModel, PreferenceModel> pairData = await repo.loginUsingGoogle(
          email,
          idToken,
        );
        return emit(AuthLoginSuccess(pairData.first, pairData.second));
      } on GoogleSignInException catch (e) {
        String errMsg = "Google SignIn Failed";
        if (e.code == GoogleSignInExceptionCode.canceled) {
          errMsg = "Google SignIn : Cancelled By User";
        }
        await additionalLogoutAction();
        return emit(AuthSignUpFailure(errMsg));
      } catch (e) {
        await additionalLogoutAction();
        return emit(AuthLoginFailure(e.toString()));
      }
    }
  }

  void _authGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoginLoading());

    try {
      GoogleSignInAccount userData = await GoogleOauth.login();

      final GoogleSignInAuthentication googleAuth = userData.authentication;
      final String email = userData.email;
      final String idToken = googleAuth.idToken ?? "";

      if (idToken.isEmpty) {
        await additionalLogoutAction();
        return emit(AuthLoginFailure("Google SignIn Failed"));
      }

      Pair<UserModel, PreferenceModel> pairData = await repo.loginUsingGoogle(
        email,
        idToken,
      );
      return emit(AuthLoginSuccess(pairData.first, pairData.second));
    } on GoogleSignInException catch (e) {
      String errMsg = "Google SignIn Failed";
      if (e.code == GoogleSignInExceptionCode.canceled) {
        errMsg = "Google SignIn : Cancelled By User";
      }
      await additionalLogoutAction();
      return emit(AuthSignUpFailure(errMsg));
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
      await repo.signUpUser(event.name, event.email);
      return emit(AuthSignUpSuccess(isSuccess: true));
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
      final GoogleSignInAuthentication googleAuth = userData.authentication;
      final String email = userData.email;
      final String idToken = googleAuth.idToken ?? "";

      if (idToken.isEmpty) {
        await additionalLogoutAction();
        return emit(AuthSignUpFailure("Google SignUp Failed"));
      }
      Pair<UserModel, PreferenceModel> pairData = await repo.signupUsingGoogle(
        email,
        idToken,
      );
      return emit(AuthLoginSuccess(pairData.first, pairData.second));
    } on GoogleSignInException catch (e) {
      String errMsg = "Google SignUp Failed";
      if (e.code == GoogleSignInExceptionCode.canceled) {
        errMsg = "Google SignUp : Cancelled By User";
      }
      await additionalLogoutAction();
      return emit(AuthSignUpFailure(errMsg));
    } catch (e) {
      await additionalLogoutAction();
      return emit(AuthSignUpFailure(e.toString()));
    }
  }

  void _authWebGoogleSignUpRequested(
    AuthWebGoogleSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    final ev = event.authEvent;

    if (ev is GoogleSignInAuthenticationEventSignIn) {
      emit(AuthLoginLoading());

      try {
        GoogleSignInAccount userData = ev.user;

        final GoogleSignInAuthentication googleAuth = userData.authentication;
        final String email = userData.email;
        final String idToken = googleAuth.idToken ?? "";

        if (idToken.isEmpty) {
          await additionalLogoutAction();
          return emit(AuthSignUpFailure("Google Signup Failed"));
        }
        Pair<UserModel, PreferenceModel> pairData = await repo
            .signupUsingGoogle(email, idToken);
        return emit(AuthLoginSuccess(pairData.first, pairData.second));
      } on GoogleSignInException catch (e) {
        String errMsg = "Google SignUp Failed";
        if (e.code == GoogleSignInExceptionCode.canceled) {
          errMsg = "Google SignUp : Cancelled By User";
        }
        await additionalLogoutAction();
        return emit(AuthSignUpFailure(errMsg));
      } catch (e) {
        await additionalLogoutAction();
        return emit(AuthSignUpFailure(e.toString()));
      }
    }
  }

  void _authOTPRequested(
    AuthOTPRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthOTPSendLoading());
    try {
      await repo.sendOTP(event.email);
      return emit(AuthOTPSendSuccess(true));
    } catch (e) {
      emit(AuthOTPSendFailure(e.toString()));
      return emit(AuthOTPSendSuccess(false));
    }
  }

  void _authSignupOTPRequested(
    AuthSignupOTPRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthOTPSendLoading());
    try {
      await repo.sendSignupOTP();
      emit(AuthOTPSendSuccess(true));
      return emit(AuthSignUpSuccess(isSuccess: true));
    } catch (e) {
      emit(AuthOTPSendFailure(e.toString()));
      return emit(AuthSignUpSuccess(isSuccess: false));
    }
  }

  void _authSignupOTPValidationRequested(
    AuthSignupOTPValidationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthOTPSendLoading());
    try {
      Pair<UserModel, PreferenceModel> pairData = await repo.validateSignupOTP(
        event.otp,
      );
      return emit(AuthLoginSuccess(pairData.first, pairData.second));
    } catch (e) {
      emit(AuthOTPSendFailure(e.toString()));
      return emit(AuthSignUpSuccess(isSuccess: false));
    }
  }

  void _authLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthLoginSuccess) {
      return emit(
        AuthLogoutFailure(
          UserModel.empty(),
          PreferenceModel.empty(),
          "Invalid Logout Request",
        ),
      );
    }

    final userData = (state as AuthLoginSuccess).userData;
    final preferenceData = (state as AuthLoginSuccess).preferenceData;

    emit(AuthLogoutLoading(userData, preferenceData));

    try {
      await Future.wait([repo.logoutUser(), additionalLogoutAction()]);

      return emit(AuthInitial());
    } catch (e) {
      emit(AuthLogoutFailure(userData, preferenceData, e.toString()));
      return emit(AuthLoginSuccess(userData, preferenceData));
    }
  }

  void _authProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) {
    return emit(AuthLoginSuccess(event.userData, event.preferenceData));
  }

  void _authProfileDeleteRequested(
    AuthProfileDeleteRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthLoginSuccess) {
      return emit(
        AuthLogoutFailure(
          UserModel.empty(),
          PreferenceModel.empty(),
          "Invalid Logout Request",
        ),
      );
    }
    showSnackbarWithChildWidget(
      "Requesting Account Delete",
      child: CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
      duration: Duration(minutes: 2),
      scaffoldMessenger: event.scaffoldMessenger,
    );
    final userData = (state as AuthLoginSuccess).userData;
    final preferenceData = (state as AuthLoginSuccess).preferenceData;
    emit(AuthLogoutLoading(userData, preferenceData));

    try {
      await repo.deleteAccount();
      event.scaffoldMessenger.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        "Account Delete Requested",
        child: snackbarSuccessIcon(),
        scaffoldMessenger: event.scaffoldMessenger,
      );
    } catch (e) {
      emit(AuthLogoutFailure(userData, preferenceData, e.toString()));
    }
    return emit(AuthLoginSuccess(userData, preferenceData));
  }

  void _authLoggedInUserRequested(
    AuthLoggedInUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoginLoading());
    try {
      Pair<UserModel, PreferenceModel> data = await repo.getLoggedInUser();
      UserModel userData = data.first;
      PreferenceModel preferenceData = data.second;

      if (userData.hasData) {
        return emit(AuthLoginSuccess(userData, preferenceData));
      } else {
        return emit(AuthInitial());
      }
    } catch (e) {
      if (e.toString() == ApiConstant.sessionExpired) {
        try {
          await additionalLogoutAction();
        } catch (_) {}
        return emit(AuthInitial());
      } else {
        return emit(AuthLoginFailure(e.toString()));
      }
    }
  }

  void _authRevokeSessionRequested(
    AuthRevokeSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await additionalLogoutAction();
    } catch (_) {}
    return emit(AuthInitial());
  }

  Future<void> additionalLogoutAction() async {
    try {
      List<Future<void>> futures = [
        SessionManager.instance.revoke(),
        GoogleOauth.logout(),
        LocalStoragePreference.clearAllPreferences(),
      ];

      if (!kIsWeb) {
        futures.add(FirebaseMessaging.instance.deleteToken());
      }

      await Future.wait(futures);
    } catch (_) {}
  }
}
