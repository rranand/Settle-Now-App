import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';

import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/util/util_core.dart';

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
  List<String> headerTitle = ["Live", "Close"];

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
          _roomJoinOrCreateController.text.trim(),
        );
      } else {
        context.read<CreateJoinRoomCubit>().joinNewRoom(
          _roomJoinOrCreateController.text.trim(),
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

      final state = context.read<RoomDashboardBloc>().state;

      if (state is! RoomDashboardFetchSuccess) {
        context.read<RoomDashboardBloc>().add(
          RoomDashboardFetch(isActiveRoom: true, isFreshFetch: false),
        );
      }

      _navBarIndex.addListener(() {
        if (!_isInActiveDataFetched.value) {
          _isInActiveDataFetched.value = true;
          context.read<RoomDashboardBloc>().add(
            RoomDashboardFetch(isActiveRoom: false, isFreshFetch: false),
          );
        }
      });

      _gridViewScrollController.addListener(() {
        if (_gridViewScrollController.position.pixels ==
            _gridViewScrollController.position.maxScrollExtent) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            context.read<RoomDashboardBloc>().add(
              RoomDashboardFetch(
                isActiveRoom: _navBarIndex.value == 0,
                isFreshFetch: false,
              ),
            );
          });
        }
      });
    }

    _createRoomListener = context.read<CreateJoinRoomCubit>().stream.listen((
      state,
    ) {
      if (mounted && state is CreateJoinRoomFailure) {
        showNormalSnackBar(context, state.error);
      }
    });

    widget.isSearchEnabled.addListener(() {
      _searchController.text = "";
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: const EdgeInsets.all(
            16.0,
          ).add(EdgeInsets.only(bottom: keyboardHeight)),
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
                        borderColor:
                            GradientColorConstant.coolIndigoToBlue.last,
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
                      borderRadius: BorderRadius.circular(
                        UiConstant.cardBorderRadius,
                      ),
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

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(
        context,
        SnackbarMessageConstant.sessionExpiredMessage,
      );
      return;
    }
    context.read<RoomDashboardBloc>().add(
      RoomDashboardFetch(
        isActiveRoom: _navBarIndex.value == 0,
        isFreshFetch: true,
      ),
    );
  }

  List<RoomInfoModel> filterDataByPreference(
    List<RoomInfoModel> oldData,
    PreferenceSection pref,
  ) {
    if (pref.isSettled) {
      return oldData;
    }

    List<RoomInfoModel> data = [];

    for (int i = 0; i < oldData.length; i++) {
      bool isSettledByYou =
          !oldData[i].users
              .firstWhere(
                (ele) => ele.id == _loggedInUser.id,
                orElse: () => RoomUserModel.empty(),
              )
              .active;

      if (pref.isSettled != isSettledByYou) {
        continue;
      }
      data.add(oldData[i]);
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final cardSizeInfo = calculateCrossAspectRatio(
      context,
      MediaQuery.of(context).size.width,
      _mainScreenPadding,
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        notificationPredicate: (ScrollNotification notification) {
          final state = context.read<RoomDashboardBloc>().state;
          if (state is RoomDashboardFetchSuccess) {
            if (_navBarIndex.value == 0 && state.activeData.isNotEmpty) {
              return notification.depth == 0;
            } else if (_navBarIndex.value == 1 &&
                state.inactiveData.isNotEmpty) {
              return notification.depth == 0;
            } else {
              return notification.depth == 1;
            }
          } else {
            return notification.depth == 1;
          }
        },
        child: Consumer<PreferenceProvider>(
          builder: (context, prefData, _) {
            return CustomGestureDetector(
              navBarIndex: _navBarIndex,
              totalTitle: headerTitle.length,
              child: CustomScrollView(
                controller: _gridViewScrollController,
                slivers: [
                  ValueListenableBuilder(
                    valueListenable: widget.isSearchEnabled,
                    builder: (BuildContext context, bool value, Widget? _) {
                      if (!value) {
                        return SliverToBoxAdapter(child: SizedBox.shrink());
                      }
                      return SliverPadding(
                        padding: _mainScreenPadding,
                        sliver: SliverAppBar(
                          automaticallyImplyLeading: false,
                          pinned: value,
                          title: CustomFormField.searchBar(
                            "Search",
                            widget.isSearchEnabled,
                            _searchController,
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _navBarIndex,
                    builder: (BuildContext context, int value, Widget? child) {
                      return SliverToBoxAdapter(
                        child: SizedBox(
                          height: 40,
                          child: NavBarCard(
                            headerTitle: headerTitle,
                            selectedIndex: _navBarIndex,
                          ),
                        ),
                      );
                    },
                  ),
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
                                    ? filterDataByPreference(
                                      state.activeData,
                                      prefData.roomPref,
                                    )
                                    : state.inactiveData;
                          } else if (state is RoomDashboardLoading) {
                            roomInfoData = List.generate(
                              11,
                              (i) => RoomInfoModel.empty(),
                            );
                          }
                          if (roomInfoData.isEmpty) {
                            return SliverToBoxAdapter(
                              child: noRecordFoundWidget(
                                ApiConstant.noRoomFound,
                                context,
                              ),
                            );
                          } else {
                            return SliverPadding(
                              padding: _mainScreenPadding
                                  .add(
                                    EdgeInsets.only(
                                      bottom: UiConstant.spaceAtBottom,
                                    ),
                                  )
                                  .add(
                                    EdgeInsets.only(
                                      top: UiConstant.spaceBetweenSection,
                                    ),
                                  ),
                              sliver: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _searchController,
                                builder: (context, _, _) {
                                  List<RoomInfoModel> filterData = roomInfoData;
                                  if (state is RoomDashboardFetchSuccess) {
                                    filterData = FilterSort.filteredSearchText(
                                      _searchController.text,
                                      roomInfoData,
                                      (roomData) => roomData.roomName,
                                    );
                                  }

                                  if (filterData.isEmpty) {
                                    return SliverToBoxAdapter(
                                      child: noRecordFoundWidget(
                                        ApiConstant.noMatchingRecords,
                                        context,
                                      ),
                                    );
                                  }
                                  return SliverGrid.builder(
                                    itemCount: filterData.length,
                                    gridDelegate:
                                        SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: cardSizeInfo[0],
                                          mainAxisSpacing:
                                              UiConstant.spaceBetweenCard,
                                          crossAxisSpacing:
                                              UiConstant.spaceBetweenCard,
                                          childAspectRatio: cardSizeInfo[1],
                                        ),
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      return RoomCard(data: filterData[index]);
                                    },
                                  );
                                },
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: CustomButton.customFloatingButton(
        Iconsax.add_copy,
        () => _showBottomSheet(context),
      ),
    );
  }
}
