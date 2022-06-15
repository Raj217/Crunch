import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

import '../utils/constant.dart';

/// [invert] is used to invert the bool value
Future<void> showLoadingOverlay(
    {required BuildContext context,
    required ValueNotifier<bool> isVisible,
    bool invert = false}) async {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, _, __) {
        return ValueListenableBuilder<bool>(
            valueListenable: isVisible,
            builder: (BuildContext context, isVisible, Widget? child) {
              if (invert) {
                isVisible = !isVisible;
              }
              if (!isVisible) {
                Navigator.pop(context);
              }
              return Center(
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Lottie.asset(
                    paths[Paths.lottieLoading]!,
                    repeat: true,
                  ),
                ),
              );
            });
      },
    ),
  );
}
