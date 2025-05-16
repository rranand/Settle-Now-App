import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/room/dashboard/room_dashboard_bloc.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/room_info_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/room_card.dart';
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
  final GlobalKey<FormState> _roomJoinOrCreateKey = GlobalKey();
  final TextEditingController _roomJoinOrCreateController =
      TextEditingController();
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  List<String> statusList = ["Open", "Closed", "Partially Closed"];

  void _blocListenerHandler(BuildContext context, RoomDashboardState state) {
    if (state is RoomDashboardFailure) {
      showNormalSnackBar(context, state.error);
    }
  }

  void _roomJoinOrCreateHandler() {
    if (_roomJoinOrCreateKey.currentState!.validate()) {}
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
    final state = context.read<RoomDashboardBloc>().state;

    if (state is! RoomDashboardFetchSuccess) {
      context.read<RoomDashboardBloc>().add(RoomDashboardFetch());
    }
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 40,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.symmetric(vertical: 8),
              centerTitle: true,
              title: ValueListenableBuilder(
                valueListenable: _navBarIndex,
                builder: (BuildContext context, int value, Widget? child) {
                  return NavBarCard(
                    headerTitle: ["Live", "Close"],
                    selectedIndex: _navBarIndex,
                  );
                },
              ),
            ),
          ),
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
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  title: CustomFormField.searchBar(
                    "Search",
                    widget.isSearchEnabled,
                    _searchController,
                    (value) {
                      // Add filter logic if needed
                    },
                  ),
                ),
              );
            },
          ),
          BlocConsumer<RoomDashboardBloc, RoomDashboardState>(
            listener: _blocListenerHandler,
            builder: (context, state) {
              List<RoomInfoModel> roomInfoData = [];
              if (state is RoomDashboardFetchSuccess) {
                roomInfoData = state.data;
              } else if (state is RoomDashboardLoading) {
                roomInfoData = List.generate(11, (i) => RoomInfoModel.empty());
              }
              return SliverPadding(
                padding: _mainScreenPadding.add(
                  EdgeInsets.only(bottom: UiConstant.spaceAtBottom),
                ),
                sliver: SliverGrid.builder(
                  itemCount: roomInfoData.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: cardSizeInfo[0],
                    mainAxisSpacing: UiConstant.spaceBetweenCard,
                    crossAxisSpacing: UiConstant.spaceBetweenCard,
                    childAspectRatio: cardSizeInfo[1],
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return RoomCard(data: roomInfoData[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: CustomButton.customFloatingButton(
        Iconsax.add,
        () => _showBottomSheet(context),
      ),
    );
  }
}
