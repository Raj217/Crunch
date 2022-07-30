import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crunch/widgets/rounded_button.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/utils/constant.dart';
import 'package:crunch/widgets/custom_widgets/custom_text_field.dart';

Future<void> addEditBoardCard(
    {required BuildContext context,
    required Map<String, dynamic> data,
    String? title,
    String? parentBoard,
    bool isBoard = true}) async {
  await showDialog(
      context: context,
      builder: (context) {
        return _Dialog(
            context: context,
            parentBoard: parentBoard,
            data: data,
            title: title,
            isBoard: isBoard);
      });
  return;
}

class _Dialog extends StatefulWidget {
  final BuildContext context;
  final String? title;
  final String? parentBoard;
  final bool? isBoard;
  final Map<String, dynamic> data;
  const _Dialog(
      {Key? key,
      required this.context,
      required this.parentBoard,
      required this.data,
      this.title,
      required this.isBoard})
      : super(key: key);

  @override
  State<_Dialog> createState() => _DialogState();
}

class _DialogState extends State<_Dialog> {
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.title != null) {
      titleController.text = widget.title!;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenDimension = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          height: screenDimension.height * 0.24,
          width: screenDimension.width * 0.7,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: kColorBG),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${widget.title == null ? 'Add' : 'Update'} ${widget.isBoard == true ? 'Board' : 'Card'}',
                    style: kTextStyleDefaultStylised),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: CustomTextField(
                    hintText: 'name',
                    autofocus: true,
                    controller: titleController,
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                RoundedButton(
                  width: double.infinity,
                  height: 40,
                  giveDefaultInternalPadding: false,
                  isActive: widget.title == null
                      ? titleController.text.isNotEmpty
                      : widget.title != titleController.text,
                  onTap: () async {
                    if (widget.isBoard == true) {
                      if (widget.title == null) {
                        // Add New board
                        if (!widget.data.keys.contains(titleController.text)) {
                          widget.data[titleController.text] = [];
                          widget.data['board indices']
                              .add(titleController.text);
                        }
                      } else {
                        // Update Old board
                        if (widget.data.keys.contains(widget.title)) {
                          var data = widget.data[widget.title];
                          int index = widget.data['board indices']
                              .indexOf(widget.title);

                          widget.data.remove(widget.title);

                          widget.data[titleController.text] = data;
                          widget.data['board indices'][index] =
                              titleController.text;
                        }
                      }
                    } else {
                      if (widget.title == null) {
                        // Add New Card
                        widget.data[widget.parentBoard!]
                            .add({'card name': titleController.text});
                      } else {
                        // Update Old Card
                        int index = widget.data[widget.parentBoard!].indexOf(
                            widget.data[widget.parentBoard!]
                                .where(
                                    (card) => card['card name'] == widget.title)
                                .toList()[0]);
                        widget.data[widget.parentBoard][index]['card name'] =
                            titleController.text;
                      }
                    }
                    await Provider.of<ProjectsHandler>(context, listen: false)
                        .setData(widget.data)
                        .then((_) {
                      Navigator.pop(context);
                    });
                  },
                  child: Text(
                    widget.title == null ? 'Add' : 'Update',
                    style: kTextStyleDefaultActiveText,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
