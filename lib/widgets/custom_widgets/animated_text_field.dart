import 'package:crunch/widgets/custom_widgets/custom_button.dart';
import 'package:flutter/material.dart';

import 'package:crunch/utils/constant.dart';

class AnimatedTextField extends StatefulWidget {
  final double height;
  final double width;
  final bool? readOnly;
  final bool isMultiline;
  final TextStyle _textStyle;
  final TextStyle _hintTextStyle;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? initText;
  final Color textColor;
  final bool autoFocus;
  final bool isCheckboxVisible;
  final bool checkboxValue;
  final bool? showEditButton;
  final bool? showDeleteButton;
  final TextAlign textFieldTextAlign;
  final EdgeInsets _internalTextFieldPadding;
  final TextEditingController _controller;
  final void Function()? onSubmit;
  final void Function(bool)? onCheckboxChanged;
  final void Function()? onDelete;
  final void Function(String, bool)? onChanged;
  AnimatedTextField(
      {Key? key,
      this.height = 40,
      this.width = 300,
      this.readOnly,
      this.isMultiline = false,
      TextStyle? textStyle,
      TextStyle? hintTextStyle,
      this.keyboardType,
      this.initText,
      this.hintText,
      this.textColor = kColorBlack,
      this.autoFocus = true,
      this.isCheckboxVisible = false,
      this.checkboxValue = false,
      this.onCheckboxChanged,
      this.showEditButton,
      this.textFieldTextAlign = TextAlign.start,
      EdgeInsets? internalTextFieldPadding,
      TextEditingController? controller,
      this.showDeleteButton,
      this.onSubmit,
      this.onDelete,
      this.onChanged})
      : _textStyle = textStyle ??
            kTextStyleDefaultActiveText.copyWith(
                fontWeight: FontWeight.w600, fontSize: 12),
        _hintTextStyle = hintTextStyle ?? kTextStyleDefaultInactiveText,
        _internalTextFieldPadding = internalTextFieldPadding ??
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        _controller = controller ?? TextEditingController(),
        super(key: key);

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with TickerProviderStateMixin {
  bool _isReadOnlyModeEnabled = true;
  bool? _checkboxValue = false;
  @override
  void initState() {
    super.initState();
    _isReadOnlyModeEnabled = widget.readOnly ??
        (widget.initText != null && widget.initText!.isNotEmpty);

    if (widget.initText != null) {
      widget._controller.text = widget.initText!;
    }
    _checkboxValue = widget.checkboxValue;
  }

  @override
  void dispose() {
    super.dispose();
    widget._controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Row(
        children: [
          Visibility(
            visible: widget.isCheckboxVisible == true,
            child: Expanded(
              child: Checkbox(
                  value: _checkboxValue,
                  activeColor: widget.textColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)),
                  onChanged: (value) {
                    if (widget._controller.text.isNotEmpty) {
                      setState(() {
                        _checkboxValue = value;
                      });
                      if (widget.onCheckboxChanged != null) {
                        widget.onCheckboxChanged!(value ?? false);
                      }
                    }
                  }),
            ),
          ),
          Expanded(
            flex: 8,
            child: Opacity(
              opacity: _checkboxValue == true ? 0.8 : 1,
              child: TextField(
                textAlign: widget.textFieldTextAlign,
                readOnly: widget.readOnly ?? _isReadOnlyModeEnabled,
                maxLines: widget.isMultiline ? null : 1,
                style: widget._textStyle.copyWith(
                    decoration: _checkboxValue == true
                        ? TextDecoration.lineThrough
                        : TextDecoration.none),
                controller: widget._controller,
                cursorColor: widget.textColor,
                autofocus: widget.autoFocus,
                onChanged: (text) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(text, _checkboxValue ?? false);
                  }
                },
                keyboardType: widget.isMultiline
                    ? TextInputType.multiline
                    : widget.keyboardType,
                onSubmitted: (text) {
                  setState(() {
                    _isReadOnlyModeEnabled = widget.readOnly ?? true;
                  });
                  widget.onSubmit?.call();
                },
                decoration: InputDecoration(
                    isDense: true,
                    contentPadding: widget._internalTextFieldPadding,
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    focusColor: widget.textColor,
                    focusedBorder: const UnderlineInputBorder(),
                    enabledBorder: InputBorder.none,
                    hintStyle: widget._hintTextStyle),
              ),
            ),
          ),
          Visibility(
            visible: widget.showEditButton ?? true,
            child: CustomButton(
              icon: Icons.edit,
              onTap: () {
                setState(() {
                  _isReadOnlyModeEnabled = widget.readOnly ?? false;
                });
              },
            ),
          ),
          SizedBox(width: widget.showDeleteButton == true ? 5 : 0),
          Visibility(
            visible: widget.showDeleteButton ?? true,
            child: CustomButton(
              icon: Icons.delete,
              onTap: widget.onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
