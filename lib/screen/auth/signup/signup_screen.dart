import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/enum/enums.dart';
import 'package:settlenow_v2/util/functions/validator.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/timer_button.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final ValueNotifier<bool> _isOTPSent = ValueNotifier(false);
  final _signupFormKey = GlobalKey<FormState>();
  final _subSignupFormKey = GlobalKey<FormState>();
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  void _handleSignUpSubmit() {
    if (_isOTPSent.value) {
      if (_signupFormKey.currentState!.validate()) {
        context.read<AuthBloc>().add(
          AuthSignUpRequested(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _otpController.text.trim(),
          ),
        );
      }
    } else {
      if (_subSignupFormKey.currentState!.validate()) {
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
    return state is AuthSignUpLoading || state is AuthOTPSendLoading;
  }

  void _blocListenerHandler(BuildContext context, AuthState state) {
    if (state is! AuthInitial) {
      if (_isScreenLoading(state)) {
        loadingWidget(context);
      } else {
        context.pop();
        if (state is AuthOTPSendFailure) {
          showNormalSnackBar(context, state.error);
        } else if (state is AuthSignUpFailure) {
          showNormalSnackBar(context, state.error);
        } else if (state is AuthOTPSendSuccess) {
          if (_isOTPSent.value == false) {
            _isOTPSent.value = true;
          }
        } else if (state is AuthSignUpSuccess) {
          context.go(RouterConstants.dashboardRouteName);
        }
      }
    }
  }

  void _googleSignUpHandler() {}

  void _handleOnLogin() {
    context.go(RouterConstants.loginRouteName);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: _mainScreenPadding.left,
        actions: appBarActionButton(context, [
          CustomButton.customTextButton(
            "Login",
            onPressed: _handleOnLogin,
            buttonTextColor: Colors.black,
          ),
        ]),
        forceMaterialTransparency: true,
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            return;
          }
          SystemNavigator.pop();
        },
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: _blocListenerHandler,
          builder: (context, state) {
            return SingleChildScrollView(
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
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: UiConstant.spaceBetweenSection),
                  const Text(
                    'Welcome !',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: UiConstant.spaceBetweenSection),
                  const Text(
                    'Sign Up to contiue',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2 * UiConstant.spaceBetweenSection),
                  Form(
                    key: _signupFormKey,
                    child: Column(
                      children: [
                        Form(
                          key: _subSignupFormKey,
                          child: Column(
                            children: [
                              CustomFormField.textFormFieldWithAutoFillGroup(
                                _nameController,
                                autofillHints: [AutofillHints.name],
                                hintText: 'Name',
                                labelText: 'Your Name',
                                validator: CustomValidator.validateName,
                                inputDecoration:
                                    TextFormFieldInputBorder.underLine,
                                borderColor: Colors.black87,
                              ),
                              SizedBox(height: UiConstant.spaceBetweenSection),
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
                                validator: CustomValidator.validateEmail,
                                inputDecoration:
                                    TextFormFieldInputBorder.underLine,
                                borderColor: Colors.black87,
                              ),
                            ],
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
                              child: child as Widget,
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
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  hintText: 'OTP',
                                  labelText: 'Enter OTP',
                                  validator: CustomValidator.validateOTP,
                                  inputDecoration:
                                      TextFormFieldInputBorder.underLine,
                                  borderColor: Colors.black87,
                                  maxLength: 6,
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child:
                                        state is AuthOTPSendSuccess
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
                    builder: (BuildContext context, bool value, Widget? child) {
                      return Center(
                        child: CustomButton.customElevatedButton(
                          value ? "Sign Up" : "Send OTP",
                          onPressed: _handleSignUpSubmit,
                          elevation: 8,
                          buttonHeight: 50,
                          buttonWidth: 155,
                          borderRadius: 100,
                          borderColor: Colors.black87,
                          backgroundColor: Colors.black87,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 2 * UiConstant.spaceBetweenSection),
                  const Center(child: Text('Or sign up with social account')),
                  SizedBox(height: 2 * UiConstant.spaceBetweenSection),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton.socialButton(
                        context,
                        'assets/socialmedia/google.png',
                        onPressed: _googleSignUpHandler,
                      ),
                    ],
                  ),

                  SizedBox(height: UiConstant.spaceAtBottom),
                ],
              ),
            );
          },
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
            text: 'By signing up, You agree to the ',
            children: [
              TextSpan(
                text: 'Terms of Use',
                style: TextStyle(decoration: TextDecoration.underline),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () async {
                        launchUrl(
                          Uri.parse("https://settlenow.in/privacy-policy"),
                          mode: LaunchMode.inAppWebView,
                          webViewConfiguration: const WebViewConfiguration(
                            enableJavaScript: true,
                          ),
                        );
                      },
              ),
              TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(decoration: TextDecoration.underline),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () async {
                        launchUrl(
                          Uri.parse("https://settlenow.in/privacy-policy"),
                          mode: LaunchMode.inAppWebView,
                          webViewConfiguration: const WebViewConfiguration(
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
  }
}
