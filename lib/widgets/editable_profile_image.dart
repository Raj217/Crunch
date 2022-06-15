import 'dart:typed_data';

import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

import '../utils/constant.dart';
import 'dart:io';

import 'package:crunch/screens/crop_image_screen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class EditableProfileImage extends StatefulWidget {
  String imagePath;
  EditableProfileImage({Key? key, this.imagePath = ''}) : super(key: key);

  @override
  State<EditableProfileImage> createState() => _EditableProfileImageState();
}

class _EditableProfileImageState extends State<EditableProfileImage> {
  Image? croppedImage;
  List<Widget> children = [];
  File? file;
  Directory? tempDir;

  @override
  Widget build(BuildContext context) {
    if (widget.imagePath == '' && file == null) {
      Uint8List? img = Provider.of<ProjectsHandler>(context).getProfileImage;
      children.add(SizedBox(
        height: 100,
        width: 100,
        child: CircleAvatar(
          backgroundImage: img != null
              ? Image.memory(img).image
              : AssetImage(paths[Paths.defaultUserAvatar]!),
        ),
      ));
    } else {
      children.add(
        GestureDetector(
          onTap: () async {
            CroppedFile? croppedFile = await ImageCropper().cropImage(
              sourcePath:
                  widget.imagePath.isNotEmpty ? widget.imagePath : file!.path,
              cropStyle: CropStyle.circle,
              uiSettings: [
                AndroidUiSettings(
                    toolbarTitle: 'Cropper',
                    toolbarColor: Colors.black,
                    activeControlsWidgetColor: kColorBlueDark,
                    toolbarWidgetColor: Colors.white,
                    initAspectRatio: CropAspectRatioPreset.original,
                    dimmedLayerColor: Colors.black,
                    lockAspectRatio: false),
                IOSUiSettings(
                  title: 'Cropper',
                ),
              ],
            );
            if (croppedFile != null) {
              croppedImage = Image.memory(await croppedFile.readAsBytes());
              await Provider.of<ProjectsHandler>(context, listen: false)
                  .setProfileImage(await croppedFile.readAsBytes());
              setState(() {});
            }
          },
          child: SizedBox(
            height: 100,
            width: 100,
            child: CircleAvatar(
              backgroundImage: (croppedImage == null)
                  ? FileImage(File(widget.imagePath))
                  : croppedImage!.image,
            ),
          ),
        ),
      );
    }
    children.add(
      GestureDetector(
        onTap: () async {
          FilePickerResult? filePicked = await FilePicker.platform.pickFiles(
              type: FileType.image,
              dialogTitle: 'Select your profile picture',
              withData: true);

          if (filePicked != null) {
            await Provider.of<ProjectsHandler>(context, listen: false)
                .setProfileImage(
                    await File(filePicked.paths[0]!).readAsBytes());
            setState(() {
              widget.imagePath = filePicked.paths[0] ?? '';
            });
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: const [
            Icon(Icons.circle, color: kColorGray, size: kSizeIconDefault * 2.5),
            Icon(
              Icons.edit,
              color: kColorBlack,
              size: kSizeIconDefault * 1.5,
            ),
          ],
        ),
      ),
    );

    return Stack(
      alignment: Alignment.bottomRight,
      children: children,
    );
  }
}
