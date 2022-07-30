import 'package:flutter/material.dart';

import 'package:crunch/utils/constant.dart';

class DrawerIcon extends StatelessWidget {
  final double size;
  final Color bgColor;
  final Color barColor;
  final double gap;
  final double thickness;
  const DrawerIcon(
      {Key? key,
      this.size = kSizeIconDefault,
      this.bgColor = kColorBG,
      this.barColor = kColorBlack,
      this.gap = 2,
      this.thickness = 2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      color: bgColor,
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: gap);
        },
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: size,
            height: thickness,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(thickness / 4),
            ),
          );
        },
      ),
    );
  }
}
