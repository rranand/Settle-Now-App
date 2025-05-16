import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';

class RoundedNavbarWidget extends StatelessWidget {
  final List<String> title;
  final ValueNotifier<int> titleIndex;

  const RoundedNavbarWidget({
    super.key,
    required this.title,
    required this.titleIndex,
  });

  Expanded _tabButton(int index) {
    bool isActive = index == titleIndex.value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          titleIndex.value = index;
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient:
                isActive
                    ? LinearGradient(
                      colors: GradientColorConstant.coolIndigoToBlue,
                    )
                    : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          alignment: Alignment.center,
          child: Text(
            title[index],
            style: TextStyle(color: isActive ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(50),
      ),
      padding: EdgeInsets.all(4),
      child: Row(
        children: List.generate(title.length, (index) => _tabButton(index)),
      ),
    );
  }
}
