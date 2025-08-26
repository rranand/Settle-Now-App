import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/update_info/update_info_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/firebase/firebase_remote.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/card/loading_card.dart';
import 'package:settlenow_v2/util/enum/enums.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/functions/in_app_update_service.dart';
import 'package:settlenow_v2/util/functions/validator.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/timer_button.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final ValueNotifier<bool> _isOTPSent = ValueNotifier(false);

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _loginEmailFormKey = GlobalKey<FormState>();
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  ValueNotifier<bool> isNotificationAllowed = ValueNotifier(false);

  void populateData() async {
    if (kIsWeb) {
      isNotificationAllowed.value = true;
    } else {
      isNotificationAllowed.value =
          await AwesomeNotifications().isNotificationAllowed();
    }
  }

  void _handleLoginSubmit() {
    if (_isOTPSent.value) {
      if (_loginFormKey.currentState!.validate()) {
        context.read<AuthBloc>().add(
          AuthLoginRequested(
            _emailController.text.trim(),
            _otpController.text.trim(),
          ),
        );
      }
    } else {
      if (_loginEmailFormKey.currentState!.validate()) {
        context.read<AuthBloc>().add(
          AuthOTPRequested(_emailController.text.trim()),
        );
      }
    }
  }

  void _resendOTP() {
    context.read<AuthBloc>().add(
      AuthOTPRequested(_emailController.text.trim()),
    );
  }

  bool _isScreenLoading(AuthState state) {
    return state is AuthLoginLoading || state is AuthOTPSendLoading;
  }

  void _blocListenerHandler(BuildContext context, AuthState state) {
    if (state is AuthLoginSuccess) {
      context.go(RouterConstants.dashboardRouteName);
      if (!isNotificationAllowed.value) {
        context.push(RouterConstants.notificationPage);
      }
    } else if (state is AuthOTPSendFailure) {
      showNormalSnackBar(context, state.error);
    } else if (state is AuthLoginFailure) {
      showNormalSnackBar(context, state.error);
    } else if (state is AuthOTPSendSuccess) {
      if (_isOTPSent.value == false && state.isSuccess) {
        _isOTPSent.value = true;
      }
    }
  }

  void _googleLoginHandler() {
    context.read<AuthBloc>().add(AuthGoogleSignInRequested());
  }

  void _handleOnSignUp() {
    context.go(RouterConstants.signupRouteName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    populateData();
    InAppUpdateService.checkForUpdate(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseRemote>(
      builder: (context, firebaseRemote, _) {
        context.read<UpdateInfoBloc>().add(
          UpdateInfoFetchRequested(firebaseRemote),
        );
        return BlocConsumer<UpdateInfoBloc, UpdateInfoState>(
          listener: updateStateListener,
          builder: (context, state) {
            return BlocConsumer<AuthBloc, AuthState>(
              listener: _blocListenerHandler,
              builder: (context, state) {
                if (_isScreenLoading(state) || state is AuthLoginSuccess) {
                  return Scaffold(
                    appBar: AppBar(backgroundColor: Colors.transparent),
                    body: LoadingPage(),
                  );
                }
                return Scaffold(
                  appBar: AppBar(
                    titleSpacing: _mainScreenPadding.left,
                    actions: appBarActionButton(context, [
                      CustomButton.customTextButton(
                        "Sign Up",
                        onPressed: _handleOnSignUp,
                        buttonTextColor:
                            Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      SizedBox(width: _mainScreenPadding.left),
                    ]),
                    forceMaterialTransparency: true,
                  ),
                  body: PopScope(
                    canPop: false,
                    onPopInvokedWithResult: (
                      bool didPop,
                      Object? result,
                    ) async {
                      if (didPop) {
                        return;
                      }
                      SystemNavigator.pop();
                    },
                    child: SingleChildScrollView(
                      padding: _mainScreenPadding,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/sn/SN_WBG.png',
                              height: 150,
                              width: 150,
                            ),
                          ),
                          SizedBox(height: UiConstant.spaceBetweenSection),
                          const Text(
                            'Welcome Back !',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: UiConstant.spaceBetweenSection),
                          const Text(
                            'Sign In to Continue',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 2 * UiConstant.spaceBetweenSection),
                          Form(
                            key: _loginFormKey,
                            child: Column(
                              children: [
                                Form(
                                  key: _loginEmailFormKey,
                                  child:
                                      CustomFormField.textFormFieldWithAutoFillGroup(
                                        _emailController,
                                        autofillHints: [AutofillHints.email],
                                        hintText: 'Email',
                                        labelText: 'Your Email',
                                        onChanged: (value) {
                                          if (_isOTPSent.value) {
                                            _isOTPSent.value = false;
                                          }
                                        },
                                        validator:
                                            CustomValidator.validateEmail,
                                        inputDecoration:
                                            TextFormFieldInputBorder.underLine,
                                        borderColor:
                                            Theme.of(context)
                                                .inputDecorationTheme
                                                .enabledBorder!
                                                .borderSide
                                                .color,
                                      ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: _isOTPSent,
                                  builder: (
                                    BuildContext context,
                                    bool value,
                                    Widget? child,
                                  ) {
                                    return Visibility(
                                      visible: value,
                                      child: child!,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: UiConstant.spaceBetweenSection,
                                    ),
                                    child: Column(
                                      children: [
                                        CustomFormField.textFormField(
                                          _otpController,
                                          textInputType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          hintText: 'OTP',
                                          labelText: 'Enter OTP',
                                          validator:
                                              CustomValidator.validateOTP,
                                          inputDecoration:
                                              TextFormFieldInputBorder
                                                  .underLine,
                                          borderColor:
                                              Theme.of(context)
                                                  .inputDecorationTheme
                                                  .enabledBorder!
                                                  .borderSide
                                                  .color,
                                          maxLength: 6,
                                        ),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child:
                                                (state is AuthOTPSendSuccess &&
                                                        state.isSuccess)
                                                    ? TimerButton(
                                                      onPressed: _resendOTP,
                                                      timerDuration: 5,
                                                    )
                                                    : SizedBox.shrink(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2 * UiConstant.spaceBetweenSection),
                          ValueListenableBuilder(
                            valueListenable: _isOTPSent,
                            builder: (
                              BuildContext context,
                              bool value,
                              Widget? child,
                            ) {
                              return Center(
                                child: CustomButton.customElevatedButton(
                                  value ? "Login" : "Send OTP",
                                  onPressed: _handleLoginSubmit,
                                  elevation: 8,
                                  buttonWidth: 155,
                                  buttonHeight: 50,
                                  borderRadius: 100,
                                ),
                              );
                            },
                          ),
                          if (!kIsWeb) ...<Widget>[
                            SizedBox(
                              height: 2 * UiConstant.spaceBetweenSection,
                            ),
                            const Center(
                              child: Text('Or Sign in with social account'),
                            ),
                            SizedBox(
                              height: 2 * UiConstant.spaceBetweenSection,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomButton.socialButton(
                                  context,
                                  'assets/socialmedia/google.png',
                                  onPressed: _googleLoginHandler,
                                ),
                              ],
                            ),
                          ],

                          SizedBox(height: UiConstant.spaceAtBottom),
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: Padding(
                    padding: EdgeInsets.only(
                      bottom: 2 * UiConstant.spaceBetweenSection,
                      left: _mainScreenPadding.left,
                      right: _mainScreenPadding.right,
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        text: 'By signing in, You agree to the ',
                        children: [
                          TextSpan(
                            text: 'Terms of Use',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () async {
                                    launchUrl(
                                      Uri.parse(
                                        "https://settlenow.in/privacy-policy",
                                      ),
                                      mode: LaunchMode.inAppWebView,
                                      webViewConfiguration:
                                          const WebViewConfiguration(
                                            enableJavaScript: true,
                                          ),
                                    );
                                  },
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () async {
                                    launchUrl(
                                      Uri.parse(
                                        "https://settlenow.in/privacy-policy",
                                      ),
                                      mode: LaunchMode.inAppWebView,
                                      webViewConfiguration:
                                          const WebViewConfiguration(
                                            enableJavaScript: true,
                                          ),
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
