import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:crunch/screens/project_screen.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/add_edit_project.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:crunch/utils/constant.dart';
import 'package:provider/provider.dart';

class ProjectsSlider extends StatefulWidget {
  final Stream stream;
  final double height;
  final double width;
  final double spacing;
  final String? matchProjectName;
  final bool showAddBoardButton;
  const ProjectsSlider(
      {Key? key,
      required this.stream,
      this.height = 250,
      this.width = double.infinity,
      this.spacing = 20,
      this.matchProjectName,
      this.showAddBoardButton = true})
      : super(key: key);

  @override
  State<ProjectsSlider> createState() => _ProjectsSliderState();
}

class _ProjectsSliderState extends State<ProjectsSlider> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.stream,
        builder: (context, AsyncSnapshot snapshot) {
          return SizedBox(
              height: widget.height,
              width: widget.width,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: widget.height / 5),
                child: ListView.builder(
                    itemCount:
                        snapshot.data != null ? snapshot.data.length + 1 : 1,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if (snapshot.data == null || index == 0) {
                        if (widget.showAddBoardButton == true) {
                          return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: widget.spacing),
                              child: _Project(
                                width: 200,
                                height: widget.height * 4 / 5,
                                boardType: BoardType.addProject,
                              ));
                        } else {
                          return const SizedBox();
                        }
                      } else {
                        bool showBoard = false;
                        if (widget.showAddBoardButton == true) {
                          showBoard = true;
                        } else {
                          if (widget.matchProjectName == null ||
                              (widget.matchProjectName?.isEmpty ?? false)) {
                            showBoard = false;
                          } else {
                            if (widget.matchProjectName ==
                                snapshot.data![index - 1]['project name']
                                    .substring(
                                        0, widget.matchProjectName!.length)) {
                              showBoard = true;
                            } else {
                              showBoard = false;
                            }
                          }
                        }
                        if (showBoard) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: widget.spacing),
                            child: _Project(
                              data: Map<String, dynamic>.from(
                                  snapshot.data![index - 1]),
                              width: 250,
                              height: widget.height * 4 / 5,
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      }
                    }),
              ));
        });
  }
}

enum BoardType { addProject, displayProject }

class _Project extends StatelessWidget {
  final Map<String, dynamic>? data;
  static final List<Color> _availableColorsForBG = [
    kColorBlue,
    kColorPurple,
    kColorOrange,
    kColorAquamarine
  ];
  final Color _color;
  final double height;
  final double width;
  final BoardType boardType;
  _Project(
      {Key? key,
      this.data,
      Color? color,
      required this.height,
      required this.width,
      this.boardType = BoardType.displayProject})
      : _color = color ??
            _availableColorsForBG[
                Random().nextInt(_availableColorsForBG.length)],
        assert(data != null || boardType != BoardType.displayProject,
            'if the boardType is display type, data must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (boardType == BoardType.addProject) {
      return InkWell(
        onTap: () {
          addEditProject(context: context);
        },
        child: SizedBox(
          height: height,
          width: width,
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(20),
            strokeCap: StrokeCap.round,
            dashPattern: const [6, 6],
            color: kColorGrayDark,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: const [
                  Icon(
                    Icons.circle_outlined,
                    size: kSizeIconDefault + 20,
                    color: kColorGrayDark,
                  ),
                  Icon(
                    Icons.add,
                    size: kSizeIconDefault + 10,
                    color: kColorGrayDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ProjectScreen(data: data!);
            }));
          },
          child: Container(
            height: height,
            width: width,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _color.withOpacity(0.2),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: height / 8, horizontal: width / 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: width - width / 5 - kSizeIconDefault - 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data!['project name'] ?? '',
                          style: kTextStyleDefaultHeader,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: kSizeIconDefault),
                          child: Text(
                            data!['project description'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: kTextStyleDefaultInactiveText.copyWith(
                                fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () async {
                            if (await confirm(
                              context,
                              title: const Text('Confirm'),
                              content: Text(
                                  'Would you like to delete ${data!['project name']}?'),
                              textOK: const Text('Yes'),
                              textCancel: const Text('No'),
                            )) {
                              await Provider.of<ProjectsHandler>(context,
                                      listen: false)
                                  .deleteProject(data!['project name']!);

                              return;
                            }
                            return;
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: const [
                              Icon(
                                Icons.circle,
                                color: Colors.transparent,
                                size: kSizeIconDefault + 15,
                              ),
                              Icon(Icons.delete,
                                  color: kColorBlack, size: kSizeIconDefault),
                            ],
                          )),
                      const Icon(
                        Icons.arrow_right_alt,
                        color: kColorBlack,
                        size: kSizeIconDefault,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
