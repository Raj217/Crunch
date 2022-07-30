import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/custom_widgets/custom_button.dart';
import 'package:crunch/widgets/dialogs/add_update_dialog.dart';
import 'package:crunch/widgets/dialogs/loading_overlay.dart';
import 'package:crunch/widgets/dialogs/confirm_delete.dart';
import 'crunch_card_details.dart';

class CrunchCard {
  void _updateCard(
      {required BuildContext context,
      required String cardName,
      required Map<String, dynamic> data,
      required String boardName,
      required int index}) {
    addUpdateDialog(
        context: context,
        message: 'Update Card',
        title: cardName,
        hintTitleText: 'card name',
        onButtonPressed: (newCardName, _) {
          showLoadingOverlay(
              context: context,
              onCompleted: () => Navigator.pop(context),
              asyncTask: () async {
                data[boardName][index]['card name'] = newCardName;
                await Provider.of<ProjectsHandler>(context, listen: false)
                    .setData(data);
                return;
              });
        });
  }

  void _deleteCard(
      {required BuildContext context,
      required int cardIndex,
      required Map<String, dynamic> data,
      required String boardName}) async {
    // Asking whether to delete the card
    if (await confirm(
      context,
      focusText: data[boardName][cardIndex]['card name'],
    )) {
      // Delete the card
      showLoadingOverlay(
          context: context,
          asyncTask: () async {
            data[boardName].removeAt(cardIndex);
            await Provider.of<ProjectsHandler>(context, listen: false)
                .setData(data);
            return;
          });
    }
    return;
  }

  void _openCard(
      {required BuildContext context,
      required Map<String, dynamic> data,
      required String boardName,
      required int cardIndex}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          final tween = Tween(begin: begin, end: end);
          final scaleAnimation = animation.drive(tween);
          final curvedAnimation = CurvedAnimation(
            parent: scaleAnimation,
            curve: Curves.ease,
          );
          return ScaleTransition(
            scale: tween.animate(curvedAnimation),
            child: child,
          );
        },
        barrierColor: Colors.black26,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) => CardDetails(
          data: data,
          boardName: boardName,
          cardIndex: cardIndex,
        ),
      ),
    );
  }

  DragAndDropItem getCard(
      {required BuildContext context,
      required Map<String, dynamic> data,
      required int cardIndex,
      required String boardName,
      required int index}) {
    Map cardData = data[boardName][cardIndex];
    return DragAndDropItem(
      child: GestureDetector(
        onTap: () {
          _openCard(
              context: context,
              data: data,
              boardName: boardName,
              cardIndex: cardIndex);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      cardData['card name'],
                      style: kTextStyleDefaultActiveText,
                    ),
                  ),
                  CustomButton(
                    icon: Icons.edit,
                    onTap: () {
                      _updateCard(
                          context: context,
                          cardName: cardData['card name'],
                          data: data,
                          boardName: boardName,
                          index: index);
                    },
                  ),
                ],
              ),
              CustomButton(
                  icon: Icons.delete,
                  onTap: () {
                    _deleteCard(
                        context: context,
                        cardIndex: cardIndex,
                        data: data,
                        boardName: boardName);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
