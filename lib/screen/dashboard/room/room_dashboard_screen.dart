import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/room/dashboard/room_dashboard_bloc.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/room/create_join_room/create_join_room_cubit.dart';
import 'package:settlenow_v2/model/room_info_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/room_card.dart';
import 'package:settlenow_v2/util/enum/enums.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/functions/validator.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/gradient_widget.dart';
import 'package:settlenow_v2/util/widgets/navbar_widget.dart';
import 'package:settlenow_v2/util/widgets/rounded_navbar_widget.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';

class RoomDashboardScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const RoomDashboardScreen({super.key, required this.isSearchEnabled});

  @override
  State<RoomDashboardScreen> createState() => _RoomDashboardScreenState();
}

class _RoomDashboardScreenState extends State<RoomDashboardScreen> {
  final ValueNotifier<int> _navBarIndex = ValueNotifier(0);
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<int> _roomJoinOrCreate = ValueNotifier(0);
  final GlobalKey<FormState> _roomJoinOrCreateKey = GlobalKey<FormState>();
  final TextEditingController _roomJoinOrCreateController =
      TextEditingController();
  final ValueNotifier<bool> _isInActiveDataFetched = ValueNotifier(false);
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  UserModel _loggedInUser = UserModel.empty();
  late final StreamSubscription _createRoomListener;
  final ScrollController _gridViewScrollController = ScrollController();

  List<String> statusList = ["Open", "Closed", "Partially Closed"];

  void _blocListenerHandler(BuildContext context, RoomDashboardState state) {
    if (state is RoomDashboardFailure) {
      showNormalSnackBar(context, state.error);
    }
  }

