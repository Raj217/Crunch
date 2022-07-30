import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/dialogs/confirm_delete.dart';
import 'package:crunch/widgets/dialogs/download_dialog.dart';
import 'package:flutter/material.dart';

import 'package:crunch/widgets/custom_widgets/custom_app_bar.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  static const String id = 'Settings Screen';
  final List<String> _settingsText = ['Check for update'];
  SettingsScreen({Key? key}) : super(key: key);

  GestureDetector _getSettingItem(
      {required String text, required void Function() onTapped}) {
    return GestureDetector(
      onTap: onTapped,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          text,
          style: kTextStyleDefaultActiveText.copyWith(color: kColorBlue),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<void Function()> _settingsOnTapped = [
      () {
        Provider.of<ProjectsHandler>(context, listen: false)
            .isNewAppVersionAvailable
            .then((isAvailable) async {
          if (isAvailable) {
            if (await confirm(context,
                message:
                    'An update is available. Would you like to download it?')) {
              Provider.of<ProjectsHandler>(context, listen: false)
                  .downloadUpdate();
              downloadDialog(
                context,
                downloadStream:
                    Provider.of<ProjectsHandler>(context, listen: false)
                        .getDownloadStreamProgress,
              );
            } else {}
          } else {
            showToast('Your app is up to date',
                context: context,
                textStyle:
                    kTextStyleDefaultActiveText.copyWith(color: Colors.white),
                animation: StyledToastAnimation.slideFromTop,
                reverseAnimation: StyledToastAnimation.slideToTop,
                position: StyledToastPosition.top,
                startOffset: Offset(0.0, -3.0),
                reverseEndOffset: Offset(0.0, -3.0),
                duration: Duration(seconds: 4),
                //Animation duration   animDuration * 2 <= duration
                animDuration: Duration(seconds: 1),
                curve: Curves.elasticOut,
                reverseCurve: Curves.fastOutSlowIn);
          }
        });
      }
    ];
    return Scaffold(
      body: SafeArea(
        child: Consumer<ProjectsHandler>(
          builder: (context, handler, _) {
            return CustomAppBar(
              isBackButtonVisible: true,
              isSearchBarVisible: false,
              isMenuVisible: false,
              context: context,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return _getSettingItem(
                              text: _settingsText[index],
                              onTapped: _settingsOnTapped[index]);
                        },
                        separatorBuilder: (context, _) {
                          return const Divider(thickness: 1);
                        },
                        itemCount: 1),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5, top: 12),
                      child: Text(
                        'version: ${handler.getAppVersion}',
                        style: kTextStyleDefaultInactiveText.copyWith(
                            fontSize: 13, color: kColorGrayDark),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
