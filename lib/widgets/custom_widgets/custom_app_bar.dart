import 'package:crunch/screens/settings_screen.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/custom_widgets/custom_divider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:crunch/utils/constant.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../screens/edit_profile_screen.dart';
import '../icons/board_icon.dart';
import 'package:crunch/widgets/search_bar.dart';

class CustomAppBar extends StatefulWidget {
  final BuildContext context;
  final bool isSearchBarVisible;
  final bool isBackButtonVisible;
  final bool isMenuVisible;
  final Widget child;
  final int animDuration;
  final void Function(String)? onSearchChanged;
  const CustomAppBar(
      {Key? key,
      required this.context,
      this.isSearchBarVisible = true,
      this.isBackButtonVisible = false,
      this.isMenuVisible = true,
      required this.child,
      this.onSearchChanged,
      this.animDuration = 400})
      : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  List<String> lottieAnimations = [
    paths[Paths.lottieProfile]!,
    paths[Paths.lottieSettings]!,
    paths[Paths.lottieSignOut]!
  ];
  List<String> sliderOptions = ['Profile', 'Settings', 'Sign out'];
  List<Color?> sliderColor = [null, null, Colors.redAccent];

  final GlobalKey<SliderDrawerState> _sliderKey =
      GlobalKey<SliderDrawerState>();
  GestureDetector _sliderItem(
      {required String lottieAnimation,
      required String text,
      required void Function()? onTap,
      Color? color = kColorBlack}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              height: kSizeIconDefault + 10,
              width: kSizeIconDefault + 10,
              child: Lottie.asset(lottieAnimation, repeat: true),
            ),
            const SizedBox(width: 10),
            Text(text,
                style: kTextStyleDefaultActiveText.copyWith(color: color))
          ],
        ),
      ),
    );
  }

  Padding _getSlider(
      {String? userName,
      required ImageProvider img,
      required List<void Function()> sliderOptionsOnTap}) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage: img,
          ),
          Visibility(
            visible: userName != null,
            child: Text(
              userName ?? '',
              style: kTextStyleDefaultStylised,
            ),
          ),
          ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _sliderItem(
                  lottieAnimation: lottieAnimations[index],
                  text: sliderOptions[index],
                  color: sliderColor[index],
                  onTap: sliderOptionsOnTap[index],
                );
              },
              separatorBuilder: (context, _) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomDivider(thickness: 1),
                );
              },
              itemCount: 3),
        ],
      ),
    );
  }

  Row _getAppBarContent({required isLargeScreen}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Visibility(
          visible: widget.isBackButtonVisible,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Stack(
                alignment: Alignment.center,
                children: const [
                  Icon(Icons.circle,
                      color: Colors.transparent, size: kSizeIconDefault + 20),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: kColorBlack,
                    size: kSizeIconDefault,
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: !widget.isBackButtonVisible,
          child: const SizedBox(width: 10),
        ),
        Hero(
            tag: 'App name',
            child: Text(
              'Crunch',
              style: kTextStyleDefaultStylised,
            )),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: CustomDivider(
            length: 20,
            direction: Axis.vertical,
          ),
        ),
        BoardIcon(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Visibility(
            visible: isLargeScreen,
            child: Text('Boards', style: kTextStyleDefaultHeader),
          ),
        ),
        const CustomDivider(
          length: 20,
          direction: Axis.vertical,
        ),
        Visibility(
          visible: widget.isSearchBarVisible,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SearchBar(
              onChanged: widget.onSearchChanged,
              width: isLargeScreen ? 200 : 130,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getAppBarWithSlider({required isLargeScreen}) {
    return SliderAppBar(
      isTitleCenter: false,
      appBarColor: kColorBG,
      appBarHeight: 53,
      drawerIconSize: 30,
      appBarPadding: const EdgeInsets.only(top: 5),
      title: const SizedBox(),
      trailing: _getAppBarContent(isLargeScreen: isLargeScreen),
    );
  }

  Widget _getAppBarWithoutSlider({required isLargeScreen}) {
    return AppBar(
      backgroundColor: kColorBG,
      automaticallyImplyLeading: false,
      elevation: 0,
      shadowColor: Colors.transparent,
      title: SizedBox(
          width: MediaQuery.of(context).size.width / 2.33,
          child: _getAppBarContent(isLargeScreen: isLargeScreen)),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<void Function()> sliderOptionsOnTap = [
      () {
        _sliderKey.currentState?.closeSlider();
        Future.delayed(Duration(milliseconds: widget.animDuration)).then(
            (value) => Navigator.pushNamed(context, EditProfileScreen.id));
      },
      () {
        _sliderKey.currentState?.closeSlider();
        Future.delayed(Duration(milliseconds: widget.animDuration))
            .then((value) {
          Navigator.pushNamed(context, SettingsScreen.id);
        });
      },
      () async {
        _sliderKey.currentState?.closeSlider();
        Provider.of<ProjectsHandler>(context, listen: false)
            .signOut()
            .then((value) {
          _sliderKey.currentState?.dispose();
          Navigator.pop(context);
        });
      }
    ];
    return Consumer<ProjectsHandler>(
      builder: (context, handler, _) {
        if (handler.getCurrentUser != null) {
          User user = handler.getCurrentUser!;
          ImageProvider img = AssetImage(paths[Paths.defaultUserAvatar]!);
          if (handler.getProfileImage != null) {
            img = Image.memory(handler.getProfileImage!).image;
          }

          bool isLargeScreen =
              MediaQuery.of(context).size.width > kAppStylingWidthLimit
                  ? true
                  : false;
          return SliderDrawer(
            key: _sliderKey,
            isDraggable: false,
            animationDuration: widget.animDuration,
            slideDirection: SlideDirection.RIGHT_TO_LEFT,
            sliderShadow:
                SliderShadow(shadowSpreadRadius: 1, shadowBlurRadius: 5),
            slider: _getSlider(
                userName: user.displayName,
                img: img,
                sliderOptionsOnTap: sliderOptionsOnTap),
            appBar: widget.isMenuVisible
                ? _getAppBarWithSlider(isLargeScreen: isLargeScreen)
                : _getAppBarWithoutSlider(isLargeScreen: isLargeScreen),
            child: widget.child,
          );
        } else {
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
        }
      },
    );
  }
}
