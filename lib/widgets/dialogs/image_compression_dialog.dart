import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:lottie/lottie.dart';

import 'package:crunch/utils/formatter.dart';
import 'package:crunch/utils/constant.dart';
import 'package:crunch/widgets/custom_widgets/animated_text_field.dart';
import 'package:crunch/widgets/dialogs/loading_overlay.dart';
import 'package:crunch/widgets/rounded_button.dart';
import 'package:crunch/widgets/custom_widgets/image_compare.dart';

late Uint8List img;
Future<Uint8List?> imageCompressionDialog(
    {required BuildContext context,
    required String imgPath,
    required double cardWidth}) async {
  var img = await Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black26,
      barrierDismissible: true,
      pageBuilder: (context, _, __) {
        return ImageCompression(imgPath: imgPath, cardWidth: cardWidth);
      },
    ),
  );
  return img;
}

class ImageCompression extends StatefulWidget {
  final String imgPath;
  final double cardWidth;
  const ImageCompression(
      {Key? key, required this.imgPath, required this.cardWidth})
      : super(key: key);

  @override
  State<ImageCompression> createState() => ImageCompressionState();
}

class ImageCompressionState extends State<ImageCompression> {
  final TextEditingController _qualityController = TextEditingController();
  Completer<ui.Image> completer = Completer<ui.Image>();
  double quality = 80;
  late ImageProvider image;
  final double padding = 15;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    img = File(widget.imgPath).readAsBytesSync();
    image = Image.memory(img).image;
    image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }));

    _qualityController.text = quality.toStringAsFixed(0);
  }

  double _getQualityFromController() {
    return double.parse(
        _qualityController.text.isNotEmpty ? _qualityController.text : '0');
  }

  Future _compress() async {
    showLoadingOverlay(
        context: context,
        onCompleted: () => setState(() {}),
        asyncTask: () async {
          Uint8List? cache = await FlutterImageCompress.compressWithFile(
              widget.imgPath,
              quality: quality.toInt());
          if (cache != null) {
            setState(() {
              img = cache;
            });
          }
          return;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FutureBuilder(
        future: completer.future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    ImageCompare(
                      img1: Image.file(File(widget.imgPath)),
                      imgSize: Size(snapshot.data.width.toDouble(),
                          snapshot.data.height.toDouble()),
                      parentWidth: widget.cardWidth,
                      img2: Image.memory(img),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Formatter.getSize(size: img.lengthInBytes),
                      style: kTextStyleDefaultInactiveText,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: AnimatedTextField(
                            controller: _qualityController,
                            readOnly: false,
                            showDeleteButton: false,
                            autoFocus: false,
                            showEditButton: false,
                            keyboardType: TextInputType.number,
                            textFieldTextAlign: TextAlign.center,
                            internalTextFieldPadding:
                                const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 5),
                            onChanged: (t, _) {
                              setState(() {
                                quality = _getQualityFromController();
                              });
                            },
                            onSubmit: () {
                              _compress();
                            },
                          ),
                        ),
                        Text(
                          '%',
                          style: kTextStyleDefaultActiveText.copyWith(
                              fontSize: 10),
                        ),
                        Expanded(
                          flex: 6,
                          child: SliderTheme(
                            data: const SliderThemeData(
                              trackHeight: 2,
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 15),
                              thumbShape:
                                  RoundSliderThumbShape(enabledThumbRadius: 5),
                            ),
                            child: Slider.adaptive(
                              max: 100,
                              min: 0,
                              activeColor: kColorBlack,
                              inactiveColor: kColorBlack.withOpacity(0.1),
                              value: quality,
                              onChanged: (val) {
                                setState(() {
                                  quality = val;
                                  _qualityController.text =
                                      val.toStringAsFixed(0);
                                });
                              },
                              onChangeEnd: (_) {
                                _compress();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RoundedButton(
                          activeBorderColor: kColorBlack,
                          activeBGColor: Colors.white,
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 13),
                            child: Text(
                              'Cancel',
                              style: kTextStyleDefaultActiveText.copyWith(
                                  fontSize: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        RoundedButton(
                          activeBorderColor: kColorBlack,
                          activeBGColor: kColorBlack,
                          onTap: () {
                            Navigator.pop(context, img);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 13),
                            child: Text(
                              'Save',
                              style: kTextStyleDefaultActiveText.copyWith(
                                  fontSize: 10, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset(
                  paths[Paths.lottieLoading]!,
                  repeat: true,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
