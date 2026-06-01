import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/click_detector.dart';
import 'package:flutter_demo/features/history/data/models/history_model.dart';
import 'package:flutter_demo/features/history/domain/entities/history_record.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';

class ViewItem extends StatefulWidget {
  const ViewItem({
    required this.history,
    required this.onPressed,
    this.padding,
    super.key,
  });
  final History history;
  final Function() onPressed;
  final EdgeInsets? padding;

  @override
  State<ViewItem> createState() => ViewItemState();
}

class ViewItemState extends State<ViewItem> {
  void _onClick() async {
    var model = context.read<HistoryModel>();
    if (model.selectedCnt == 0) {
      widget.onPressed();
    } else if (model.isSelected(widget.history)) {
      model.releaseSelection(widget.history);
    } else {
      model.addSelection(widget.history);
    }
  }

  void _onLongClick() async {
    var model = context.read<HistoryModel>();
    if (model.selectedCnt == 0) {
      model.addSelection(widget.history);
    } else {
      if (model.isSelected(widget.history)) {
        model.releaseSelection(widget.history);
      } else {
        model.addSelection(widget.history);
      }
    }
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
                child: Image.file(
              File(widget.history.path),
              fit: BoxFit.cover,
            )),
            Builder(
              builder: (context) {
                var model = context.watch<HistoryModel>();
                final selected = model.isSelected(widget.history);
                return AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  duration: Constants.animationDuraton,
                  child: Icon(
                    Icons.check_circle,
                    size: 50,
                    color: Theme.of(context).colorScheme.colorBgUnderCard,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
