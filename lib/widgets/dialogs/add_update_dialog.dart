import 'package:flutter/material.dart';

import 'package:crunch/widgets/rounded_button.dart';
import 'package:crunch/utils/constant.dart';
import 'package:crunch/widgets/custom_widgets/custom_text_field.dart';

Future<void> addUpdateDialog({
  required BuildContext context,
  String? message,
  String? title,
  bool? addDescBox,
  String? desc,
  String? hintTitleText,
  String? hintDescText,
  void Function()? onCompleted,
  required void Function(String, String?) onButtonPressed,
}) async {
  await showDialog(
      context: context,
      builder: (context) {
        return _Dialog(
          message: message,
          title: title,
          hintTitleText: hintTitleText,
          hintDescText: hintDescText,
          addDescBox: addDescBox,
          desc: desc,
          onCompleted: onCompleted,
          onButtonPressed: onButtonPressed,
        );
      });
  return;
}

class _Dialog extends StatefulWidget {
  final String? message;
  final String? title;
  final String? hintTitleText;
  final String? hintDescText;
  final bool? addDescBox;
  final String? desc;
  final void Function()? onCompleted;
  final void Function(String, String?) onButtonPressed;
  const _Dialog({
    Key? key,
    this.message,
    this.title,
    this.hintTitleText,
    this.hintDescText,
    this.addDescBox,
    this.desc,
    this.onCompleted,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  State<_Dialog> createState() => _DialogState();
}

class _DialogState extends State<_Dialog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController? descController;

  @override
  void initState() {
    super.initState();

    if (widget.title != null) {
      titleController.text = widget.title!;
    }
    descController = TextEditingController();
    if (widget.desc != null) {
      descController!.text = widget.desc!;
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenDimension = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          height: screenDimension.height *
              (widget.addDescBox == true ? 0.44 : 0.24),
          width: screenDimension.width * 0.7,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: kColorBG),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.message ?? '', style: kTextStyleDefaultStylised),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: CustomTextField(
                    hintText: widget.hintTitleText ?? '',
                    autofocus: true,
                    controller: titleController,
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                Visibility(
                  visible: widget.addDescBox == true,
                  child: Expanded(
                    child: CustomTextField(
                      isMultiline: true,
                      hintText: widget.hintDescText ?? 'description',
                      onChanged: (_) {
                        setState(() {});
                      },
                      controller: descController,
                    ),
                  ),
                ),
                RoundedButton(
                  width: double.infinity,
                  height: 40,
                  giveDefaultInternalPadding: false,
                  isActive: widget.title == null
                      ? titleController.text.isNotEmpty
                      : widget.title != titleController.text,
                  onTap: () {
                    widget.onButtonPressed(
                        titleController.text,
                        widget.addDescBox == true
                            ? descController!.text
                            : null);
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
