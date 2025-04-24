import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
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
  final TextEditingController _name = TextEditingController(
    text: "Rohit Anand",
  );
  final TextEditingController _mobileNumber = TextEditingController(
    text: "1234567890",
  );

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
      body: SingleChildScrollView(
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
                [UiConstant.users.first],
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
      ),
    );
  }
}
