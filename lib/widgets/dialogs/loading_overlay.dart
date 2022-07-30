import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

import '../../utils/constant.dart';

Future<void> showLoadingOverlay(
    {required BuildContext context,
    ValueNotifier<bool>? isVisible,
    void Function()? onCompleted,
    Future Function()? asyncTask}) async {
  isVisible ??= ValueNotifier(true);
  if (asyncTask != null) {
    asyncTask().then((value) => isVisible!.value = false);
  }
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black12,
      pageBuilder: (context, _, __) {
        return ValueListenableBuilder<bool>(
            valueListenable: isVisible!,
            builder: (BuildContext context, visible, Widget? child) {
              if (!visible) {
                Navigator.pop(context);
              }
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
            });
      },
    ),
  ).then((value) {
    if (onCompleted != null) {
      onCompleted();
    }
  });
}
