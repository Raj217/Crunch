import 'package:flutter/material.dart';

class CustomAnimatedWidget extends StatefulWidget {
  final double boxHeight;
  final double boxWidth;
  final double gap;
  final Duration animDuration;
  final List<Widget> _children;
  final ValueNotifier<int> _currentlyVisibleChild;
  final Curve animCurve;
  final Axis direction;
  CustomAnimatedWidget(
      {Key? key,
      this.boxWidth = 300,
      this.boxHeight = 40,
      this.gap = 60,
      required this.animDuration,
      List<Widget>? children,
      ValueNotifier<int>? currentVisibleChild,
      this.animCurve = Curves.easeInOutQuint,
      this.direction = Axis.horizontal})
      : _currentlyVisibleChild = currentVisibleChild ?? ValueNotifier<int>(0),
        _children = children ?? [],
        super(key: key);

  @override
  State<CustomAnimatedWidget> createState() => _CustomAnimatedWidgetState();
}

class _CustomAnimatedWidgetState extends State<CustomAnimatedWidget> {
  List<AnimatedPositioned> convertChildren(
      {required int currentlyVisibleChild}) {
    List<AnimatedPositioned> out = [];
    for (int i = 0; i < widget._children.length; i++) {
      out.add(
        AnimatedPositioned(
          left: widget.direction == Axis.horizontal
              ? (i - currentlyVisibleChild) * (widget.boxWidth + widget.gap)
              : null,
          top: widget.direction == Axis.vertical
              ? (i - currentlyVisibleChild) * (widget.boxHeight + widget.gap)
              : null,
          curve: widget.animCurve,
          duration: widget.animDuration,
          child: widget._children[i],
        ),
      );
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: widget._currentlyVisibleChild,
        builder: (context, currentlyVisibleChildren, _) {
          List<AnimatedPositioned> children =
              convertChildren(currentlyVisibleChild: currentlyVisibleChildren);
          return SizedBox(
              width: widget.boxWidth,
              height: widget.boxHeight,
              child: Stack(alignment: Alignment.center, children: children));
        });
  }
}
