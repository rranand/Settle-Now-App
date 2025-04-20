import 'package:flutter/material.dart';

class NavBarCard extends StatelessWidget {
  final List<String> headerTitle;
  final ValueNotifier<int> selectedIndex;

  const NavBarCard({
    super.key,
    required this.headerTitle,
    required this.selectedIndex,
  });

  String _textWithPaddingSpace(String text) {
    String space = List.generate(4, (i) => " ").join();
    return space + text + space;
  }

  Widget _sectionTitle(int index) {
    return Stack(
      children: [
        Center(
          child: InkWell(
            onTap: () {
              selectedIndex.value = index;
            },
            child: Text(
              _textWithPaddingSpace(headerTitle[index]),
              maxLines: 1,
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
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            color:
                selectedIndex.value == index
                    ? Colors.deepPurple
                    : Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _navBarHandler() {
    if (headerTitle.length > 3) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => _sectionTitle(index),
        itemCount: headerTitle.length,
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            List.generate(headerTitle.length, (index) {
              return _sectionTitle(index);
            }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _navBarHandler();
  }
}
