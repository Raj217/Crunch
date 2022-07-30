import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/custom_widgets/custom_button.dart';
import 'package:crunch/widgets/dialogs/add_update_dialog.dart';
import 'package:crunch/widgets/dialogs/loading_overlay.dart';
import 'package:crunch/widgets/dialogs/confirm_delete.dart';

class CrunchBoard {
  void _updateBoard(
      {required BuildContext context,
      required String boardName,
      required Map<String, dynamic> data}) {
    addUpdateDialog(
        context: context,
        message: 'Update Board',
        title: boardName,
        hintTitleText: 'board name',
        onButtonPressed: (newBoardName, _) {
          showLoadingOverlay(
              context: context,
              onCompleted: () => Navigator.pop(context),
              asyncTask: () async {
                if (!data['board indices'].contains(newBoardName)) {
                  // TODO: Add merge feature later
                  var boardData = data[boardName];
                  int index = data['board indices'].indexOf(boardName);

                  data.remove(boardName);

                  data[newBoardName] = boardData;
                  data['board indices'][index] = newBoardName;
                  await Provider.of<ProjectsHandler>(context, listen: false)
                      .setData(data);
                  return;
                }
              });
        });
  }

  void _addCard(
      {required BuildContext context,
      required Map<String, dynamic> data,
      required String parentBoard}) {
    addUpdateDialog(
        context: context,
        message: "Add Card",
        hintTitleText: "card name",
        onButtonPressed: (newCardName, _) {
          showLoadingOverlay(
              context: context,
              onCompleted: () => Navigator.pop(context),
              asyncTask: () async {
                data[parentBoard].add({
                  'card name': newCardName,
                  'description': '',
                  'checklist': []
                });
                await Provider.of<ProjectsHandler>(context, listen: false)
                    .setData(data);
                return;
              });
        });
  }

  void _deleteBoard(
      {required BuildContext context,
      required String boardName,
      required Map<String, dynamic> data}) async {
    if (await confirm(
      context,
      focusText: boardName,
    )) {
      // Delete board
      showLoadingOverlay(
          context: context,
          asyncTask: () async {
            data['board indices'].remove(boardName);
            data.remove(boardName);

            await Provider.of<ProjectsHandler>(context, listen: false)
                .setData(data);
            return;
          });
    }
    return;
  }

  DragAndDropList getBoard(
      {required BuildContext context,
      required String boardName,
      required Map<String, dynamic> data,
      required List<DragAndDropItem> cards}) {
    return DragAndDropList(
      header: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: kColorGray,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    boardName,
                    style: kTextStyleDefaultHeader,
                  ),
                ),
                CustomButton(
                  icon: Icons.edit,
                  onTap: () {
                    _updateBoard(
                        context: context, boardName: boardName, data: data);
                  },
                ),
                const SizedBox(width: 5),
                CustomButton(
                    icon: Icons.add,
                    onTap: () {
                      // Add a Card
                      _addCard(
                          context: context, data: data, parentBoard: boardName);
                    })
              ],
            ),
            CustomButton(
                icon: Icons.delete,
                onTap: () {
                  _deleteBoard(
                      context: context, boardName: boardName, data: data);
                })
          ],
        ),
      ),
      children: cards,
    );
  }
}
