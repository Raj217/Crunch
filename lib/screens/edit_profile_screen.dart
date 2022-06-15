import 'dart:io';
import 'dart:typed_data';

import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/custom_app_bar.dart';
import 'package:crunch/widgets/custom_text_field.dart';
import 'package:crunch/widgets/editable_profile_image.dart';
import 'package:crunch/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

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
  Directory? tempDir;

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
    storeImageLocally();
  }

  Future<void> storeImageLocally() async {
    Uint8List? img =
        Provider.of<ProjectsHandler>(context, listen: false).getProfileImage;

    File? file;
    if (img != null) {
      tempDir = await getTemporaryDirectory();
      String imgPath =
          '${tempDir!.path}/${Provider.of<ProjectsHandler>(context, listen: false).getCurrentUser?.email}.jng';
      file = File(imgPath);
      file.writeAsBytesSync(img);
    }
    setState(() {
      imgPath = file != null ? file.path : '';
    });
    return;
  }

  @override
  void dispose() {
    super.dispose();
    tempDir?.delete(recursive: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              isProfileButtonVisible: false,
              isBackButtonVisible: true,
              isSearchBarVisible: false,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EditableProfileImage(
                    imagePath: imgPath,
                  ),
                  const SizedBox(height: 20),
                  editBox(title: 'username', controller: userName),
                  const SizedBox(height: 10),
                  editBox(title: 'email', controller: email, readOnly: true),
                  const SizedBox(height: 50),
                  RoundedButton(
                    height: 40,
                    width: 200,
                    onTap: () {
                      Provider.of<ProjectsHandler>(context, listen: false)
                          .setUserName = userName.text;
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Save',
                      style: kTextStyleDefaultActiveText,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
