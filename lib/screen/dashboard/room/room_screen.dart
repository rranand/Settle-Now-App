import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/room_card.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';

class RoomScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const RoomScreen({super.key, required this.isSearchEnabled});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final ValueNotifier<bool> _isLiveRoomSelected = ValueNotifier(true);
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 40,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.symmetric(vertical: 8),
              title: ValueListenableBuilder(
                valueListenable: _isLiveRoomSelected,
                builder: (BuildContext context, bool value, Widget? child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton.customTextButton(
                        "Live",
                        backgroundColor:
                            value
                                ? Colors.deepPurpleAccent
                                : Colors.transparent,
                        borderColor: Colors.deepPurpleAccent,
                        borderRadius: 30,
                        buttonHeight: 40,
                        buttonWidth: 100,
                        buttonTextColor: value ? Colors.white : Colors.black,
                        onPressed: () {
                          _isLiveRoomSelected.value = true;
                        },
                      ),
                      SizedBox(width: UiConstant.spaceBetweenRowSection),
                      CustomButton.customTextButton(
                        "Closed",
                        backgroundColor:
                            !value
                                ? Colors.deepPurpleAccent
                                : Colors.transparent,
                        borderColor: Colors.deepPurpleAccent,
                        borderRadius: 30,
                        buttonHeight: 40,
                        buttonWidth: 100,
                        buttonTextColor: !value ? Colors.white : Colors.black,
                        onPressed: () {
                          _isLiveRoomSelected.value = false;
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: _mainScreenPadding.add(
                  EdgeInsets.only(bottom: 2 * UiConstant.spaceBetweenSection),
                ),
                child: Column(
                  children: [
                    CustomFormField.searchBar(
                      "Search Groups...",
                      widget.isSearchEnabled,
                      _searchController,
                      (value) {
                        // Add filter logic if needed
                      },
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return RoomCard(status: statusList[index % 3]);
                      },
                      itemCount: 10,
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(height: 8);
                      },
                    ),
                  ],
                ),
              ),
              childCount: 1,
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
