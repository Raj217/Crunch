import 'package:flutter/material.dart';
import 'dart:math';

import 'package:crunch/utils/constant.dart';

class BoardsSlider extends StatefulWidget {
  final Stream stream;
  final double height;
  final double width;
  final double spacing;
  const BoardsSlider(
      {Key? key,
      required this.stream,
      this.height = 200,
      this.width = double.infinity,
      this.spacing = 20})
      : super(key: key);

  @override
  State<BoardsSlider> createState() => _BoardsSliderState();
}

class _BoardsSliderState extends State<BoardsSlider> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.stream,
        builder: (context, AsyncSnapshot snapshot) {
          return SizedBox(
              height: widget.height,
              width: widget.width,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: widget.height / 5),
                child: ListView.builder(
                    itemCount: snapshot.data != null ? snapshot.data.length : 0,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: widget.spacing),
                        child: _Board(
                          data: snapshot.data![index],
                          height: widget.height * 4 / 5,
                        ),
                      );
                    }),
              ));
        });
  }
}

class _Board extends StatelessWidget {
  final Map data;
  static const List<Color> _availableColorsForBG = [
    kColorBlue,
    kColorPurple,
    kColorOrange,
    kColorAquamarine
  ];
  final Color _color;
  final double height;
  final double width;
  _Board(
      {Key? key,
      required this.data,
      Color? color,
      required this.height,
      this.width = 250})
      : _color = color ??
            _availableColorsForBG[
                Random().nextInt(_availableColorsForBG.length)],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: height,
          width: width,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _color.withOpacity(0.2),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: height / 8, horizontal: width / 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: height - height / 4 - kSizeIconDefault,
                  width: width - width / 5 - kSizeIconDefault,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['project name'] ?? '',
                        style: kTextStyleDefaultHeader,
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Text(
                          data['project description'] ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: kTextStyleDefaultInactiveText.copyWith(
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_right_alt,
                  color: kColorBlack,
                  size: kSizeIconDefault,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
