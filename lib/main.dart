import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:crunch/screens/auth_screen.dart';
import 'package:crunch/screens/edit_profile_screen.dart';
import 'package:crunch/screens/home_screen.dart';
import 'package:crunch/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
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
            colorScheme: ColorScheme.fromSwatch(accentColor: kColorBlack),
            textSelectionTheme: const TextSelectionThemeData(
                selectionHandleColor: kColorBlack)),
        initialRoute: SplashScreen.id,
        routes: {
          AuthScreen.id: (BuildContext context) => const AuthScreen(),
          EditProfileScreen.id: (BuildContext context) =>
              const EditProfileScreen(),
          SplashScreen.id: (BuildContext context) => const SplashScreen(),
          HomeScreen.id: (BuildContext context) => const HomeScreen(),
          SettingsScreen.id: (BuildContext context) => SettingsScreen()
        },
      ),
    );
  }
}
