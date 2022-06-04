import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/boards_slider.dart';
import 'package:crunch/widgets/custom_app_bar.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(),
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
