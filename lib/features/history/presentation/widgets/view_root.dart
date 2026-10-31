import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/components/click_detector.dart';
import 'package:flutter_demo/components/slidable_item.dart';
import 'package:flutter_demo/features/history/domain/entities/history_root.dart';
import 'package:flutter_demo/features/home/data/models/home_model.dart';
import 'package:flutter_demo/core/repository/app_theme.dart';
import 'package:flutter_demo/core/repository/constants.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class ViewRoot extends StatefulWidget {
  const ViewRoot({
    required this.history,
    required this.onPressed,
    required this.onDelete,
    this.padding,
    this.showText = true,
    this.useSwipe = true,
    super.key,
  });
  final HistoryRoot history;
  final EdgeInsets? padding;
  final bool showText;
  final bool useSwipe;
  final Function() onPressed;
  final Function() onDelete;

  @override
  State<ViewRoot> createState() => ViewRootState();
}

class ViewRootState extends State<ViewRoot> with TickerProviderStateMixin {
  late final SlidableController _slideCtr;
  late AnimationController _controller;
  late ValueNotifier<int> _swipeReset;
  late final Animation<double> _width;

  @override
  void initState() {
    super.initState();
    _slideCtr = SlidableController(this);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });

    _width = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeOut)));

    _swipeReset = context.read<HomeModel>().swipeReset;
    _swipeReset.addListener(_onResetSwipe);
  }

  @override
  void dispose() {
    _controller.dispose();
    _slideCtr.dispose();
    _swipeReset.removeListener(_onResetSwipe);
    super.dispose();
  }

  void _onClick() async {
    if (_slideCtr.animation.isCompleted) {
      await _controller.forward().orCancel;
      _slideCtr.close();
      return;
    }
    widget.onPressed();
  }

  void _onLongClick() async {
    if (_controller.isForwardOrCompleted) {
      await _controller.reverse().orCancel;
    } else {
      await _controller.forward().orCancel;
      if (_slideCtr.animation.isCompleted) {
      } else {
        _slideCtr.openEndActionPane();
      }
    }
  }

  void _onResetSwipe() async {
    if (_slideCtr.animation.isCompleted) {
      await _controller.forward().orCancel;
      _slideCtr.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (widget.useSwipe) {
        return _swipe(_card());
      }
      return _card();
    });
  }

  Widget _swipe(Widget child) {
    return SlidableItem(
        controller: _slideCtr,
        onSlided: () {},
        button: RoundButton(
            color: Theme.of(context)
                .colorScheme
                .colorButtonRed
                .withValues(alpha: 0.8),
            size: 55,
            radius: 20,
            useScaleAnimation: true,
            iconData: Icons.delete_outline,
            onPressed: (v) {
              _slideCtr.close();
              widget.onDelete();
            }),
        direction: SlideDirection.right,
        child: child);
  }

  Widget _card() {
    var history = widget.history;
    var itemPath = history.path;
    return ClickDetector(
        onClick: () {
          _onClick();
        },
        onLongClick: () {
          _onLongClick();
        },
        child: ScaleTransition(
            scale: _width,
            child: Container(
                margin: const EdgeInsets.only(
                    left: 20, right: 20, top: 16, bottom: 4),
                height: Constants.cardHeight,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.colorCard,
                    borderRadius: BorderRadius.circular(18)),
                child: Stack(fit: StackFit.expand, children: [
                  Image.file(File(itemPath),
                      fit: BoxFit.cover,
                      // no need to decode more than the card shows
                      cacheWidth: 1000),
                  //
                  // keeps the text readable on any photo
                  const DecoratedBox(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xCC000000)]))),
                  Positioned(
                      left: 16,
                      right: 16,
                      bottom: 14,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  //
                                  // header (Yesterday, Today etc)
                                  Text(history.dateHeader,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700)),
                                  //
                                  // date [7 JUN 2026]
                                  Text(
                                      '${history.date.day} ${history.dateMonth.toUpperCase().substring(0, 3)} ${history.dateSub}',
                                      style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.75),
                                          fontSize: 12,
                                          letterSpacing: 0.6,
                                          fontWeight: FontWeight.w500)),
                                ])),
                            //
                            // count of frames
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Row(children: [
                                  const Icon(Icons.photo_library_outlined,
                                      size: 14, color: Colors.white),
                                  const SizedBox(width: 5),
                                  Text('${history.framesCount}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ])),
                          ])),
                ]))));
  }
}
