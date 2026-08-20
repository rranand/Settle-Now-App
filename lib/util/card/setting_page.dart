import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/util/util_core.dart';
import 'package:share_plus/share_plus.dart';

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
  final ValueNotifier<XFile?> imagePreviewFile = ValueNotifier(null);
  final GlobalKey<FormState> _roomUpdateFormKey = GlobalKey<FormState>();
  final TextEditingController _roomNameController = TextEditingController();
  late FocusNode focusNode;

  late final StreamSubscription _sub;

  int totalMemberCount = 0;
  BaseUserModel createdBy = BaseUserModel.empty();
  DateTime createdOn = DateTime.now();
  String roomKey = "";
  String roomName = "";
  String roomLink = "";
  bool isDeletable = false;
  bool isLeavable = false;

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
                roomName: _roomNameController.text.trim(),
                scaffoldMessengerState: ScaffoldMessenger.of(context),
              ),
            );
          }
        case (TransactionType.room):
          {
            context.read<RoomInfoCubit>().updateRoomName(
              _roomNameController.text.trim(),
              ScaffoldMessenger.of(context),
            );
          }
        default:
          {}
      }
    }
  }

  void populateData() {
    bool dataPopulated = false;

    switch (widget.transactionType) {
      case (TransactionType.room):
        {
          final state = context.read<RoomInfoCubit>().state;

          if (state is RoomInfoSuccess) {
            _roomNameController.text = state.data.name;
            roomName = state.data.name;
            totalMemberCount = state.data.users.length;

            createdBy =
                state.data.users.firstWhere(
                      (user) => user.id == state.data.createdBy,
                      orElse: () => RoomUserModel.empty(),
                    )
                    as BaseUserModel;

            createdOn = state.data.createdOn;
            roomKey = state.data.key;
            roomLink = state.data.link;

            final loggedInUserData = state.data.users.firstWhere(
              (user) => user.id == _loggedInUser.id,
              orElse: () => RoomUserModel.empty(),
            );

            if (loggedInUserData.hasData) {
              dataPopulated = true;
              isDeletable = false;
              isLeavable = false;

              if (state.data.createdBy != _loggedInUser.id) {
                if (loggedInUserData.contribution == 0 &&
                    loggedInUserData.spent == 0 &&
                    loggedInUserData.settle == 0) {
                  isLeavable = true;
                }
              } else {
                bool isAnyUserHasData = false;
                for (RoomUserModel user in state.data.users) {
                  if (!(user.contribution == 0 &&
                      user.spent == 0 &&
                      user.settle == 0)) {
                    isAnyUserHasData = true;
                    break;
                  }
                }

                isDeletable = !isAnyUserHasData;
              }
            }
          }
        }
      case (TransactionType.lenden):
        {
          final state = context.read<LendenRoomBloc>().state;
          if (state is LendenRoomFetchSuccess) {
            dataPopulated = true;
            _roomNameController.text = state.roomData.roomName;
            totalMemberCount = state.roomData.users.length;

            for (int i = 0; i < totalMemberCount; i++) {
              if (state.roomData.users[i].id == state.roomData.createdBy) {
                createdBy = state.roomData.users[i] as BaseUserModel;
                break;
              }
            }

            createdOn = state.roomData.createdOn;

            final loggedInUserData = state.roomData.users.firstWhere(
              (user) => user.id == _loggedInUser.id,
              orElse: () => LendenUserModel.empty(),
            );
            isDeletable = false;
            isLeavable = false;

            if (loggedInUserData.hasData) {
              dataPopulated = true;

              if (state.roomData.createdBy != _loggedInUser.id) {
                if (loggedInUserData.gave == 0 && loggedInUserData.owe == 0) {
                  isLeavable = true;
                }
              } else {
                bool isAnyUserHasData = false;
                for (LendenUserModel user in state.roomData.users) {
                  if (!(user.gave == 0 && user.owe == 0)) {
                    isAnyUserHasData = true;
                    break;
                  }
                }

                isDeletable = !isAnyUserHasData;
              }
            }
          }
        }
      default:
        {}
    }

    if (!dataPopulated) {
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  Widget bottomBarHandler() {
    Color bgColor = Colors.red;
    String btnTxt = "Delete Room";
    bool isActionable = isDeletable;
    String errTxt = "Delete blocked due to existing records";

    if (createdBy.id != _loggedInUser.id) {
      bgColor = Colors.blueGrey.shade800;
      btnTxt = "Leave Room";
      isActionable = isLeavable;
      errTxt = "Leave request denied due to existing records";
    }

    return CustomButton.customElevatedButton(
      btnTxt,
      buttonHeight: 45,
      backgroundColor: bgColor,
      onPressed: () {
        if (isActionable) {
          if (widget.transactionType == TransactionType.lenden) {
            context.read<LendenRoomBloc>().add(
              LendenRoomDelete(
                id: widget.id,
                isRemoving: createdBy.id != _loggedInUser.id,
                scaffoldMessengerState: ScaffoldMessenger.of(context),
              ),
            );
          } else if (widget.transactionType == TransactionType.room) {
            context.read<RoomInfoCubit>().deleteRoom(
              widget.id,
              createdBy.id != _loggedInUser.id,
              ScaffoldMessenger.of(context),
            );
          }
        } else {
          showNormalSnackBar(context, errTxt);
        }
      },
    );
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
        Visibility(
          visible: label == "Room Key:",
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (context.mounted && mounted) {
                showSnackbarWithChildWidget(
                  "Room Key Copied",
                  child: snackbarSuccessIcon(),
                  duration: Duration(seconds: 1),
                  scaffoldMessenger: ScaffoldMessenger.of(context),
                );
              }
            },
            icon: Icon(Iconsax.copy_copy),
          ),
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
    try {
      _sub.cancel();
    } catch (_) {}
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    shareAssetImage();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
      populateData();

      switch (widget.transactionType) {
        case (TransactionType.lenden):
          {
            _sub = context.read<LendenRoomBloc>().stream.listen((state) {
              if (context.mounted &&
                  mounted &&
                  state is LendenRoomInitial &&
                  context.canPop()) {
                context.pop();
              }
            });
          }
        case (TransactionType.room):
          {
            _sub = context.read<RoomInfoCubit>().stream.listen((state) {
              if (context.mounted &&
                  mounted &&
                  state is RoomInfoInitial &&
                  context.canPop()) {
                context.pop();
              }
            });
          }
        default:
          {}
      }
    }
    focusNode = FocusNode();
  }

  Widget saveHandler() {
    String ogRoomName = "";

    switch (widget.transactionType) {
      case (TransactionType.lenden):
        {
          final state = context.watch<LendenRoomBloc>().state;
          if (state is LendenRoomFetchSuccess && state.id == widget.id) {
            ogRoomName = state.roomData.roomName;
          }
        }
      case (TransactionType.room):
        {
          final state = context.watch<RoomInfoCubit>().state;
          if (state is RoomInfoSuccess && state.data.id == widget.id) {
            ogRoomName = state.data.name;
            roomName = ogRoomName;
          }
        }
      default:
        {
          return SizedBox.shrink();
        }
    }

    if (ogRoomName.isEmpty) {
      return SizedBox.shrink();
    }

    return Visibility(
      visible: _roomNameController.text != ogRoomName,
      child: IconButton(
        icon: Icon(Icons.check),
        onPressed: () {
          roomUpdateHandler();
        },
      ),
    );
  }

  Future<void> shareAssetImage() async {
    if (kIsWeb) {
      return;
    }
    try {
      final byteData = await rootBundle.load('assets/sn/SN_WBG.png');

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/SN_WBG.png');

      await file.writeAsBytes(byteData.buffer.asUint8List());

      imagePreviewFile.value = XFile(file.path);
    } catch (_) {}
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
              return saveHandler();
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
                        suffixIcon: Icon(Iconsax.edit_2_copy, size: 22),
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
                          activeColor: Theme.of(context).primaryColor,
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
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black38),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        widget.transactionType == TransactionType.room
                            ? EdgeInsets.only(
                              bottom: 8,
                              left: 8,
                              right: 8,
                              top: 4,
                            )
                            : EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.transactionType == TransactionType.room
                            ? infoRow('Room Key:', roomKey)
                            : SizedBox.shrink(),
                        infoRow(
                          'Created By:',
                          _loggedInUser.id == createdBy.id
                              ? "You"
                              : createdBy.name,
                        ),
                        SizedBox(height: 8),
                        infoRow('Created On:', convertInDateFormat(createdOn)),
                        SizedBox(height: 8),
                        infoRow('Total Member:', totalMemberCount.toString()),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: widget.transactionType == TransactionType.room,
                    child: Positioned(
                      right: 8,
                      child: ValueListenableBuilder(
                        valueListenable: imagePreviewFile,
                        builder: (context, value, child) {
                          return IconButton(
                            padding: EdgeInsets.only(
                              top: 8,
                              bottom: 8,
                              left: 8,
                              right: 8,
                            ),
                            onPressed: () {
                              SharePlus.instance.share(
                                ShareParams(
                                  text:
                                      "Join $roomName\nRoom Key: $roomKey\n$roomLink",
                                  previewThumbnail: imagePreviewFile.value,
                                ),
                              );
                            },
                            icon: Icon(Iconsax.send_2_copy),
                          );
                        },
                      ),
                    ),
                  ),
                ],
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [bottomBarHandler()],
        ),
      ),
    );
  }
}
