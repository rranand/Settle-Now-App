import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/loading_card.dart';
import 'package:settlenow_v2/util/functions/validator.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final _profileEditFormKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();
  final TextEditingController _email = TextEditingController();

  void _blocListenerHandler(BuildContext context, AuthState state) {}

  void _onSubmitEditForm() {
    if (_profileEditFormKey.currentState!.validate()) {}
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
        title: Text("Edit Profile"),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: _blocListenerHandler,
        builder: (context, state) {
          UserModel userData = UserModel.empty();
          if (state is AuthLoginSuccess) {
            userData = state.userData;
            _name.text = userData.name;
            _mobileNumber.text = userData.phoneNo;
            _email.text = userData.email;
          } else {
            return LoadingPage();
          }

          return SingleChildScrollView(
            padding: _mainScreenPadding.add(
              EdgeInsets.only(
                top: UiConstant.spaceBetweenSection,
                bottom: 2 * UiConstant.spaceBetweenSection,
              ),
            ),
            child: Form(
              key: _profileEditFormKey,
              child: Column(
                children: [
                  overlapUserImageWidget(
                    context,
                    [userData],
                    1,
                    imageRadius: 140,
                  ),
                  SizedBox(height: 2 * UiConstant.spaceBetweenSection),
                  CustomFormField.textFormField(
                    _name,
                    autofillHints: [AutofillHints.name],
                    hintText: 'Name',
                    labelText: 'Your Name',
                    validator: CustomValidator.validateName,
                    inputDecoration: TextFormFieldInputBorder.underLine,
                    borderColor: Colors.black87,
                  ),
                  SizedBox(height: UiConstant.spaceBetweenSection),
                  CustomFormField.textFormField(
                    _mobileNumber,
                    textInputType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    hintText: 'Phone No',
                    labelText: 'Enter Phone No',
                    validator: CustomValidator.validatePhoneNo,
                    inputDecoration: TextFormFieldInputBorder.underLine,
                    borderColor: Colors.black87,
                    maxLength: 10,
                  ),
                  SizedBox(height: UiConstant.spaceBetweenSection),
                  CustomFormField.textFormField(
                    _email,
                    hintText: 'Email',
                    labelText: '',
                    readOnly: true,
                    validator: CustomValidator.validateEmail,
                    inputDecoration: TextFormFieldInputBorder.underLine,
                    borderColor: Colors.black87,
                    maxLength: 10,
                  ),
                  SizedBox(height: UiConstant.spaceBetweenSection),
                  CustomButton.customElevatedButton(
                    "Save",
                    buttonHeight: 45,
                    buttonWidth: 120,
                    elevation: 4,
                    borderRadius: 100,
                    backgroundColor: Colors.deepPurple.shade500,
                    borderColor: Colors.deepPurple.shade500,
                    onPressed: _onSubmitEditForm,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
