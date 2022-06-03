import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/boards_slider.dart';
import 'package:crunch/widgets/custom_divider.dart';
import 'package:crunch/widgets/icons/board_icon.dart';
import 'package:crunch/widgets/user_profile.dart';
import 'package:crunch/widgets/search_bar.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "Home Screen";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLargeScreen = true;
  @override
  Widget build(BuildContext context) {
    isLargeScreen = MediaQuery.of(context).size.width > kAppStylingWidthLimit
        ? true
        : false;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 20 : 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text('Crunch', style: kTextStyleDefaultLogo),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: SearchBar(
                          width: isLargeScreen ? 200 : 130,
                        ),
                      ),
                    ],
                  ),
                  const UserProfile(),
                ],
              ),
            ),
            const CustomDivider(),
            BoardsSlider(
                stream: Provider.of<ProjectsHandler>(context, listen: false)
                    .getStream)
          ],
        ),
      ),
    );
  }
}
