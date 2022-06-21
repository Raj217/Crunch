import 'package:crunch/widgets/confirm_delete.dart';
import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/add_edit_board_card.dart';
import 'package:crunch/widgets/custom_app_bar.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:flutter/scheduler.dart' show timeDilation;

import '../widgets/add_edit_project.dart';

class ProjectScreen extends StatefulWidget {
  Map<String, dynamic> data;
  ProjectScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  List<DragAndDropList> list = [];
  Map<String, dynamic> data = {};
  bool isProcessing = false;

  GestureDetector _button({required IconData icon, void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.circle,
            color: Colors.transparent,
            size: kSizeIconDefault + 10,
          ),
          Icon(
            icon,
            color: kColorGrayDark,
            size: kSizeIconDefault,
          )
        ],
      ),
    );
  }

  void decodeData() {
    list = [];
    for (String boardName in data['board indices']) {
      List<DragAndDropItem> items = [];
      for (Map item in data[boardName] ?? []) {
        items.add(
          DragAndDropItem(
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
                          item['card name'],
                          style: kTextStyleDefaultActiveText,
                        ),
                      ),
                      _button(
                        icon: Icons.edit,
                        onTap: () {
                          addEditBoardCard(
                              context: context,
                              data: data,
                              isBoard: false,
                              title: item['card name'],
                              parentBoard: boardName);
                        },
                      ),
                    ],
                  ),
                  _button(
                      icon: Icons.delete,
                      onTap: () async {
                        if (await confirm(
                          context,
                          focusText: item['card name'],
                        )) {
                          data[boardName].removeWhere(
                              (card) => card['card name'] == item['card name']);
                          await Provider.of<ProjectsHandler>(context,
                                  listen: false)
                              .setData(data);
                          return;
                        }
                        return;
                      })
                ],
              ),
            ),
          ),
        );
      }

      list.add(DragAndDropList(
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
                    _button(
                      icon: Icons.edit,
                      onTap: () {
                        addEditBoardCard(
                            context: context,
                            data: data,
                            isBoard: true,
                            title: boardName);
                      },
                    ),
                    const SizedBox(width: 5),
                    _button(
                        icon: Icons.add,
                        onTap: () {
                          addEditBoardCard(
                            context: context,
                            data: data,
                            isBoard: false,
                            parentBoard: boardName,
                          );
                        })
                  ],
                ),
                _button(
                    icon: Icons.delete,
                    onTap: () async {
                      if (await confirm(
                        context,
                        focusText: boardName,
                      )) {
                        data['board indices'].remove(boardName);
                        data.remove(boardName);

                        await Provider.of<ProjectsHandler>(context,
                                listen: false)
                            .setData(data);
                        return;
                      }
                      return;
                    })
              ],
            ),
          ),
          children: items));
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
                                        _button(
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
                                        CustomPopupMenu(
                                          arrowColor: kColorBG,
                                          barrierColor:
                                              Colors.blueGrey.withOpacity(0.01),
                                          pressType: PressType.singleClick,
                                          menuBuilder: () => ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Container(
                                                color: kColorBG,
                                                child: IntrinsicWidth(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Text(
                                                      data['project description']
                                                              .isNotEmpty
                                                          ? data[
                                                              'project description']
                                                          : 'No description...',
                                                      style:
                                                          kTextStyleDefaultActiveText,
                                                    ),
                                                  ),
                                                )),
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: const [
                                              Icon(
                                                Icons.circle,
                                                color: Colors.transparent,
                                                size: kSizeIconDefault + 20,
                                              ),
                                              Icon(
                                                Icons.info_outline,
                                                size: kSizeIconDefault,
                                                color: kColorGrayDark,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    _button(
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
