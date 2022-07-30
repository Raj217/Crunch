import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

import 'package:crunch/widgets/custom_widgets/custom_divider.dart';
import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/projects_slider.dart';
import 'package:crunch/widgets/custom_widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "Home Screen";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLargeScreen = true;
  String searchedProjectName = '';
  GlobalKey<SliderDrawerState> sliderKey = GlobalKey();
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
        child: CustomAppBar(
          onSearchChanged: (search) {
            setState(() {
              searchedProjectName = search;
            });
          },
          context: context,
          child: LiquidPullToRefresh(
            onRefresh: () async {
              await Provider.of<ProjectsHandler>(context, listen: false)
                  .retrieveData();
            },
            color: kColorBlack,
            springAnimationDurationInMilliseconds: 800,
            child: ListView(
              children: [
                const CustomDivider(),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
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
      ),
    );
  }
}
