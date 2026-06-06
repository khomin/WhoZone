import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/core/di/di.dart';
import 'package:flutter_demo/features/history/data/models/history_model.dart';
import 'package:flutter_demo/features/history/domain/entities/history_record.dart';
import 'package:flutter_demo/features/history/domain/entities/history_root.dart';
import 'package:flutter_demo/features/history/presentation/widgets/view_item.dart';
import 'package:flutter_demo/features/history/presentation/pages/history_view.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistorPage extends StatefulWidget {
  const HistorPage({
    required this.history,
    required this.initialIndex,
    super.key,
  });
  final HistoryRoot history;
  final int initialIndex;

  @override
  State<HistorPage> createState() => _State();
}

class _State extends State<HistorPage> {
  final _model = getIt<HistoryModel>();
  final _scrollController = ScrollController();
  final _disp = DisposableStream();
  Timer? _testTimer;
  final tag = 'historyView';

  @override
  void initState() {
    super.initState();

    _model.setFilter(widget.history.date);
  }

  @override
  void dispose() {
    _model.dispose();
    _scrollController.dispose();
    _testTimer?.cancel();
    _disp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _model,
      builder: (context, child) {
        var selected = context.select<HistoryModel, List<History>?>(
          (v) => v.selected,
        );
        return PopScope(
          canPop: selected == null || selected.isEmpty,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            context.read<HistoryModel>().stopSelection();
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: _header(),
            ),
            body: SafeArea(
              child: _view(),
            ),
          ),
        );
      },
    );
  }

  Widget _view() {
    if (widget.history.items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(children: [
      Flexible(child: Builder(builder: (context) {
        var history = context.select<HistoryModel, HistoryRoot?>(
          (v) => v.history,
        );
        if (history == null || history.items.isEmpty) {
          return const SizedBox();
        }
        return GridView.builder(
            itemCount: history.items.length,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index) {
              var record = history.items[index];
              return ViewItem(
                  history: record,
                  padding: const EdgeInsets.all(1),
                  onPressed: () {
                    var model = context.read<HistoryModel>();
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            settings: const RouteSettings(),
                            builder: (context) {
                              return ChangeNotifierProvider.value(
                                  value: model,
                                  child: HistoryViewItem(
                                    history: history.items,
                                    initialIndex: index,
                                  ));
                            }));
                  });
            });
      }))
    ]);
  }

  Widget _header() {
    return Builder(builder: (context) {
      var label = widget.history.dateHeader;
      var selected = context.select<HistoryModel, List<History>?>(
        (v) => v.selected,
      );
      final count = selected?.length ?? 0;
      return Container(
          height: kToolbarHeight,
          child: Row(children: [
            Flexible(
                child: Row(children: [
              const SizedBox(width: 25),
              Flexible(
                  child: Stack(alignment: Alignment.centerLeft, children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: count == 0
                        ? AnimatedScale(
                            duration: Constants.duration,
                            scale: count != 0 ? 0 : 1,
                            child: Text(
                              label,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 22),
                            ),
                          )
                        : Text(
                            '${count}',
                            maxLines: 1,
                            style: const TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                Positioned(
                    left: 90,
                    top: 0,
                    bottom: 0,
                    child: AnimatedScale(
                        duration: Constants.duration,
                        scale: count == 0 ? 0 : 1,
                        child: Row(children: [
                          RoundButton(
                              color: Theme.of(context)
                                  .colorScheme
                                  .colorButtonRed
                                  .withValues(alpha: 0.8),
                              size: 45,
                              radius: 20,
                              useScaleAnimation: true,
                              iconData: Icons.delete_outline,
                              onPressed: (v) async {
                                var model = context.read<HistoryModel>();
                                model.deleteHistory(model.getSelected());
                                model.stopSelection();
                              }),
                          const SizedBox(width: 15),
                          RoundButton(
                              color: Theme.of(context)
                                  .colorScheme
                                  .colorSecondary
                                  .withValues(alpha: 0.8),
                              size: 45,
                              radius: 20,
                              iconData: Icons.share,
                              useScaleAnimation: true,
                              onPressed: (_) {
                                var model = context.read<HistoryModel>();
                                var v = model.getSelected(resetSelection: true);
                                model.share(v);
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
                margin: EdgeInsets.only(right: 8),
                iconData: Icons.close,
                onPressed: (_) {
                  var model = context.read<HistoryModel>();
                  if (model.selectedCnt > 0) {
                    model.stopSelection();
                  } else {
                    Navigator.of(context).pop();
                  }
                }),
          ]));
    });
  }
}

class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
