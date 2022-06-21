import 'package:crunch/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

/// The `title` argument is used to title of alert dialog.
/// The `content` argument is used to content of alert dialog.
/// The `textOK` argument is used to text for 'OK' Button of alert dialog.
/// The `textCancel` argument is used to text for 'Cancel' Button of alert dialog.
///
/// Returns a [Future<bool>].
Future<bool> confirm(
  BuildContext context, {
  double? height,
  double? width,
  String title = 'Confirm',
  String message = 'Would you like to delete ',
  String focusText = '',
}) async {
  Size screenSize = MediaQuery.of(context).size;
  height ??= screenSize.height / 4;
  width ??= screenSize.width / 1.2;
  final bool? isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => Center(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: kColorBG,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, false);
            return true;
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: kTextStyleDefaultStylised),
              Wrap(
                children: [
                  Text(
                    message,
                    style: kTextStyleDefaultInactiveText.copyWith(fontSize: 13),
                  ),
                  Text(
                    focusText,
                    style: kTextStyleDefaultInactiveText.copyWith(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '?',
                    style: kTextStyleDefaultInactiveText.copyWith(fontSize: 13),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, false);
                    },
                    child: Text('No',
                        style: kTextStyleDefaultActiveText.copyWith(
                            color: kColorBlue, fontSize: 15)),
                  ),
                  SizedBox(width: width! / 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, true);
                    },
                    child: Text('Yes',
                        style: kTextStyleDefaultActiveText.copyWith(
                            color: kColorBlue, fontSize: 15)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ),
  );

  return isConfirm ?? false;
}
/*
AlertDialog(
        title: title,
        content: content ?? const Text('Are you sure continue?'),
        actions: <Widget>[
          TextButton(
            child: textCancel ?? const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: textOK ?? const Text('OK'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
 */