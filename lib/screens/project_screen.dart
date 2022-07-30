import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/dialogs/add_edit_board_card.dart';
import 'package:crunch/widgets/custom_widgets/custom_app_bar.dart';
import 'package:crunch/widgets/custom_widgets/custom_button.dart';
import 'package:crunch/widgets/dtype_formats/crunch_board/crunch_board.dart';
import 'package:crunch/widgets/dtype_formats/crunch_card/crunch_card.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:flutter/scheduler.dart' show timeDilation;

import 'package:crunch/widgets/dialogs/add_edit_project.dart';

class ProjectScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ProjectScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  List<DragAndDropList> list = [];
  Map<String, dynamic> data = {};
  bool isProcessing = false;

  void decodeData() {
    list = [];
    for (String boardName in data['board indices']) {
      List<DragAndDropItem> cards = [];
      if (data[boardName].length != 0) {
        for (int index = 0; index < data[boardName].length; index++) {
          cards.add(
            CrunchCard().getCard(
                context: context,
                data: data,
                cardIndex: index,
                boardName: boardName,
                index: index),
          );
        }
      }

      list.add(CrunchBoard().getBoard(
          context: context, boardName: boardName, data: data, cards: cards));
    }
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1;

    return Scaffold(
      body: SafeArea(
        child: CustomAppBar(
          isSearchBarVisible: false,
          isBackButtonVisible: true,
          context: context,
          child: LiquidPullToRefresh(
            onRefresh: () async {
              await Provider.of<ProjectsHandler>(context, listen: false)
                  .retrieveData();
            },
            color: kColorBlack,
            springAnimationDurationInMilliseconds: 800,
            child: ListView(
              children: [
                StreamBuilder(
                  initialData: widget.data,
                  stream: Provider.of<ProjectsHandler>(context, listen: false)
                      .getStream,
                  builder: (context, AsyncSnapshot snapshot) {
                    try {
                      if (Provider.of<ProjectsHandler>(context)
                              .getCurrentUser ==
                          null) {
                        Navigator.pop(context);
                      }
                      if (snapshot.data!.runtimeType == List<dynamic>) {
                        data = snapshot.data[0];
                      } else {
                        data = snapshot.data!;
                      }
                      decodeData();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              data['project name'] ?? '',
                                              style: kTextStyleDefaultActiveText
                                                  .copyWith(
                                                      color: kColorBlue,
                                                      fontSize: 27,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                        CustomButton(
                                            icon: Icons.edit,
                                            onTap: () async {
                                              setState(
                                                  () => isProcessing = true);
                                              await addEditProject(
                                                  context: context,
                                                  title: data['project name'],
                                                  desc: data[
                                                      'project description']);

                                              setState(
                                                  () => isProcessing = false);
                                            }),
                                      ],
                                    ),
                                    CustomButton(
                                        icon: Icons.add,
                                        onTap: () async {
                                          setState(() => isProcessing = true);
                                          await addEditBoardCard(
                                              context: context,
                                              isBoard: true,
                                              data: data);

                                          setState(() => isProcessing = false);
                                        }),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.75,
                                  child: DragAndDropLists(
                                    axis: Axis.horizontal,
                                    listWidth: 280,
                                    listPadding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    onItemReorder: (int oldItemIndex,
                                        int oldListIndex,
                                        int newItemIndex,
                                        int newListIndex) {
                                      setState(() {
                                        String oldBoardName =
                                            data['board indices'][oldListIndex];
                                        String newBoardName =
                                            data['board indices'][newListIndex];

                                        Map oldItem =
                                            data[oldBoardName][oldItemIndex];
                                        data[oldBoardName]
                                            .removeAt(oldItemIndex);
                                        if (data[newBoardName] != null) {
                                          data[newBoardName]
                                              .insert(newItemIndex, oldItem);
                                        } else {
                                          data[newBoardName] = [oldItem];
                                        }
                                      });

                                      Provider.of<ProjectsHandler>(context,
                                              listen: false)
                                          .setData(data);
                                    },
                                    onListReorder:
                                        (int oldListIndex, int newListIndex) {
                                      setState(() {
                                        if (newListIndex >=
                                            data['board indices'].length) {
                                          newListIndex =
                                              data['board indices'].length - 1;
                                        }
                                        String oldBoard =
                                            data['board indices'][oldListIndex];
                                        data['board indices']
                                            .removeAt(oldListIndex);
                                        data['board indices']
                                            .insert(newListIndex, oldBoard);
                                      });
                                      Provider.of<ProjectsHandler>(context,
                                              listen: false)
                                          .setData(data);
                                    },
                                    children: list,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    } catch (_) {
                      return Lottie.asset(paths[Paths.lottieLoading]!,
                          repeat: true);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
