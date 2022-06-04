import 'package:flutter/material.dart';

import 'package:crunch/utils/constant.dart';
import 'custom_divider.dart';
import 'icons/board_icon.dart';
import 'package:crunch/widgets/search_bar.dart';
import 'package:crunch/widgets/user_profile.dart';

class CustomAppBar extends StatelessWidget {
  bool isLargeScreen = false;
  final bool isSearchBarVisible;
  final bool isBackButtonVisible;
  CustomAppBar(
      {Key? key,
      this.isSearchBarVisible = true,
      this.isBackButtonVisible = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    isLargeScreen = MediaQuery.of(context).size.width > kAppStylingWidthLimit
        ? true
        : false;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 20 : 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Visibility(
                visible: isBackButtonVisible,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: kColorBlack,
                      size: kSizeIconDefault,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('Crunch', style: kTextStyleDefaultStylised),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: CustomDivider(
                  length: 20,
                  direction: Axis.vertical,
                ),
              ),
              BoardIcon(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Visibility(
                  visible: isLargeScreen,
                  child: Text('Boards', style: kTextStyleDefaultHeader),
                ),
              ),
              const CustomDivider(
                length: 20,
                direction: Axis.vertical,
              ),
              Visibility(
                visible: isSearchBarVisible,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SearchBar(
                    width: isLargeScreen ? 200 : 130,
                  ),
                ),
              ),
            ],
          ),
          const UserProfile(),
        ],
      ),
    );
  }
}
