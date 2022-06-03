import 'package:flutter/material.dart';

// ----------------------------------- Color -----------------------------------
const Color kColorBG = Color(0xFFDED2D2);
const Color kColorBlack = Color(0xFF303030);
const Color kColorGray = Color(0xFFE7E7E7);
const Color kColorGrayMedium = Color(0xFFC7C7C7);
const Color kColorGrayDark = Color(0xFFB0B0B0);

const Color kColorBlue = Color(0xFF72DDF7);
const Color kColorPurple = Color(0xFFC58BFF);
const Color kColorOrange = Color(0xFFF4A74F);
const Color kColorAquamarine = Color(0xFF41ECA0);

// ----------------------------------- Paths -----------------------------------
enum Paths { lottieLoading }

Map<Paths, String> paths = {Paths.lottieLoading: 'assets/lottie/loading.json'};

// ----------------------------------- Size -----------------------------------
const double kAppStylingWidthLimit = 600;
const double kSizeIconDefault = 15;

// --------------------------------- TextStyle ---------------------------------
const TextStyle _kDefaultStylisedFontFamily = TextStyle(fontFamily: 'Belgates');
const TextStyle _kDefaultFontFamily = TextStyle(fontFamily: 'Poppins');
final TextStyle kTextStyleDefaultLogo =
    _kDefaultStylisedFontFamily.copyWith(fontSize: 25, color: kColorBlack);
final TextStyle kTextStyleDefaultHeader = _kDefaultFontFamily.copyWith(
    fontWeight: FontWeight.w600, color: kColorBlack);
final TextStyle kTextStyleDefaultActiveText = _kDefaultFontFamily.copyWith(
    color: kColorBlack, fontWeight: FontWeight.w600);
final TextStyle kTextStyleDefaultInactiveText = _kDefaultFontFamily.copyWith(
    color: kColorBlack, fontWeight: FontWeight.w300);
