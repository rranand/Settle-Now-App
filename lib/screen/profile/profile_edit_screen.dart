import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/util/util_core.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final GlobalKey<FormState> _profileEditFormKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();
  final TextEditingController _email = TextEditingController();
  UserModel _loggedInUser = UserModel.empty();
  PreferenceModel _preferenceData = PreferenceModel.empty();

  void _blocListenerHandler(
    BuildContext context,
    UserUpdateProfileState state,
  ) {
    if (state.error != null) {
      showNormalSnackBar(context, state.error!);
    }
    if (state.isUpdated == true) {
      showSnackbar(context, "Profile Updated");
      context.pop();
    }
  }

  void _onSubmitEditForm() {
    if (_profileEditFormKey.currentState!.validate()) {
      if (_name.text != _loggedInUser.name) {
        UserModel newData = _loggedInUser.copyWith(name: _name.text);
        context.read<UserUpdateProfileCubit>().updateProfile(
          newData,
          _preferenceData,
        );
      } else {
        showNormalSnackBar(context, "Nothing to update!");
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
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _preferenceData = authState.preferenceData;
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
                  Visibility(
                    visible: _mobileNumber.text.isNotEmpty,
                    child: SizedBox(height: UiConstant.spaceBetweenSection),
                  ),
                  Visibility(
                    visible: _mobileNumber.text.isNotEmpty,
                    child: CustomFormField.textFormField(
                      _mobileNumber,
                      textInputType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      hintText: 'Phone No',
                      labelText: 'Phone No',
                      readOnly: true,
                      validator: CustomValidator.validatePhoneNo,
                      inputDecoration: TextFormFieldInputBorder.underLine,
                      borderColor: Colors.black87,
                      maxLength: 10,
                    ),
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
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _name,
                    builder: (context, _, _) {
                      if (_name.text == _loggedInUser.name) {
                        return SizedBox.shrink();
                      }
                      return CustomButton.customElevatedButton(
                        "Save",
                        buttonHeight: 45,
                        buttonWidth: 120,
                        elevation: 4,
                        borderRadius: 100,
                        backgroundColor: Theme.of(context).primaryColor,
                        borderColor: Theme.of(context).primaryColor,
                        onPressed: _onSubmitEditForm,
                      );
                    },
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
