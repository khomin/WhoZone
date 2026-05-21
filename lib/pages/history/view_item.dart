import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/click_detector.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/history_rep.dart';
import 'package:flutter_demo/repository/selection_repo.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';

class ViewItem extends StatefulWidget {
  const ViewItem({
    required this.history,
    required this.onPressed,
    required this.selectionRep,
    this.padding,
    super.key,
  });
  final History history;
  final Function() onPressed;
  final EdgeInsets? padding;
  final SelectionRep selectionRep;

  @override
  State<ViewItem> createState() => ViewItemState();
}

class ViewItemState extends State<ViewItem> {
  final _dispStream = DisposableStream();

  @override
  void initState() {
    super.initState();
  }

  void _onClick() async {
    var selectionRep = widget.selectionRep;
    if (selectionRep.selectedCnt == 0) {
      widget.onPressed();
    } else if (selectionRep.isSelected(widget.history)) {
      selectionRep.releaseSelection(widget.history);
    } else {
      selectionRep.addSelection(widget.history);
    }
  }

  void _onLongClick() async {
    var selectionRep = widget.selectionRep;
    if (selectionRep.selectedCnt == 0) {
      selectionRep.addSelection(widget.history);
    } else {
      if (selectionRep.isSelected(widget.history)) {
        selectionRep.releaseSelection(widget.history);
      } else {
        selectionRep.addSelection(widget.history);
      }
    }
  }

  @override
  void dispose() {
    _dispStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.colorCard,
        child: ClickDetector(
          onClick: () {
            _onClick();
          },
          onLongClick: () {
            _onLongClick();
          },
          child: Stack(alignment: Alignment.center, children: [
            Positioned.fill(
                child: Image.file(
              File(widget.history.path),
              fit: BoxFit.cover,
            )),
            StreamBuilder(
                stream: widget.selectionRep.selectedStream,
                builder: (context, snapshot) {
                  var value = snapshot.data;
                  var selected = false;
                  if (value != null) {
                    selected = widget.selectionRep.isSelected(widget.history);
                  }
                  return AnimatedOpacity(
                      opacity: selected ? 1 : 0,
                      duration: Constants.animationDuraton,
                      child: Icon(Icons.check_circle,
                          size: 40,
                          color: Theme.of(context)
                              .colorScheme
                              .colorBgUnderCard
                              .withValues(alpha: 0.7)));
                }),
          ]),
        ));
  }
}
