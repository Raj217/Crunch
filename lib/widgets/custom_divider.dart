import 'package:crunch/utils/constant.dart';
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  /// The longer side
  final double length;
  final double thickness;
  final Axis direction;
  final Color color;
  const CustomDivider(
      {Key? key,
      this.length = double.infinity,
      this.thickness = 1,
      this.direction = Axis.horizontal,
      this.color = kColorGrayMedium})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: direction == Axis.horizontal ? thickness : length,
      width: direction == Axis.horizontal ? length : thickness,
      color: color,
    );
  }
}
