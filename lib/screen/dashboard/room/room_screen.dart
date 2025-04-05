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
                        backgroundColor: Colors.transparent,
                        borderColor:
                            value
                                ? Colors.deepPurpleAccent
                                : Colors.black.withAlpha(51),
                        borderRadius: 30,
                        buttonHeight: 40,
                        buttonWidth: 100,
                        buttonTextColor:
                            value ? Colors.deepPurpleAccent : Colors.black,
                        onPressed: () {
                          _isLiveRoomSelected.value = true;
                        },
                      ),
                      SizedBox(width: UiConstant.spaceBetweenRowSection),
                      CustomButton.customTextButton(
                        "Closed",
                        backgroundColor: Colors.transparent,
                        borderColor:
                            !value
                                ? Colors.deepPurpleAccent
                                : Colors.black.withAlpha(51),
                        borderRadius: 30,
                        buttonHeight: 40,
                        buttonWidth: 100,
                        buttonTextColor:
                            !value ? Colors.deepPurpleAccent : Colors.black,
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
                padding: _mainScreenPadding,
                child: Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: widget.isSearchEnabled,
                      builder: (
                        BuildContext context,
                        bool value,
                        Widget? child,
                      ) {
                        return Visibility(
                          visible: widget.isSearchEnabled.value,
                          child: child!,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: .5 * UiConstant.spaceBetweenSection,
                        ),
                        child: CustomFormField.textFormField(
                          _searchController,
                          hintText: "Search groups...",
                          prefixIcon: Icon(Icons.search),
                          inputDecoration:
                              TextFormFieldInputBorder.outlineInputBorder,
                          borderColor: Colors.black12,
                          borderRadius: 30,
                          filled: true,
                          fillColor: Colors.black.withAlpha(10),
                          onChanged: (value) {
                            // Add filter logic if needed
                          },
                        ),
                      ),
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
                    SizedBox(height: 2 * UiConstant.spaceBetweenSection),
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
