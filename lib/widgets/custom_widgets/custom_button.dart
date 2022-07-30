import 'package:flutter/material.dart';

import 'package:crunch/utils/constant.dart';

class CustomButton extends StatelessWidget {
  final IconData icon;
  final void Function()? onTap;
  const CustomButton({Key? key, required this.icon, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.circle,
            color: Colors.transparent,
            size: kSizeIconDefault + 10,
          ),
          Icon(
            icon,
            color: kColorGrayDark,
            size: kSizeIconDefault,
          )
        ],
      ),
    );
  }
}
