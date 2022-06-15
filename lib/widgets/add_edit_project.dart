import 'package:crunch/utils/constant.dart';
import 'package:crunch/widgets/custom_text_field.dart';
import 'package:crunch/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/provider/projects_handler.dart';

Future<void> addEditProject(
    {required BuildContext context, String? title, String? desc}) async {
  await showDialog(
      context: context,
      builder: (context) {
        return _Dialog(context: context, title: title, desc: desc);
      });
  return;
}

class _Dialog extends StatefulWidget {
  final BuildContext context;
  final String? title;
  final String? desc;
  const _Dialog({Key? key, required this.context, this.title, this.desc})
      : super(key: key);

  @override
  State<_Dialog> createState() => _DialogState();
}

class _DialogState extends State<_Dialog> {
  TextEditingController projectNameController = TextEditingController();
  TextEditingController projectDescriptionController = TextEditingController();
  String error = '';
  @override
  void initState() {
    super.initState();
    if (widget.title != null) {
      projectNameController.text = widget.title!;
    }

    if (widget.desc != null) {
      projectDescriptionController.text = widget.desc!;
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
          height: screenDimension.height * 0.44,
          width: screenDimension.width * 0.7,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: kColorBG),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.title == null ? 'Add' : 'Update'} Project',
                    style: kTextStyleDefaultStylised),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: CustomTextField(
                    hintText: 'name',
                    autofocus: true,
                    controller: projectNameController,
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: CustomTextField(
                    isMultiline: true,
                    hintText: 'description',
                    onChanged: (_) {
                      setState(() {});
                    },
                    controller: projectDescriptionController,
                  ),
                ),
                Visibility(
                  /// Left it like this since error is global in this case
                  visible: error.isNotEmpty,
                  child: SizedBox(
                    width: 150,
                    child: Text(
                      '*$error',
                      style: kTextStyleDefaultInactiveText.copyWith(
                          color: Colors.red, fontSize: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                RoundedButton(
                  width: double.infinity,
                  height: 40,
                  giveDefaultInternalPadding: false,
                  isActive: widget.title == null
                      ? projectNameController.text.isNotEmpty
                      : (widget.title != projectNameController.text ||
                          widget.desc != projectDescriptionController.text),
                  onTap: () {
                    if (widget.title == null) {
                      Provider.of<ProjectsHandler>(context, listen: false)
                          .addProject(
                              name: projectNameController.text,
                              desc: projectDescriptionController.text)
                          .listen((message) {
                        setState(() {
                          error = message;
                        });
                        if (message == '') {
                          Navigator.pop(context);
                        }
                      });
                    } else {
                      Provider.of<ProjectsHandler>(context, listen: false)
                          .setBoardNameAndDesc(
                              oldBoardName: widget.title!,
                              newBoardName: projectNameController.text,
                              desc: projectDescriptionController.text)
                          .listen((message) {
                        if (message == '') {
                          Navigator.pop(context);
                        }
                        setState(() {
                          error = message;
                        });
                      });
                    }
                  },
                  child: Text(
                    widget.title == null ? 'Add' : 'Update',
                    style: kTextStyleDefaultActiveText,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
