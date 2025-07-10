import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/user/user_update_profile/user_update_profile_cubit.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/loading_card.dart';
import 'package:settlenow_v2/util/enum/enums.dart';
import 'package:settlenow_v2/util/functions/validator.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  static final GlobalKey<FormState> _profileEditFormKey =
      GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();
  final TextEditingController _email = TextEditingController();
  UserModel _loggedInUser = UserModel.empty();

  void _blocListenerHandler(
    BuildContext context,
    UserUpdateProfileState state,
  ) {
    if (state.error != null) {
      showNormalSnackBar(context, state.error!);
    }
    if (state.isUpdated == true) {
      context.pop();
    }
  }

  void _onSubmitEditForm() {
    if (_profileEditFormKey.currentState!.validate()) {
      UserModel newData = UserModel.copyFromUser(_loggedInUser);
      newData.name = _name.text;
      newData.phoneNo = _mobileNumber.text;
      context.read<UserUpdateProfileCubit>().updateProfile(newData);
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
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
      _name.text = _loggedInUser.name;
      _mobileNumber.text = _loggedInUser.phoneNo;
      _email.text = _loggedInUser.email;
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
      body: BlocConsumer<UserUpdateProfileCubit, UserUpdateProfileState>(
        listener: _blocListenerHandler,
        builder: (context, state) {
          if (state.isLoading) {
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
                    [_loggedInUser],
                    1,
                    imageRadius: 140,
                  ),
                  SizedBox(height: 2 * UiConstant.spaceBetweenSection),
                  CustomFormField.textFormField(
                    _name,
                    autofillHints: [AutofillHints.name],
                    hintText: 'Name',
                    labelText: 'Name',
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
                    labelText: 'Phone No',
                    validator: CustomValidator.validatePhoneNo,
                    inputDecoration: TextFormFieldInputBorder.underLine,
                    borderColor: Colors.black87,
                    maxLength: 10,
                  ),
                  SizedBox(height: UiConstant.spaceBetweenSection),
                  CustomFormField.textFormField(
                    _email,
                    hintText: 'Email',
                    labelText: 'Email',
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
