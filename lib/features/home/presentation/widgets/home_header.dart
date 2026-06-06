import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/features/history/domain/entities/history_state.dart';
import 'package:flutter_demo/features/history/presentation/pages/filter_page.dart';
import 'package:flutter_demo/features/home/data/models/home_model.dart';
import 'package:flutter_demo/core/repository/app_theme.dart';
import 'package:flutter_demo/core/repository/constants.dart';
import 'package:provider/provider.dart';

class HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 60,
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.colorBgUnderCard,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.colorBgUnderCard,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  )
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Icon(
                      Icons.search_outlined,
                      color: Theme.of(context).colorScheme.colorTextSecond,
                      size: Constants.cardHeaderHeight,
                    ),
                  ),
                  Flexible(
                    child: HoverClick(
                      onPressedL: (_) {
                        final model = context.read<HomeModel>();
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            settings: const RouteSettings(),
                            builder: (context) {
                              return ChangeNotifierProvider<HomeModel>.value(
                                value: model,
                                builder: (context, child) {
                                  var homeModel = context.read<HomeModel>();
                                  var state =
                                      context.select<HomeModel, HistoryState?>(
                                    (v) => v.historyState,
                                  );
                                  return FilterPage(
                                    startDate: state?.startTime,
                                    endDate: state?.endTime,
                                    onApply: (start, end) {
                                      homeModel.filterHistory(
                                        startTime: start,
                                        endTime: end,
                                      );
                                    },
                                    onReset: () {
                                      homeModel.resetFilter();
                                    },
                                    key: ValueKey('filter-${state}'),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                      child: Builder(
                        builder: (context) {
                          var state = context.select<HomeModel, HistoryState?>(
                            (value) => value.historyState,
                          );
                          var items = state?.list;
                          var count = 0;
                          if (items != null) {
                            for (var it in items) {
                              count += it.framesCount;
                            }
                          }
                          var startTime = state?.startTimeString;
                          var endTime = state?.endTimeString;
                          String title;
                          if (startTime != null) {
                            title = startTime;
                            if (endTime != null) {
                              title = '$title / ${endTime}';
                            }
                          } else {
                            title = 'Search by date';
                          }
                          return Stack(
                            children: [
                              SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .colorTextSecond,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 15,
                                bottom: 0,
                                top: 0,
                                child: Center(
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .colorTextSecond,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
