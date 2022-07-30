import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double length;
  final double thickness;
  final Axis direction;
  const CustomDivider(
      {Key? key,
      this.length = double.infinity,
      this.thickness = 1,
      this.direction = Axis.horizontal})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black12,
        width: direction == Axis.horizontal ? length : thickness,
        height: direction == Axis.horizontal ? thickness : length);
  }
}
