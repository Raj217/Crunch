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
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool menuVisible = false;
  ValueNotifier<bool> isProcessing = ValueNotifier(false);

  Column _getMenuItems({
    required List<String> texts,
    required List<void Function()> onTappedTexts,
    required List<Color> colors,
  }) {
    List<Widget> children = [];

    for (int index = 0; index < texts.length; index++) {
      children.add(
        InkWell(
          onTap: onTappedTexts[index],
          child: Text(
            texts[index],
            style: kTextStyleDefaultActiveText.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: colors[index]),
          ),
        ),
      );
      if (index != texts.length - 1) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: CustomDivider(
              thickness: 0.5,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPopupMenu(
          menuBuilder: () => ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              color: kColorBG,
              child: IntrinsicWidth(
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _getMenuItems(texts: [
                      'Profile',
                      'Sign Out & Exit'
                    ], onTappedTexts: [
                      () {
                        Navigator.pushNamed(context, EditProfileScreen.id);
                      },
                      () async {
                        isProcessing.value = true;
                        showLoadingOverlay(
                            context: context, isVisible: isProcessing);
                        Provider.of<ProjectsHandler>(context, listen: false)
                            .signOut()
                            .then((value) {
                          isProcessing.value = false;
                          exit(0);
                        });
                      }
                    ], colors: [
                      kColorBlack,
                      Colors.red
                    ])),
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
              radius: kSizeIconDefault,
            ),
          ),
        )
      ],
    );
  }
}
