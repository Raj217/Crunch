import 'package:flutter/material.dart';

// ----------------------------------- Color -----------------------------------
const Color kColorBG = Colors.white;
const Color kColorBlack = Color(0xFF303030);
const Color kColorGray = Color(0xFFE7E7E7);
const Color kColorGrayMedium = Color(0xFFC7C7C7);
const Color kColorGrayDark = Color(0xFFB0B0B0);

final Color kColorBlue = Colors.lightBlue.shade200;
const Color kColorBlueDark = Colors.blue;
const Color kColorPurple = Color(0xFFC58BFF);
const Color kColorOrange = Color(0xFFF4A74F);
const Color kColorAquamarine = Color(0xFF41ECA0);

// ----------------------------------- Paths -----------------------------------
enum Paths {
  lottieLoading,
  lottieLoadImage,
  lottieDelete,
  lottieProfile,
  lottieSettings,
  lottieSignOut,
  defaultUserAvatar,
  googleLogo
}

Map<Paths, String> paths = {
  Paths.lottieLoading: 'assets/lottie/loading.json',
  Paths.lottieLoadImage: 'assets/lottie/load_image.json',
  Paths.lottieDelete: 'assets/lottie/delete.json',
  Paths.lottieProfile: 'assets/lottie/profile.json',
  Paths.lottieSettings: 'assets/lottie/settings.json',
  Paths.lottieSignOut: 'assets/lottie/sign_out.json',
  Paths.defaultUserAvatar: 'assets/default images/user.png',
  Paths.googleLogo: 'assets/default images/google.png'
};

// ----------------------------------- Size -----------------------------------
const double kAppStylingWidthLimit = 600;
const double kSizeIconDefault = 15;

// --------------------------------- TextStyle ---------------------------------
const TextStyle _kDefaultStylisedFontFamily =
    TextStyle(fontFamily: 'Belgates', decoration: TextDecoration.none);
const TextStyle _kDefaultFontFamily =
    TextStyle(fontFamily: 'Poppins', decoration: TextDecoration.none);

final TextStyle kTextStyleDefaultStylised =
    _kDefaultStylisedFontFamily.copyWith(fontSize: 25, color: kColorBlack);
final TextStyle kTextStyleDefaultHeader = _kDefaultFontFamily.copyWith(
    fontWeight: FontWeight.w600, color: kColorBlack);
final TextStyle kTextStyleDefaultActiveText = _kDefaultFontFamily.copyWith(
    color: kColorBlack, fontWeight: FontWeight.w600);
final TextStyle kTextStyleDefaultInactiveText = _kDefaultFontFamily.copyWith(
    color: kColorBlack, fontWeight: FontWeight.w300);
