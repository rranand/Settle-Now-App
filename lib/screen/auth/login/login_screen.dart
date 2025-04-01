import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/functions/validator.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/screen_size.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO : Add Resend Timer OTP functionality

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final ValueNotifier<bool> isOTPSent = ValueNotifier(false);
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailFormKey = GlobalKey<FormState>();
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  void _handleLoginSubmit() {
    if (isOTPSent.value) {
      if (_loginFormKey.currentState!.validate()) {}
    } else {
      if (_loginEmailFormKey.currentState!.validate()) {
        isOTPSent.value = true;
      }
    }
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
        actions: [
          CustomButton.customTextButton("Sign Up"),
          SizedBox(width: _mainScreenPadding.left),
        ],
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        padding: _mainScreenPadding,
        child: SizedBox(
          height: getScreenHeightWithoutAppBar(context),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: UiConstant.spaceBetweenSection),
                    const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
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
                                  emailController,
                                  autofillHints: [AutofillHints.email],
                                  hintText: 'Email',
                                  labelText: 'Your Email',
                                  validator: CustomValidator.validateEmail,
                                  inputDecoration:
                                      TextFormFieldInputBorder.underLine,
                                ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: isOTPSent,
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
                              child: CustomFormField.textFormField(
                                otpController,
                                textInputType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                readOnly: true,
                                hintText: 'OTP',
                                labelText: 'Enter OTP',
                                validator: CustomValidator.validateOTP,
                                inputDecoration:
                                    TextFormFieldInputBorder.underLine,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2 * UiConstant.spaceBetweenSection),
                    CustomButton.customElevatedButton(
                      "Send OTP",
                      onPressed: _handleLoginSubmit,
                      elevation: 8,
                      buttonHeight: 50,
                      borderRadius: 100,
                      borderColor: Colors.black87,
                      backgroundColor: Colors.black87,
                    ),
                    SizedBox(height: 2 * UiConstant.spaceBetweenSection),
                    const Center(child: Text('Or sign up with social account')),
                    SizedBox(height: 2 * UiConstant.spaceBetweenSection),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton.customOutlinedButton(
                          "Google",
                          onPressed: () {},
                          buttonHeight: 50,
                          buttonWidth: 175,
                          buttonTextSize: 16,
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Image.asset(
                              'assets/socialmedia/google.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 2 * UiConstant.spaceBetweenSection,
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'By signing in, You agree to the ',
                    children: [
                      TextSpan(
                        text: 'Terms of Use',
                        style: TextStyle(decoration: TextDecoration.underline),
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
                        style: TextStyle(decoration: TextDecoration.underline),
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
            ],
          ),
        ),
      ),
    );
  }
}
