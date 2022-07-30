import 'dart:async';
import 'dart:typed_data';

import 'package:crunch/utils/google/google_drive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crunch/widgets/custom_widgets/custom_divider.dart';
import 'package:crunch/widgets/custom_widgets/custom_text_field.dart';
import 'package:crunch/widgets/custom_widgets/imageSwiper.dart';
import 'package:crunch/widgets/rounded_button.dart';
import 'package:crunch/widgets/custom_widgets/checklist.dart';
import 'package:crunch/utils/file_handler.dart';
import 'package:crunch/widgets/dialogs/loading_overlay.dart';
import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/custom_widgets/custom_button.dart';
import 'package:crunch/widgets/dialogs/confirm_delete.dart';
import 'package:crunch/widgets/dialogs/image_compression_dialog.dart';

class CardDetails extends StatefulWidget {
  final Map<String, dynamic> data;
  final String boardName;
  final int cardIndex;
  final Map cardData;
  CardDetails(
      {Key? key,
      required this.data,
      required this.boardName,
      required this.cardIndex})
      : cardData = data[boardName][cardIndex],
        super(key: key);

  @override
  State<CardDetails> createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> {
  TextEditingController descriptionController = TextEditingController();
  final double padding = 20;
  late StreamController<List<Uint8List>> _attachmentStreamController;

  @override
  void initState() {
    super.initState();
    if (widget.cardData['description'] != null) {
      descriptionController.text = widget.cardData['description'];
    }
    _attachmentStreamController = StreamController<List<Uint8List>>.broadcast();
  }

  void _saveDesc() {
    showLoadingOverlay(
        context: context,
        onCompleted: () => Navigator.pop(context),
        asyncTask: () async {
          widget.data[widget.boardName][widget.cardIndex]['description'] =
              descriptionController.text;
          Provider.of<ProjectsHandler>(context, listen: false)
              .setData(widget.data);
        });
  }

  Future<void> addAttachment({Uint8List? img}) async {
    if (img != null) {
      String fileName =
          '${widget.boardName}_${widget.cardData['card name']}_${widget.cardData['attachments'] == null ? 0 : widget.cardData['attachments'].length}';
      if (widget.cardData['attachments'] != null) {
        widget.cardData['attachments'].add(fileName);
      } else {
        widget.cardData['attachments'] = [fileName];
      }
      Provider.of<ProjectsHandler>(context, listen: false)
          .uploadAttachment(data: img, fileName: fileName);
      final data = widget.data;
      data[widget.boardName][widget.cardIndex] = widget.cardData;

      Provider.of<ProjectsHandler>(context, listen: false).setData(data);

      _attachmentStreamController.add([img]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!(widget.data[widget.boardName][widget.cardIndex]['description'] ==
            descriptionController.text)) {
          if (await confirm(context,
              title: 'Save', message: 'Do you want to save the changes?')) {
            _saveDesc();
          }
        }

        return true;
      },
      child: Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(padding),
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: kColorBG,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.cardData['card name'],
                      style: kTextStyleDefaultStylised,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Description',
                    style: kTextStyleDefaultActiveText.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 120,
                    child: CustomTextField(
                      isMultiline: true,
                      controller: descriptionController,
                      hintText: 'description',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                      child: CustomDivider(
                        length: 160,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Checklist',
                        style:
                            kTextStyleDefaultActiveText.copyWith(fontSize: 15),
                      ),
                      CustomButton(
                        icon: Icons.add,
                        onTap: () {
                          setState(() {
                            Map<String, dynamic> newCheckList = {
                              "text": '',
                              "isCompleted": false,
                            };
                            if (widget.data[widget.boardName][widget.cardIndex]
                                    ['checklist'] ==
                                null) {
                              widget.data[widget.boardName][widget.cardIndex]
                                  ['checklist'] = [];
                            }

                            widget.data[widget.boardName][widget.cardIndex]
                                    ['checklist']
                                .add(newCheckList);
                          });
                        },
                      ),
                    ],
                  ),
                  Checklist(
                    cardData: widget.cardData,
                    cardIndex: widget.cardIndex,
                    data: widget.data,
                    boardName: widget.boardName,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                      child: CustomDivider(
                        length: 160,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Attachments(in dev)',
                            style: kTextStyleDefaultActiveText.copyWith(
                                fontSize: 15),
                          ),
                          CustomButton(
                            icon: Icons.add,
                            onTap: () async {
                              String? imgPath = await FileHandler.pick();
                              if (imgPath != null) {
                                imageCompressionDialog(
                                        context: context,
                                        imgPath: imgPath,
                                        cardWidth: 240 + padding / 2)
                                    .then((Uint8List? img) =>
                                        addAttachment(img: img));
                              }
                            },
                          ),
                        ],
                      ),
                      Center(
                        child: Container(
                          height: 150,
                          width: 240,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ImageSwiper(
                            itemWidth: 240,
                            images: _attachmentStreamController.stream,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  RoundedButton(
                    height: 40,
                    giveDefaultInternalPadding: false,
                    isActive: !(widget.data[widget.boardName][widget.cardIndex]
                            ['description'] ==
                        descriptionController.text),
                    onTap: () {
                      _saveDesc();
                    },
                    child: Text(
                      'Save',
                      style: kTextStyleDefaultActiveText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
