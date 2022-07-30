import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/custom_widgets/custom_app_bar.dart';
import 'package:crunch/widgets/custom_widgets/custom_text_field.dart';
import 'package:crunch/widgets/editable_profile_image.dart';
import 'package:crunch/widgets/rounded_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  static String id = 'Edit Profile Screen';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController userName = TextEditingController();
  TextEditingController email = TextEditingController();
  String imgPath = '';
  bool isProcessing = false;
  File? file;

  Column editBox(
      {required String title,
      required TextEditingController controller,
      bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: kTextStyleDefaultActiveText.copyWith(fontSize: 13),
        ),
        CustomTextField(
          controller: controller,
          hintText: title,
          readOnly: readOnly,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    userName.text = Provider.of<ProjectsHandler>(context, listen: false)
            .getCurrentUser
            ?.displayName ??
        '';
    email.text = Provider.of<ProjectsHandler>(context, listen: false)
            .getCurrentUser
            ?.email ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomAppBar(
          isBackButtonVisible: true,
          isSearchBarVisible: false,
          isMenuVisible: false,
          context: context,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isProcessing ? 1 : 0,
                  child: SizedBox(
                    height: 80,
                    child: Lottie.asset(
                      paths[Paths.lottieLoading]!,
                    ),
                  ),
                ),
                EditableProfileImage(
                    imagePath: imgPath,
                    showCurrentlyStoredProfileImage: imgPath == '',
                    onImgUpdate: (String newImg) {
                      setState(() {
                        imgPath = newImg;
                      });
                    },
                    onBeginChoosingNewProfileImage: () {
                      setState(() {
                        isProcessing = true;
                      });
                    },
                    onEndChoosingNewProfileImage: () {
                      setState(() {
                        isProcessing = false;
                      });
                    }),
                const SizedBox(height: 20),
                editBox(title: 'username', controller: userName),
                const SizedBox(height: 10),
                editBox(title: 'email', controller: email, readOnly: true),
                const SizedBox(height: 50),
                RoundedButton(
                  height: 40,
                  width: 200,
                  onTap: () async {
                    setState(() {
                      isProcessing = true;
                    });
                    Provider.of<ProjectsHandler>(context, listen: false)
                        .setUserName = userName.text;
                    if (imgPath.length > 4) {
                      await Provider.of<ProjectsHandler>(context, listen: false)
                          .setProfileImage(await File(imgPath).readAsBytes());
                    } else if (imgPath == 'none') {
                      await Provider.of<ProjectsHandler>(context, listen: false)
                          .deleteProfileImage();
                    }
                    isProcessing = false;
                    // TODO: Do as suggested
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Save',
                    style: kTextStyleDefaultActiveText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
