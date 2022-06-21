import 'dart:typed_data';

import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:crunch/utils/constant.dart';
import 'dart:io';

import 'package:crunch/screens/crop_image_screen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class EditableProfileImage extends StatelessWidget {
  final String imagePath;
  final bool showCurrentlyStoredProfileImage;
  final void Function(String newImage)? onImgUpdate;
  final void Function()? onBeginChoosingNewProfileImage;
  final void Function()? onEndChoosingNewProfileImage;
  EditableProfileImage(
      {Key? key,
      this.imagePath = '',
      this.showCurrentlyStoredProfileImage = false,
      this.onBeginChoosingNewProfileImage,
      this.onEndChoosingNewProfileImage,
      this.onImgUpdate})
      : super(key: key);

  Image? _croppedImage;
  final List<Widget> _children = [];
  final double lottieSize = 50;

  Future<String> storeImageLocally(Uint8List img) async {
    Directory tempDir = await getTemporaryDirectory();
    String imgPath = '${tempDir.path}/temp.jpg';
    File file = File(imgPath);

    file = await file.writeAsBytes(img, flush: true);
    return file.path;
  }

  GestureDetector cropableCircleAvatar(ImageProvider img) {
    return GestureDetector(
      onTap: () async {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: imagePath,
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
        if (croppedFile != null && onImgUpdate != null) {
          Uint8List img = await croppedFile.readAsBytes();
          _croppedImage = Image.memory(img);
          String imgPath = await storeImageLocally(img);
          onImgUpdate!(imgPath);
        }
      },
      child: SizedBox(
        height: 100,
        width: 100,
        child: CircleAvatar(backgroundImage: img),
      ),
    );
  }

  SizedBox getDefaultCircleAvatar() {
    return SizedBox(
      height: 100,
      width: 100,
      child: CircleAvatar(
        backgroundImage: AssetImage(paths[Paths.defaultUserAvatar]!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showCurrentlyStoredProfileImage) {
      // Due to the bug of not updating the image even after flushing
      Uint8List? img =
          Provider.of<ProjectsHandler>(context, listen: false).getProfileImage;
      if (img != null) {
        _children.add(cropableCircleAvatar(Image.memory(img).image));
      } else {
        _children.add(getDefaultCircleAvatar());
      }
    } else {
      if (imagePath.length <= 4) {
        _children.add(getDefaultCircleAvatar());
      } else {
        _children.add(cropableCircleAvatar((_croppedImage == null)
            ? Image.file(File(imagePath)).image
            : _croppedImage!.image));
      }
    }

    _children.add(
      GestureDetector(
        onTap: () async {
          bool chooseImage = false;
          bool setImageToNone = false;
          await showDialog(
              context: context,
              builder: (context) {
                return Center(
                  child: WillPopScope(
                    onWillPop: () async {
                      chooseImage = false;
                      setImageToNone = false;
                      return true;
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kColorBG,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                chooseImage = true;
                                setImageToNone = false;
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: lottieSize,
                                    width: lottieSize,
                                    child: Lottie.asset(
                                        paths[Paths.lottieLoadImage]!,
                                        repeat: true),
                                  ),
                                  Text(
                                    'Choose an image',
                                    style: kTextStyleDefaultInactiveText,
                                  )
                                ],
                              ),
                            ),
                            Visibility(
                              visible: imagePath.isNotEmpty ||
                                  _croppedImage != null ||
                                  showCurrentlyStoredProfileImage,
                              child: const Divider(
                                thickness: 1,
                              ),
                            ),
                            Visibility(
                              visible: imagePath.isNotEmpty ||
                                  _croppedImage != null ||
                                  showCurrentlyStoredProfileImage,
                              child: GestureDetector(
                                onTap: () {
                                  chooseImage = false;
                                  setImageToNone = true;
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: lottieSize,
                                      width: lottieSize,
                                      child: Lottie.asset(
                                          paths[Paths.lottieDelete]!,
                                          repeat: true),
                                    ),
                                    Text('Remove image',
                                        style: kTextStyleDefaultInactiveText)
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
          if (chooseImage) {
            if (onBeginChoosingNewProfileImage != null) {
              onBeginChoosingNewProfileImage!();
            }
            FilePickerResult? filePicked = await FilePicker.platform.pickFiles(
                type: FileType.image,
                dialogTitle: 'Select your profile picture',
                withData: true);

            if (filePicked != null && onImgUpdate != null) {
              onImgUpdate!(filePicked.paths[0] ?? '');
            }
            if (onEndChoosingNewProfileImage != null) {
              onEndChoosingNewProfileImage!();
            }
          } else if (setImageToNone) {
            if (onImgUpdate != null) {
              onImgUpdate!('none');
            }
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
      children: _children,
    );
  }
}
