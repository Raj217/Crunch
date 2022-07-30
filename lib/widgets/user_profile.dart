import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';

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
    return CircleAvatar(
      backgroundImage: Provider.of<ProjectsHandler>(context).getProfileImage !=
              null
          ? Image.memory(Provider.of<ProjectsHandler>(context).getProfileImage!)
              .image
          : AssetImage(paths[Paths.defaultUserAvatar]!),
      backgroundColor: kColorBG,
      radius: widget.profileSize,
    );
  }
}
