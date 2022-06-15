import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_cropper/image_cropper.dart';

class CropImageScreen extends StatefulWidget {
  final String imagePath;
  const CropImageScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  CroppedFile? _croppedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Column()));
  }
}
