import 'dart:io';

import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/custom_divider.dart';
import 'package:crunch/widgets/loading_overlay.dart';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_profile_screen.dart';

class UserProfile extends StatefulWidget {
  final double profileSize;
  const UserProfile({Key? key, this.profileSize = kSizeIconDefault})
      : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool menuVisible = false;
  ValueNotifier<bool> isProcessing = ValueNotifier(false);
  CustomPopupMenuController _controller = CustomPopupMenuController();

  Widget _getMenuItems({
    required List<String> texts,
    required List<void Function()> onTappedTexts,
    required List<Color> colors,
  }) {
    return ListView.separated(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      separatorBuilder: (context, _) {
        return const Divider(thickness: 1);
      },
      itemCount: texts.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: onTappedTexts[index],
          child: Text(
            texts[index],
            style: kTextStyleDefaultActiveText.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: colors[index]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPopupMenu(
          controller: _controller,
          menuBuilder: () => ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              color: kColorBG,
              width: 100,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: _getMenuItems(texts: [
                  'Profile',
                  'Settings',
                  'Sign Out'
                ], onTappedTexts: [
                  () {
                    _controller.hideMenu();
                    Navigator.pushNamed(context, EditProfileScreen.id);
                  },
                  () {},
                  () async {
                    _controller.hideMenu();
                    isProcessing.value = true;
                    showLoadingOverlay(
                        context: context, isVisible: isProcessing);
                    Provider.of<ProjectsHandler>(context, listen: false)
                        .signOut()
                        .then((value) {
                      isProcessing.value = false;
                      Navigator.pop(context);
                    });
                  }
                ], colors: [
                  kColorBlack,
                  kColorBlack,
                  Colors.red
                ]),
              ),
            ),
          ),
          arrowColor: kColorBG,
          barrierColor: Colors.blueGrey.withOpacity(0.01),
          pressType: PressType.singleClick,
          menuOnChange: (visible) {
            setState(() {
              menuVisible = visible;
            });
          },
          child: AnimatedScale(
            scale: menuVisible ? 1.25 : 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: CircleAvatar(
              backgroundImage:
                  Provider.of<ProjectsHandler>(context).getProfileImage != null
                      ? Image.memory(Provider.of<ProjectsHandler>(context)
                              .getProfileImage!)
                          .image
                      : AssetImage(paths[Paths.defaultUserAvatar]!),
              backgroundColor: kColorBG,
              radius: widget.profileSize,
            ),
          ),
        )
      ],
    );
  }
}
