import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/functions/validator.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/timer_button.dart';
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
  final ValueNotifier<bool> isOTPSent = ValueNotifier(false);
  final _signupFormKey = GlobalKey<FormState>();
  final _subSignupFormKey = GlobalKey<FormState>();
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  void _handleSignUpSubmit() {
    if (isOTPSent.value) {
      if (_signupFormKey.currentState!.validate()) {}
    } else {
      if (_subSignupFormKey.currentState!.validate()) {
        isOTPSent.value = true;
        showSnackbar(context, "OTP Sent Successful");
      }
    }
  }

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
        actions: [
          CustomButton.customTextButton("Login", onPressed: _handleOnLogin),
          SizedBox(width: _mainScreenPadding.left),
        ],
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
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
                          inputDecoration: TextFormFieldInputBorder.underLine,
                        ),
                        SizedBox(height: UiConstant.spaceBetweenSection),
                        CustomFormField.textFormFieldWithAutoFillGroup(
                          _emailController,
                          autofillHints: [AutofillHints.email],
                          hintText: 'Email',
                          labelText: 'Your Email',
                          validator: CustomValidator.validateEmail,
                          inputDecoration: TextFormFieldInputBorder.underLine,
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: isOTPSent,
                    builder: (BuildContext context, bool value, Widget? child) {
                      return Visibility(visible: value, child: child as Widget);
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
                            inputDecoration: TextFormFieldInputBorder.underLine,
                            maxLength: 6,
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: TimerButton(onPressed: () {}),
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
              valueListenable: isOTPSent,
              builder: (BuildContext context, bool value, Widget? child) {
                return CustomButton.customElevatedButton(
                  value ? "Sign Up" : "Send OTP",
                  onPressed: _handleSignUpSubmit,
                  elevation: 8,
                  buttonHeight: 50,
                  borderRadius: 100,
                  borderColor: Colors.black87,
                  backgroundColor: Colors.black87,
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
                  onPressed: () {},
                ),
              ],
            ),

            SizedBox(height: 2 * UiConstant.spaceBetweenSection),
          ],
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
