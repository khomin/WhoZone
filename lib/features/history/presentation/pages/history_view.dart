import 'dart:async';
import 'dart:io';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/features/history/data/models/history_model.dart';
import 'package:flutter_demo/features/history/domain/entities/history_record.dart';
import 'package:flutter_demo/features/history/domain/entities/scroll_touch.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:flutter/material.dart';

class Current {
  Current({required this.index, required this.model});
  int index;
  History model;
}

class HistoryViewItem extends StatefulWidget {
  const HistoryViewItem({
    required this.history,
    required this.initialIndex,
    super.key,
  });
  final List<History> history;
  final int initialIndex;

  @override
  State<HistoryViewItem> createState() => HistoryViewItemState();
}

class HistoryViewItemState extends State<HistoryViewItem> {
  late Current _current;
  var _doNotScroollToPreviewItem = false;
  final _scrollTouch = ScrollTouch();
  late PageController pageController;
  final FocusNode _rawKeyLister = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late ListObserverController _observerController;
  late final PageController _controller;
  final tag = 'historyView';

  @override
  void initState() {
    super.initState();

    var startModel = widget.history[widget.initialIndex];
    _current = Current(index: 0, model: startModel);
    _current.index = widget.initialIndex;
    _current.model = startModel;

    _observerController = ListObserverController(controller: _scrollController);
    _controller = PageController(initialPage: _current.index);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _rawKeyLister.dispose();
  }

  void _scrollTo(int index) {
    _observerController.jumpTo(index: _current.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: _header(),
        ),
        body: Column(children: [
          //
          _page(),
          //
          _buttons(),
        ]));
  }

  Widget _buttons() {
    return SafeArea(
      child: Container(
        height: kToolbarHeight,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          // delete
          RoundButton(
              color: Theme.of(context)
                  .colorScheme
                  .colorButtonRed
                  .withValues(alpha: 0.8),
              size: 55,
              radius: 20,
              useScaleAnimation: true,
              iconData: Icons.delete_outline,
              onPressed: (v) async {
                var model = context.read<HistoryModel>();
                model.deleteHistory([_current.model]);
                model.releaseSelection(_current.model);
                Navigator.of(context).pop();
              }),
          const SizedBox(width: 15),
          // share
          RoundButton(
              color: Theme.of(context)
                  .colorScheme
                  .colorSecondary
                  .withValues(alpha: 0.8),
              size: 55,
              radius: 20,
              useScaleAnimation: true,
              iconData: Icons.share,
              onPressed: (_) {
                var model = context.read<HistoryModel>();
                model.share([_current.model]);
                model.releaseSelection(_current.model);
              })
        ]),
      ),
    );
  }

  Widget _page() {
    return Builder(
      builder: (context) {
        var size = MediaQuery.sizeOf(context);
        return Expanded(
          child: Container(
            width: size.width,
            height: size.height - kToolbarHeight,
            child: Listener(
              onPointerDown: (opm) {
                _scrollTouch.savePointerPosition(opm.pointer);
              },
              onPointerMove: (opm) {
                _scrollTouch.savePointerPosition(opm.pointer);
              },
              onPointerCancel: (opc) {
                _scrollTouch.clearPointerPosition(opc.pointer);
              },
              onPointerUp: (opc) {
                _scrollTouch.clearPointerPosition(opc.pointer);
              },
              child: ChangeNotifierProvider.value(
                value: _scrollTouch,
                builder: (context, child) {
                  var scroll = context.watch<ScrollTouch>();
                  return PageView.builder(
                    physics: scroll.touchPositions.length > 1 || scroll.zoom
                        ? const NeverScrollableScrollPhysics()
                        : const CustomPageViewScrollPhysics(),
                    onPageChanged: _onPageChange,
                    controller: _controller,
                    itemCount: widget.history.length,
                    itemBuilder: (context, index) {
                      var model = widget.history[index];
                      return _item(model);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _onPageChange(int index) {
    _current.index = index;
    var model = widget.history[index];
    var current = Current(index: index, model: model);
    setState(() {
      _current = current;
    });
    if (_doNotScroollToPreviewItem) {
      _doNotScroollToPreviewItem = false;
    } else {
      Future.microtask(() {
        _scrollTo(index);
      });
    }
  }

  Widget _header() {
    return SizedBox(
        height: kToolbarHeight,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const SizedBox(width: 25),
            Text(widget.history.first.dateHeader,
                style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text('${_current.index + 1} of ${widget.history.length}',
                style: const TextStyle(fontSize: 18))
          ]),
          RoundButton(
              margin: EdgeInsets.only(right: 8),
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
                Navigator.of(context).pop();
              }),
        ]));
  }

  Widget _item(History model) {
    return Stack(alignment: Alignment.center, children: [
      Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: ClipRRect(
          child: Image.file(File(model.path), fit: BoxFit.contain),
        ),
      )
    ]);
  }
}

class PagingScrollPhysics extends ScrollPhysics {
  final double itemDimension;

  const PagingScrollPhysics({required this.itemDimension, super.parent});

  @override
  PagingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PagingScrollPhysics(
        itemDimension: itemDimension, parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 100000,
        stiffness: 10,
        damping: 0.8,
      );

  double _getPage(ScrollMetrics position) {
    return position.pixels / itemDimension;
  }

  double _getPixels(double page) {
    return page * itemDimension;
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    // ignore: deprecated_member_use
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({super.parent});

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (velocity.abs() > toleranceFor(position).velocity) {
      return null;
    }
    return super.createBallisticSimulation(position, velocity);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 1.0,
        stiffness: 50000,
        damping: 1000,
      );
}
