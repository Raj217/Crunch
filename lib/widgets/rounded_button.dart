import 'package:crunch/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatefulWidget {
  final Widget child;
  final Color _activeBGColor;
  final Color inactiveBGColor;
  final Color activeBorderColor;
  final Color inactiveBorderColor;
  final double borderWidth;
  final void Function()? onTap;
  final double? height;
  final double? width;
  final bool giveDefaultInternalPadding;
  bool isActive;
  RoundedButton(
      {Key? key,
      required this.child,
      Color? activeBGColor,
      this.inactiveBGColor = kColorGray,
      this.activeBorderColor = kColorBlueDark,
      this.inactiveBorderColor = kColorBlack,
      this.onTap,
      this.height,
      this.width,
      this.giveDefaultInternalPadding = false,
      this.isActive = true,
      this.borderWidth = 2})
      : _activeBGColor = activeBGColor ?? kColorBlue,
        super(key: key);

  @override
  State<RoundedButton> createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null && widget.isActive) {
          widget.onTap!();
        }
      },
      child: AnimatedContainer(
        height: widget.height,
        width: widget.width,
        duration: const Duration(milliseconds: 200),
        padding: widget.giveDefaultInternalPadding
            ? const EdgeInsets.symmetric(vertical: 15, horizontal: 20)
            : null,
        decoration: BoxDecoration(
            color: widget.isActive
                ? widget._activeBGColor
                : widget.inactiveBGColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: widget.isActive
                    ? widget.activeBorderColor
                    : widget.inactiveBorderColor,
                width: widget.borderWidth)),
        child: Center(child: widget.child),
      ),
    );
  }
}
