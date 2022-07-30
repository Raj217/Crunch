import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'animated_text_field.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/dialogs/loading_overlay.dart';

class Checklist extends StatefulWidget {
  final Map cardData;
  final Map<String, dynamic> data;
  final String boardName;
  final int cardIndex;
  const Checklist(
      {Key? key,
      required this.cardData,
      required this.data,
      required this.boardName,
      required this.cardIndex})
      : super(key: key);

  @override
  State<Checklist> createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 150),
      child: ListView.builder(
        itemCount: widget.cardData.containsKey('checklist')
            ? widget.cardData['checklist'].length
            : 0,
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        itemBuilder: (context, index) {
          return AnimatedTextField(
            initText: widget.cardData['checklist'][index]['text'],
            checkboxValue: widget.cardData['checklist'][index]['isCompleted'],
            autoFocus: index == widget.cardData['checklist'].length - 1,
            isCheckboxVisible: true,
            onCheckboxChanged: (val) {
              setState(() async {
                widget.data[widget.boardName][widget.cardIndex]['checklist']
                    [index]['isCompleted'] = val;

                await Provider.of<ProjectsHandler>(context, listen: false)
                    .setData(widget.data);
              });
            },
            onDelete: () {
              setState(() {
                showLoadingOverlay(
                    context: context,
                    asyncTask: () async {
                      widget.data[widget.boardName][widget.cardIndex]
                              ['checklist']
                          .removeAt(index);
                      await Provider.of<ProjectsHandler>(context, listen: false)
                          .setData(widget.data);
                    });
              });
            },
            onChanged: (text, isCompleted) async {
              if (text.isNotEmpty) {
                widget.data[widget.boardName][widget.cardIndex]['checklist']
                    [index]['text'] = text;
                widget.data[widget.boardName][widget.cardIndex]['checklist']
                    [index]['isCompleted'] = isCompleted;
                await Provider.of<ProjectsHandler>(context, listen: false)
                    .setData(widget.data);
              }
            },
          );
        },
      ),
    );
  }
}
