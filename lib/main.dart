import 'package:crunch/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/screens/splash_screen.dart';
import 'package:crunch/utils/constant.dart';

void main() async {
  runApp(const Crunch());
}

class Crunch extends StatelessWidget {
  const Crunch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ProjectsHandler(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Crunch',
        theme: ThemeData.light().copyWith(
            backgroundColor: kColorBG,
            textSelectionTheme: const TextSelectionThemeData(
                selectionHandleColor: kColorBlack)),
        initialRoute: SplashScreen.id,
        routes: {
          SplashScreen.id: (BuildContext context) => const SplashScreen(),
          HomeScreen.id: (BuildContext context) => const HomeScreen()
        },
      ),
    );
  }
}
