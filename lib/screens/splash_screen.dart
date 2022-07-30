import 'dart:io';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:crunch/screens/home_screen.dart';
import 'package:crunch/screens/auth_screen.dart';
import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';

class SplashScreen extends StatefulWidget {
  static const String id = "Splash Screen";
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieLoadingAnimController;

  @override
  void initState() {
    super.initState();

    // TODO: Make it global and use it whenever necessary as an overlay
    _lottieLoadingAnimController = AnimationController(vsync: this);

    Provider.of<ProjectsHandler>(context, listen: false)
        .connect()
        .then((userExists) {
      if (userExists) {
        Navigator.pushNamed(context, HomeScreen.id).then((_) =>
            Navigator.pushNamed(context, AuthScreen.id)
                .then((value) => Navigator.pushNamed(context, AuthScreen.id)));
      } else {
        Navigator.pushNamed(context, AuthScreen.id).then((_) => exit(0));
      }
    });
  }

  @override
  void dispose() {
    _lottieLoadingAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'App name',
                child: Text(
                  'Crunch',
                  style: kTextStyleDefaultStylised.copyWith(fontSize: 50),
                ),
              ),
              SizedBox(
                height: 200,
                child: Lottie.asset(paths[Paths.lottieLoading]!,
                    controller: _lottieLoadingAnimController,
                    onLoaded: (controller) {
                  _lottieLoadingAnimController.duration = controller.duration;
                  _lottieLoadingAnimController.repeat();
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
