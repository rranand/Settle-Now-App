import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';

class NavBarCard extends StatelessWidget {
  final List<String> headerTitle;
  final ValueNotifier<int> selectedIndex;
  final double width;
  final bool equalSplit;

  const NavBarCard({
    super.key,
    required this.headerTitle,
    required this.selectedIndex,
    required this.width,
    this.equalSplit = true,
  });

  @override
  Widget build(BuildContext context) {
    int headerTitleLength = headerTitle.length;
    double extraHorizontalPadding =
        12 + context.watch<ScreenSizeProvider>().getPadding.left;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: extraHorizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            List.generate(headerTitle.length, (index) {
              double eachNavWidth =
                  width -
                  UiConstant.spaceBetweenRowSection *
                      1.5 *
                      (headerTitleLength - 1) -
                  extraHorizontalPadding * 2;

              return SizedBox(
                width: equalSplit ? eachNavWidth / headerTitleLength : null,
                child: Column(
                  children: [
                    Center(
                      child: InkWell(
                        onTap: () {
                          selectedIndex.value = index;
                        },
                        child: Text(
                          "  ${headerTitle[index]}  ",
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                selectedIndex.value == index
                                    ? Colors.deepPurple
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Container(
                        height: 2,
                        color:
                            selectedIndex.value == index
                                ? Colors.deepPurple
                                : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}
