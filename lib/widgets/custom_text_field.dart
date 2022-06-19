import 'package:crunch/utils/constant.dart';
import 'package:flutter/material.dart';

enum InputType {
  normal,
  obscureComplete,

  /// No option to reveal,
  obscurePartial

  /// Option available to reveal
}

class CustomTextField extends StatefulWidget {
  final Color bgColor;
  final Color borderColor;
  final double borderWidth;
  final TextStyle _textStyle;
  final TextStyle _hintTextStyle;
  final String hintText;
  final void Function(String)? onChanged;
  final bool autofocus;
  final double height;
  final double width;
  final InputType inputType;
  final bool isKeyboardTypeEmail;
  final bool isMultiline;
  final TextEditingController? controller;
  final bool readOnly;
  CustomTextField(
      {Key? key,
      this.bgColor = kColorGray,
      this.borderColor = kColorBlack,
      this.borderWidth = 1.3,
      TextStyle? textStyle,
      TextStyle? hintTextStyle,
      this.hintText = '',
      this.onChanged,
      this.autofocus = false,
      this.height = 40,
      this.width = 300,
      this.inputType = InputType.normal,
      this.isKeyboardTypeEmail = false,
      this.isMultiline = false,
      this.readOnly = false,
      this.controller})
      : _textStyle = textStyle ??
            kTextStyleDefaultActiveText.copyWith(
                fontWeight: FontWeight.w600, fontSize: 12),
        _hintTextStyle = hintTextStyle ?? kTextStyleDefaultInactiveText,
        super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    isVisible = widget.inputType == InputType.normal;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: widget.borderColor, width: widget.borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 8,
            child: TextField(
              readOnly: widget.readOnly,
              maxLines: widget.isMultiline ? null : 1,
              autofocus: widget.autofocus,
              style: widget.readOnly
                  ? widget._textStyle.copyWith(color: kColorGrayDark)
                  : widget._textStyle,
              controller: widget.controller,
              obscureText: !isVisible,
              cursorColor: widget.borderColor,
              keyboardType: widget.isMultiline
                  ? TextInputType.multiline
                  : (widget.isKeyboardTypeEmail
                      ? TextInputType.emailAddress
                      : null),
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  focusColor: widget.borderColor,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  hintStyle: widget._hintTextStyle),
            ),
          ),
          Visibility(
            visible: widget.inputType != InputType.normal,
            child: Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () {
                    if (widget.inputType == InputType.obscurePartial) {
                      setState(() {
                        isVisible = !isVisible;
                      });
                    }
                  },
                  child: Center(
                    child: Icon(isVisible
                        ? Icons.remove_red_eye_outlined
                        : Icons.remove_red_eye),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
