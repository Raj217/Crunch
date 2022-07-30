import 'package:flutter/material.dart';

import 'package:crunch/utils/constant.dart';
import 'package:crunch/widgets/dialogs/view_image.dart';

class ImageCompare extends StatefulWidget {
  final Image img1;
  final Image img2;
  final Size imgSize;
  final double parentWidth;
  final double sliderWidth;
  final double sliderIconSize;
  const ImageCompare({
    Key? key,
    required this.img1,
    required this.img2,
    required this.imgSize,
    required this.parentWidth,
    this.sliderWidth = 4,
    this.sliderIconSize = 25,
  }) : super(key: key);

  @override
  State<ImageCompare> createState() => _ImageCompareState();
}

class _ImageCompareState extends State<ImageCompare> {
  late double _height;
  double _left = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _height =
        (widget.parentWidth / widget.imgSize.width) * widget.imgSize.height;
    _left = widget.parentWidth / 2;
  }

  GestureDetector _liveImage(
      {required Image img,
      required Widget heroChild,
      String? overlayText,
      AlignmentGeometry textAlign = Alignment.topLeft}) {
    return GestureDetector(
      onTap: () {
        viewImage(
            context: context,
            imageWidth: widget.imgSize.width.toInt(),
            image: img.image,
            tag: img);
      },
      child: Stack(
        children: [
          Hero(
            tag: img,
            child: heroChild,
          ),
          Positioned(
            left: textAlign == Alignment.topLeft ? 5 : null,
            right: textAlign == Alignment.topRight ? 5 : null,
            top: 3,
            child: Text(
              overlayText ?? '',
              style: kTextStyleDefaultActiveText.copyWith(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _liveImage(
          // TODO: Not completed
          img: widget.img1,
          heroChild: widget.img1,
          overlayText: 'Before',
        ),
        Positioned(
          right: 0,
          child: _liveImage(
            img: widget.img2,
            overlayText: 'After',
            textAlign: Alignment.topRight,
            heroChild: Container(
              height: _height,
              width: widget.parentWidth - _left,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: widget.img2.image,
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.centerRight),
              ),
            ),
          ),
        ),
        Positioned(
          left: _left,
          child: Container(
            height: _height,
            width: widget.sliderWidth,
            color: kColorBlack,
          ),
        ),
        Positioned(
          top: _height / 2 - widget.sliderIconSize,
          left: _left - widget.sliderIconSize + widget.sliderWidth / 2,
          child: GestureDetector(
            onPanUpdate: (DragUpdateDetails? drag) {
              if (drag != null) {
                double x = drag.globalPosition.dx - widget.sliderIconSize * 2;
                if (x < 0) {
                  x = 0;
                } else if (x > widget.parentWidth) {
                  x = widget.parentWidth - widget.sliderWidth;
                }
                setState(() {
                  _left = x;
                });
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.circle,
                  color: Colors.transparent,
                  size: widget.sliderIconSize * 2,
                ),
                Container(
                  height: widget.sliderIconSize,
                  width: widget.sliderIconSize,
                  decoration: BoxDecoration(
                    color: kColorBlack.withOpacity(0.6),
                    border: Border.all(
                        color: kColorBlack, width: widget.sliderWidth / 2),
                    borderRadius:
                        BorderRadius.circular(widget.sliderIconSize / 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: widget.sliderIconSize / 3,
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: widget.sliderIconSize / 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