  void _roomJoinOrCreateHandler() {
    if (_roomJoinOrCreateKey.currentState!.validate()) {
      if (_roomJoinOrCreate.value == 0) {
        context.read<CreateJoinRoomCubit>().createNewRoom(
          context,
          _roomJoinOrCreateController.text,
        );
      } else {
        context.read<CreateJoinRoomCubit>().joinNewRoom(
          context,
          _roomJoinOrCreateController.text,
          _loggedInUser.authToken,
          ScaffoldMessenger.of(context),
        );
      }
      if (context.canPop()) {
        _roomJoinOrCreateController.text = "";
        context.pop();
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
      _loggedInUser = authState.userData;
    }

    final state = context.read<RoomDashboardBloc>().state;

    if (state is! RoomDashboardFetchSuccess) {
      context.read<RoomDashboardBloc>().add(
        RoomDashboardFetch(
          authToken: _loggedInUser.authToken,
          isActiveRoom: true,
        ),
      );
    }

    _createRoomListener = context.read<CreateJoinRoomCubit>().stream.listen((
      state,
    ) {
      if (mounted && state is CreateJoinRoomFailure) {
        showNormalSnackBar(context, state.error);
      }
    });

    _navBarIndex.addListener(() {
      if (!_isInActiveDataFetched.value) {
        _isInActiveDataFetched.value = true;
        context.read<RoomDashboardBloc>().add(
          RoomDashboardFetch(
            authToken: _loggedInUser.authToken,
            isActiveRoom: false,
          ),
        );
      }
    });

    _gridViewScrollController.addListener(() {
      if (_gridViewScrollController.position.pixels ==
          _gridViewScrollController.position.maxScrollExtent) {
        final roomDashboardState = context.read<RoomDashboardBloc>().state;
        if (roomDashboardState is RoomDashboardLoading) {
          return;
        }
        if (_navBarIndex.value == 0) {
          context.read<RoomDashboardBloc>().add(
            RoomDashboardFetch(
              authToken: _loggedInUser.authToken,
              isActiveRoom: true,
            ),
          );
        } else {
          context.read<RoomDashboardBloc>().add(
            RoomDashboardFetch(
              authToken: _loggedInUser.authToken,
              isActiveRoom: false,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _gridViewScrollController.dispose();
    _navBarIndex.dispose();
    _createRoomListener.cancel();
    super.dispose();
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(height: 4, width: 60, color: Colors.grey[300]),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: _roomJoinOrCreate,
                builder: (BuildContext context, int value, Widget? _) {
                  return RoundedNavbarWidget(
                    title: ["Create Room", "Join Room"],
                    titleIndex: _roomJoinOrCreate,
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: ValueListenableBuilder(
                  valueListenable: _roomJoinOrCreate,
                  builder: (BuildContext context, int value, Widget? child) {
                    String hintText =
                        "Room ${_roomJoinOrCreate.value == 0 ? 'Name' : 'Key'}";
                    return Form(
                      key: _roomJoinOrCreateKey,
                      child: CustomFormField.textFormField(
                        _roomJoinOrCreateController,
                        autofillHints: [],
                        hintText: hintText,
                        labelText: hintText,
                        validator: (value) {
                          if (_roomJoinOrCreate.value == 0) {
                            return CustomValidator.validateRoomName(value);
                          } else {
                            return CustomValidator.validateRoomKey(value);
                          }
                        },
                        inputDecoration:
                            TextFormFieldInputBorder.outlineInputBorder,
                        borderColor: Colors.black12,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: ValueListenableBuilder(
                  valueListenable: _roomJoinOrCreate,
                  builder: (BuildContext context, int value, Widget? child) {
                    String buttonText =
                        _roomJoinOrCreate.value == 0 ? 'Create' : 'Join';
                    return InkWell(
                      onTap: _roomJoinOrCreateHandler,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * .9,
                        child: GradientWidget(
                          text: buttonText,
                          gradientColors:
                              GradientColorConstant.coolIndigoToBlue,
                          textSize: 14,
                          textColor: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardSizeInfo = calculateCrossAspectRatio(
      MediaQuery.of(context).size.width,
      _mainScreenPadding,
    );

    return Scaffold(
      body: SingleChildScrollView(
        controller: _gridViewScrollController,
        padding: _mainScreenPadding.add(
          EdgeInsets.only(bottom: UiConstant.spaceAtBottom),
        ),
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: _navBarIndex,
              builder: (BuildContext context, int value, Widget? child) {
                return SizedBox(
                  height: 40,
                  child: NavBarCard(
                    headerTitle: ["Live", "Close"],
                    selectedIndex: _navBarIndex,
                  ),
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: widget.isSearchEnabled,
              builder: (context, _, _) {
                return Column(
                  children: [
                    widget.isSearchEnabled.value
                        ? CustomFormField.searchBar(
                          "Search",
                          widget.isSearchEnabled,
                          _searchController,
                          (value) {},
                        )
                        : SizedBox.shrink(),
                    ValueListenableBuilder(
                      valueListenable: _navBarIndex,
                      builder: (context, _, _) {
                        return BlocConsumer<
                          RoomDashboardBloc,
                          RoomDashboardState
                        >(
                          listener: _blocListenerHandler,
                          builder: (context, state) {
                            List<RoomInfoModel> roomInfoData = [];
                            if (state is RoomDashboardFetchSuccess) {
                              roomInfoData =
                                  _navBarIndex.value == 0
                                      ? state.activeData
                                      : state.inactiveData;
                            } else if (state is RoomDashboardLoading) {
                              roomInfoData = List.generate(
                                11,
                                (i) => RoomInfoModel.empty(),
                              );
                            }
                            return GridView.builder(
                              padding: EdgeInsets.only(
                                top:
                                    widget.isSearchEnabled.value
                                        ? 0
                                        : UiConstant.spaceBetweenSection,
                              ),
                              shrinkWrap: true,
                              itemCount: roomInfoData.length,
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: cardSizeInfo[0],
                                    mainAxisSpacing:
                                        UiConstant.spaceBetweenCard,
                                    crossAxisSpacing:
                                        UiConstant.spaceBetweenCard,
                                    childAspectRatio: cardSizeInfo[1],
                                  ),
                              itemBuilder: (BuildContext context, int index) {
                                return RoomCard(data: roomInfoData[index]);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: CustomButton.customFloatingButton(
        Iconsax.add,
        () => _showBottomSheet(context),
      ),
    );
  }
}
