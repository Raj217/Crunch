import 'package:flutter/material.dart';

import 'package:crunch/utils/constant.dart';

class SearchBar extends StatefulWidget {
  final double height;
  final double width;
  final IconData iconData;
  final Color bgColor;
  final Color iconColor;
  final double iconSize;
  final void Function(String)? onChanged;
  SearchBar(
      {Key? key,
      this.height = kSizeIconDefault,
      this.width = 10,
      IconData? icon,
      this.bgColor = kColorGray,
      this.iconColor = kColorBlack,
      this.iconSize = kSizeIconDefault,
      this.onChanged})
      : iconData = icon ?? Icons.search,
        super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _textEditingController;
  bool _isActive = false;
  bool isLargeScreen = true;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _isActive = !_isActive;
          setState(() {});
        },
        child: SizedBox(
          width: widget.width,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Icon(
                Icons.circle,
                size: widget.height + 20,
                color: Colors.transparent,
              ),
              AnimatedContainer(
                height: widget.height *
                    3 /
                    2, // To give some breathing room for the text
                width: _isActive ? widget.width : 15,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isActive ? widget.bgColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                duration: const Duration(milliseconds: 200),
              ),
              _isActive
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: _textEditingController,
                        autofocus: true,
                        onChanged: widget.onChanged,
                        style:
                            kTextStyleDefaultActiveText.copyWith(fontSize: 10),
                        onSubmitted: (val) {
                          setState(() {
                            _isActive = false;
                          });
                        },
                        cursorColor: kColorGrayDark,
                        decoration: InputDecoration(
                          hintText: 'Search Project...',
                          focusColor: kColorBlack,
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          hintStyle: kTextStyleDefaultInactiveText.copyWith(
                              fontSize: 10),
                        ),
                      ),
                    )
                  : const SizedBox(),
              AnimatedPadding(
                padding: _isActive
                    ? EdgeInsets.only(left: widget.width - widget.iconSize)
                    : EdgeInsets.zero,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.iconData,
                  color: widget.iconColor,
                  size: widget.iconSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
