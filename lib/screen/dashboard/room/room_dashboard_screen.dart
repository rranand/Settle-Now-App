import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/room/room_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/room_info_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/room_card.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/navbar_widget.dart';
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
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  List<String> statusList = ["Open", "Closed", "Partially Closed"];

  void _blocListenerHandler(BuildContext context, RoomState state) {
    if (state is RoomFailure) {
      showNormalSnackBar(context, state.error);
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
    context.read<RoomBloc>().add(RoomFetch());
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
          SliverToBoxAdapter(
            child: Padding(
              padding: _mainScreenPadding,
              child: CustomFormField.searchBar(
                "Search Room",
                widget.isSearchEnabled,
                _searchController,
                (value) {
                  // Add filter logic if needed
                },
              ),
            ),
          ),
          BlocConsumer<RoomBloc, RoomState>(
            listener: _blocListenerHandler,
            builder: (context, state) {
              List<RoomInfoModel> roomInfoData = [];
              if (state is RoomFetchSuccess) {
                roomInfoData = state.data;
              } else if (state is RoomLoading) {
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
        () {},
      ),
    );
  }
}
