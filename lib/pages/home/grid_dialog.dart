import 'dart:async';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/pages/home/view_item2.dart';
import 'package:flutter_demo/pages/home/history_view_dialog.dart';
import 'package:flutter_demo/pages/home/grid_model.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/history_rep.dart';
import 'package:flutter_demo/repository/selection_repo.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class GridDialog {
  Future<FullViewItem?> show({
    required BuildContext context,
    GlobalKey? key,
    required HistoryRecord history,
    int initialIndex = 0,
  }) {
    return showGeneralDialog(
        context: context,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 100),
        pageBuilder: (_, __, ___) {
          return HistoryGridBox(
            history: history,
            initialIndex: initialIndex,
            key: key,
          );
        });
  }
}

class HistoryGridBox extends StatefulWidget {
  const HistoryGridBox({
    required this.history,
    required this.initialIndex,
    super.key,
  });
  final HistoryRecord history;
  final int initialIndex;

  @override
  State<HistoryGridBox> createState() => HistoryBoxDialogState();
}

class HistoryBoxDialogState extends State<HistoryGridBox>
    with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final SelectionRep _selectRep;
  final _model = GridModel();
  late AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _scaleAnimationReversed;
  var _selectionActive = false;
  final _dispStream = DisposableStream();
  Timer? _testTimer;
  final tag = 'mediaView';

  @override
  void initState() {
    super.initState();

    _selectRep = SelectionRep();

    Timer(const Duration(milliseconds: 1000), () async {
      var history = await getIt<HistoryRep>().getHistory();
      if (!mounted || history.firstOrNull == null) return;
      var v = history.firstWhereOrNull((e) {
        return e.folderName == widget.history.folderName;
      });
      if (v != null && v.items.isNotEmpty) {
        _model.setHistory(v.items);
      }
      if (_model.history.isEmpty) {
        Navigator.of(context).pop();
      }
    });

    _dispStream.add(getIt<HistoryRep>().onHistory.listen((history) {
      var v = history.firstWhereOrNull((element) {
        return element.folderName == widget.history.folderName;
      });
      if (v != null && v.items.isNotEmpty) {
        _model.setHistory(v.items);
        _selectRep.history = v.items;
      }
    }));

    _dispStream.add(_selectRep.selectedStream.listen((value) {
      if (value == 0) {
        _animationController.reverse().orCancel;
      } else {
        if (!_selectionActive) {
          if (_animationController.isForwardOrCompleted) {
            _animationController.reverse().orCancel;
          } else {
            _animationController.forward().orCancel;
          }
        }
      }
      _selectionActive = value > 0;
    }));

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: _animationController.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    _scaleAnimationReversed = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
        parent: _animationController.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _testTimer?.cancel();
    _dispStream.dispose();
    _selectRep.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _model,
        builder: (context, child) {
          return Scaffold(
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  title: _header()),
              body: Column(children: [_view()]));
        });
  }

  Widget _view() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate the width of each grid item by dividing the screen width by 3
    final itemWidth = screenWidth / 3;
    return Builder(builder: (context) {
      var history = context.watch<GridModel>().history;
      return Expanded(
          child: Column(children: [
        Expanded(
            child: GridView.builder(
                itemCount: history.length,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, index) {
                  var model = history[index];
                  return ViewItem2(
                      history: model,
                      size: itemWidth.toInt() - 2,
                      selectionRep: _selectRep,
                      padding: const EdgeInsets.all(1),
                      onPressed: () {
                        FullViewDialog().show(
                            context: context,
                            models: history,
                            initialIndex: index);
                      });
                }))
      ]));
    });
  }

  Widget _header() {
    return SizedBox(
        height: kToolbarHeight,
        child: StreamBuilder(
            stream: _selectRep.selectedStream,
            builder: (context, snapshot) {
              var cnt = snapshot.data ?? 0;
              var model = context.watch<GridModel>();
              var label = model.history.firstOrNull?.dateHeader ?? '';
              return Row(children: [
                Expanded(
                    child: Row(children: [
                  const SizedBox(width: 25),
                  Expanded(
                      child: Stack(alignment: Alignment.centerLeft, children: [
                    Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: cnt == 0
                                ? ScaleTransition(
                                    scale: _scaleAnimationReversed,
                                    child: Text(label,
                                        maxLines: 1,
                                        style: const TextStyle(fontSize: 22)))
                                : Text('$cnt',
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 18)))),
                    Positioned(
                        left: 90,
                        top: 0,
                        bottom: 0,
                        child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Row(children: [
                              RoundButton(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .colorButtonRed
                                      .withValues(alpha: 0.8),
                                  iconColor: Theme.of(context)
                                      .colorScheme
                                      .colorCard
                                      .withValues(alpha: 0.8),
                                  size: 45,
                                  radius: 20,
                                  useScaleAnimation: true,
                                  iconData: Icons.delete_outline,
                                  onPressed: (v) async {
                                    var v = _selectRep.getSelected(
                                        type: SearchType.media,
                                        resetSelection: false);
                                    await getIt<HistoryRep>().deleteHistory(v);
                                  }),
                              const SizedBox(width: 15),
                              RoundButton(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .colorSecondary
                                      .withValues(alpha: 0.8),
                                  iconColor: Theme.of(context)
                                      .colorScheme
                                      .colorCard
                                      .withValues(alpha: 0.8),
                                  size: 45,
                                  radius: 20,
                                  iconData: Icons.share,
                                  useScaleAnimation: true,
                                  onPressed: (_) {
                                    var v = _selectRep.getSelected(
                                        type: SearchType.media,
                                        resetSelection: true);
                                    getIt<HistoryRep>().share(v);
                                  })
                            ])))
                  ]))
                ])),
                RoundButton(
                    color: Colors.transparent,
                    iconColor: Theme.of(context)
                        .colorScheme
                        .colorTextAccent
                        .withValues(alpha: 0.8),
                    size: 50,
                    radius: 18,
                    vertTransform: true,
                    iconData: Icons.close,
                    onPressed: (p0) {
                      if (cnt > 0) {
                        _selectRep.stopSelection();
                      } else {
                        Navigator.of(context).pop();
                      }
                    }),
                const SizedBox(width: 8)
              ]);
            }));
  }
}

class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
