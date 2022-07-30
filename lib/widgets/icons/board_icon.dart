import 'package:flutter/material.dart';

import 'package:crunch/utils/constant.dart';

class BoardIcon extends StatelessWidget {
  final double height;
  final double width;
  final Color bgColor;
  final Color iconColor;
  late double? padding;
  BoardIcon(
      {Key? key,
      this.height = kSizeIconDefault,
      this.width = kSizeIconDefault,
      this.bgColor = kColorGray,
      this.iconColor = kColorGrayDark,
      this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    padding = padding ?? height / 7;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(padding!),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: padding!),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: (height - padding! * 2) / 2,
              width: width * 2 / 7,
              decoration: BoxDecoration(
                color: kColorGrayDark,
                borderRadius: BorderRadius.circular(padding!),
              ),
            ),
            Container(
              height: height - padding! * 2,
              width: width * 2 / 7,
              decoration: BoxDecoration(
                color: kColorGrayDark,
                borderRadius: BorderRadius.circular(padding!),
              ),
            )
          ],
        ),
      ),
    );
  }
}
