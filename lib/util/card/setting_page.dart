import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/room/lenden_room_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/room/room_info/room_info_cubit.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/enum/enums.dart';
import 'package:settlenow_v2/util/enum/transaction_type.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/functions/validator.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class SettingPage extends StatefulWidget {
  final String id;
  final TransactionType transactionType;
  const SettingPage({
    super.key,
    required this.id,
    required this.transactionType,
  });

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  UserModel _loggedInUser = UserModel.empty();
  final ValueNotifier<bool> _roomEditListener = ValueNotifier(false);
  final ValueNotifier<bool> _isNotificationEnabled = ValueNotifier(false);
  final GlobalKey<FormState> _roomUpdateFormKey = GlobalKey<FormState>();
  final TextEditingController _roomNameController = TextEditingController();
  late FocusNode focusNode;

  int totalMemberCount = 0;
  UserModel createdBy = UserModel.empty();
  DateTime createdOn = DateTime.now();
  String ogRoomName = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;

    if (mounted) {
      setState(() {});
    }
  }

  void roomUpdateHandler() {
    if (_roomUpdateFormKey.currentState!.validate()) {
      switch (widget.transactionType) {
        case (TransactionType.lenden):
          {
            context.read<LendenRoomBloc>().add(
              LendenRoomUpdate(
                roomName: _roomNameController.text,
                authToken: _loggedInUser.authToken,
                scaffoldMessengerState: ScaffoldMessenger.of(context),
              ),
            );
          }
        case (TransactionType.room):
          {
            context.read<RoomInfoCubit>().updateRoomName(
              _loggedInUser.authToken,
              _roomNameController.text,
              ScaffoldMessenger.of(context),
            );
          }
        default:
          {}
      }
    }
  }

  void populateData() {
    switch (widget.transactionType) {
      case (TransactionType.room):
        {
          final state = context.read<RoomInfoCubit>().state;
          if (state is RoomInfoSuccess) {
            _roomNameController.text = state.data.roomName;
            totalMemberCount = state.data.users.length;
            createdBy = state.data.createdBy;
            createdOn = state.data.createdOn;
            ogRoomName = state.data.roomName;
          }
        }
      case (TransactionType.lenden):
        {
          final state = context.read<LendenRoomBloc>().state;
          if (state is LendenRoomFetchSuccess) {
            _roomNameController.text = state.roomData.roomName;
            totalMemberCount = state.roomData.users.length;
            createdBy = state.roomData.createdBy;
            createdOn = state.roomData.createdOn;
            ogRoomName = state.roomData.roomName;
          }
        }
      default:
        {}
    }
  }

  List<Widget> bottomBarHandler() {
    List<Widget> widgetArr = [
      CustomButton.customElevatedButton(
        "Leave Room",
        buttonHeight: 45,
        backgroundColor: Colors.blueGrey.shade800,
      ),
    ];
    if (createdBy.id == _loggedInUser.id) {
      widgetArr.add(
        CustomButton.customElevatedButton(
          "Delete Room",
          buttonHeight: 45,
          backgroundColor: Colors.red,
        ),
      );
    }

    return widgetArr;
  }

  Widget infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget blankDivider() {
    double width =
        MediaQuery.of(context).size.width - 2 * _mainScreenPadding.left;
    width *= .4;
    Widget dd = SizedBox(
      width: width,
      child: Divider(color: Colors.transparent),
    );

    return Row(children: [dd, Expanded(child: Divider()), dd]);
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
      populateData();
    }
    focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
        actions: appBarActionButton(context, [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _roomNameController,
            builder: (context, _, _) {
              return Visibility(
                visible: _roomNameController.text != ogRoomName,
                child: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    roomUpdateHandler();
                  },
                ),
              );
            },
          ),
        ]),
      ),
      body: SingleChildScrollView(
        padding: _mainScreenPadding.add(
          EdgeInsets.only(bottom: UiConstant.spaceAtBottom),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Name",
                style: const TextStyle(fontSize: UiConstant.cardTitleTextSize),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ValueListenableBuilder(
                valueListenable: _roomEditListener,
                builder: (context, _, _) {
                  return _roomEditListener.value
                      ? Form(
                        key: _roomUpdateFormKey,
                        child: CustomFormField.textFormField(
                          _roomNameController,
                          hintText: "Name",
                          focusNode: focusNode,
                          validator: CustomValidator.validateRoomName,
                          inputDecoration:
                              TextFormFieldInputBorder.outlineInputBorder,
                          borderColor: Colors.black38,
                        ),
                      )
                      : CustomFormField.textFormField(
                        _roomNameController,
                        hintText: "Name",
                        validator: CustomValidator.validateRoomName,
                        readOnly: true,
                        inputDecoration:
                            TextFormFieldInputBorder.outlineInputBorder,
                        borderColor: Colors.black38,
                        suffixIcon: Icon(Iconsax.edit_2, size: 22),
                        onTap: () {
                          _roomEditListener.value = !_roomEditListener.value;
                          if (_roomEditListener.value) {
                            focusNode.requestFocus();
                          }
                        },
                      );
                },
              ),
            ),
            Visibility(
              visible: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: UiConstant.cardTitleTextSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _isNotificationEnabled,
                      builder: (context, value, child) {
                        return Checkbox(
                          value: _isNotificationEnabled.value,
                          activeColor: Colors.deepPurpleAccent,
                          shape: const CircleBorder(),
                          onChanged: (val) {
                            if (val != null) {
                              _isNotificationEnabled.value = val;
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: blankDivider(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Information",
                style: const TextStyle(fontSize: UiConstant.cardTitleTextSize),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoRow(
                      'Created By:',
                      _loggedInUser.id == createdBy.id ? "You" : createdBy.name,
                    ),
                    SizedBox(height: 8),
                    infoRow('Created On:', convertInDateFormat(createdOn)),
                    SizedBox(height: 8),
                    infoRow('Total Member:', totalMemberCount.toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: UiConstant.spaceBetweenSection,
          left: _mainScreenPadding.left,
          right: _mainScreenPadding.right,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: bottomBarHandler(),
        ),
      ),
    );
  }
}
