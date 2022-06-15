import 'package:crunch/screens/auth_screen.dart';
import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/projects_slider.dart';
import 'package:crunch/widgets/custom_app_bar.dart';
import 'package:crunch/widgets/custom_divider.dart';
import 'package:crunch/widgets/icons/board_icon.dart';
import 'package:crunch/widgets/user_profile.dart';
import 'package:crunch/widgets/search_bar.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class HomeScreen extends StatefulWidget {
  static const String id = "Home Screen";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLargeScreen = true;
  String searchedProjectName = '';
  @override
  Widget build(BuildContext context) {
    timeDilation = 1;
    if (Provider.of<ProjectsHandler>(context).getCurrentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pop(context);
      });
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                onSearchChanged: (search) {
                  setState(() {
                    searchedProjectName = search;
                  });
                },
              ),
              const CustomDivider(),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: Text(
                  'All',
                  style: kTextStyleDefaultHeader.copyWith(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              ProjectsSlider(
                  stream: Provider.of<ProjectsHandler>(context, listen: false)
                      .getStream),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: Text(
                  'Searched Items',
                  style: kTextStyleDefaultHeader.copyWith(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              ProjectsSlider(
                  showAddBoardButton: false,
                  matchProjectName: searchedProjectName,
                  stream: Provider.of<ProjectsHandler>(context, listen: false)
                      .getStream),
            ],
          ),
        ),
      ),
    );
  }
}
