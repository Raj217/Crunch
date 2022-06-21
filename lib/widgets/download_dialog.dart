import 'package:crunch/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

Future<void> downloadDialog(
  BuildContext context, {
  double? height,
  double? width,
  String title = 'Downloading',
  required Stream<double> downloadStream,
  String message = 'Would you like to delete ',
}) async {
  Size screenSize = MediaQuery.of(context).size;
  height ??= screenSize.height / 4;
  width ??= screenSize.width / 1.2;
  await showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (_) => StreamBuilder<double>(
      stream: downloadStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data == 1) {
          Navigator.pop(context);
        }
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: kColorBG,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: kTextStyleDefaultStylised),
                  Center(
                    child: SizedBox(
                      height: height! / 3.5,
                      width: width! - 10,
                      child: LiquidLinearProgressIndicator(
                        value: snapshot.hasData
                            ? snapshot.data
                            : 0, // Defaults to 0.5.
                        valueColor: AlwaysStoppedAnimation(
                            kColorBlue), // Defaults to the current Theme's accentColor.
                        backgroundColor: Colors
                            .white, // Defaults to the current Theme's backgroundColor.
                        borderColor: kColorBlueDark,
                        borderWidth: 2,
                        borderRadius: 10,
                        direction: Axis
                            .horizontal, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                        center: Text(
                          "${((snapshot.hasData ? snapshot.data : 0) * 100).toStringAsFixed(2)} %",
                          style: kTextStyleDefaultActiveText.copyWith(
                              fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                  /*
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          return;
                        },
                        child: Text(
                          'continue in background',
                          style: kTextStyleDefaultActiveText.copyWith(
                              color: kColorBlue, fontSize: 15),
                        ),
                      ),
                    ],
                  )*/
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  return;
}
