import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/card/room_card.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/navbar_widget.dart';

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
                    width:
                        MediaQuery.of(context).size.width -
                        2 * _mainScreenPadding.left,
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
          SliverPadding(
            padding: _mainScreenPadding.add(
              EdgeInsets.only(bottom: UiConstant.spaceAtBottom),
            ),
            sliver: SliverGrid.builder(
              itemCount: 11,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: cardSizeInfo[0],
                mainAxisSpacing: UiConstant.spaceBetweenCard,
                crossAxisSpacing: UiConstant.spaceBetweenCard,
                childAspectRatio: cardSizeInfo[1],
              ),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    context.push("${RouterConstants.roomRouteName}/id");
                  },
                  child: RoomCard(status: statusList[index % 3]),
                );
              },
            ),
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
