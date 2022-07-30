import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:card_swiper/card_swiper.dart';
import 'package:crunch/utils/constant.dart';
import 'package:crunch/widgets/dialogs/view_image.dart';
import 'package:flutter/cupertino.dart';

class ImageSwiper extends StatefulWidget {
  final double itemWidth;
  final Stream<List<Uint8List>> images;
  const ImageSwiper({Key? key, required this.itemWidth, required this.images})
      : super(key: key);

  @override
  State<ImageSwiper> createState() => _ImageSwiperState();
}

class _ImageSwiperState extends State<ImageSwiper> {
  List<Uint8List> images = [];
  @override
  Widget build(BuildContext context) {
    widget.images.listen((List<Uint8List> imgs) {
      setState(() {
        images.addAll(imgs);
      });
    });
    return Swiper(
      itemCount: images.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            Image img = Image.memory(images[index]);
            Completer<ui.Image> completer = Completer<ui.Image>();
            img.image
                .resolve(const ImageConfiguration())
                .addListener(ImageStreamListener((ImageInfo info, bool _) {
              completer.complete(info.image);
            }));
            viewImage(context: context, image: img.image, tag: images[index]);
          },
          child: Hero(
            tag: images[index],
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                images[index],
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
      itemWidth: widget.itemWidth - 30,
      layout: SwiperLayout.STACK,
      pagination: const SwiperPagination(
        builder: DotSwiperPaginationBuilder(
            activeColor: kColorBlack,
            color: kColorGray,
            size: 5,
            activeSize: 7),
      ),
    );
  }
}
