import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/custom_app_bar.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectScreen extends StatefulWidget {
  Map<String, dynamic> data;
  ProjectScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  List<_DraggableList> allBoards = [];
  List<Widget> list = [];

  void decodeData() {
    allBoards = [];
    Map<String, List<_DraggableListItem>> cards = {};
    List boardNames = [];
    for (String boardName in widget.data['board indices']) {
      boardNames.add(boardName);
    }

    int indexOfDivider = 0;

    /// for the divider '/'
    String boardName;
    String cardName;
    Map<String, dynamic> tempCardData = {};
    for (String card in widget.data['cards'].keys) {
      indexOfDivider = card.indexOf('/');
      if (indexOfDivider != -1) {
        boardName = card.substring(0, indexOfDivider);
        cardName = card.substring(indexOfDivider + 1);
        tempCardData = {'card name': cardName};
        tempCardData.addAll(widget.data['cards'][cardName] ?? {});

        if (cards.containsKey(boardName)) {
          cards[boardName]?.add(_DraggableListItem(data: tempCardData));
        } else {
          cards[boardName] = [_DraggableListItem(data: tempCardData)];
        }
      }
    }

    for (String boardName in boardNames) {
      allBoards.add(
          _DraggableList(header: boardName, items: cards[boardName] ?? []));
    }

    list = allBoards.map((_DraggableList e) {
      return Padding(
        key: ValueKey(e.header),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          child: Text(
            e.header,
            style: kTextStyleDefaultHeader,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    decodeData();
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(isSearchBarVisible: false, isBackButtonVisible: true),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 25),
              child: Column(
                children: [
                  Text(
                    widget.data['project name'] ?? '',
                    style:
                        kTextStyleDefaultStylised.copyWith(color: kColorBlue),
                  ),
                  SizedBox(
                    height: 400,
                    width: 400,
                    child: ReorderableListView(
                      scrollDirection: Axis.horizontal,
                      onReorder: (int oldIndex, int newIndex) async {
                        setState(() {
                          if (newIndex >= widget.data['board indices'].length) {
                            newIndex = widget.data['board indices'].length - 1;
                          }
                          String oldBoard =
                              widget.data['board indices'][oldIndex];
                          widget.data['board indices'].removeAt(oldIndex);
                          widget.data['board indices']
                              .insert(newIndex, oldBoard);
                        });
                        Provider.of<ProjectsHandler>(context, listen: false)
                            .setData(widget.data);
                      },
                      children: list,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _DraggableList {
  String header;
  List<_DraggableListItem> items;

  _DraggableList({required this.header, required this.items});
}

class _DraggableListItem {
  Map<String, dynamic> data;

  _DraggableListItem({required this.data});
}
