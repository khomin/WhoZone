import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/page_background.dart';
import 'package:flutter_demo/core/di/di.dart';
import 'package:flutter_demo/features/history/domain/entities/history_state.dart';
import 'package:flutter_demo/features/history/presentation/pages/history_page.dart';
import 'package:flutter_demo/features/history/presentation/widgets/view_root.dart';
import 'package:flutter_demo/features/home/data/models/home_model.dart';
import 'package:flutter_demo/features/home/presentation/widgets/home_header.dart';
import 'package:flutter_demo/features/home/presentation/widgets/load_records.dart';
import 'package:flutter_demo/features/home/presentation/widgets/no_records.dart';
import 'package:flutter_demo/core/repository/app_theme.dart';
import 'package:provider/provider.dart';

class HomePagePage extends StatefulWidget {
  const HomePagePage({super.key});

  @override
  State<HomePagePage> createState() => HomePagePageState();
}

class HomePagePageState extends State<HomePagePage>
    with TickerProviderStateMixin {
  late HomeModel _model;
  final tag = 'homePage';

  @override
  void initState() {
    super.initState();
    _model = getIt<HomeModel>()..init();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>.value(
      value: _model,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.colorBar,
          body: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageBackground(),
                CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Theme.of(context).colorScheme.colorBar,
                      automaticallyImplyLeading: false,
                      flexibleSpace: _sliverAppBar(),
                    ),
                    SliverToBoxAdapter(child: HomeHeader()),
                    //
                    DecoratedSliver(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.colorBgUnderCard,
                        ),
                        sliver: Builder(builder: (context) {
                          var state = context.select<HomeModel, HistoryState?>(
                            (v) => v.historyState,
                          );
                          if (state == null) {
                            return SliverToBoxAdapter(child: LoadRecords());
                          }
                          if (state.list.isEmpty) {
                            return SliverToBoxAdapter(
                              child: NoRecords(
                                stream: _model.historyStateStream,
                              ),
                            );
                          }
                          return _gallerySliver(state);
                        }))
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  SliverList _gallerySliver(HistoryState state) {
    return SliverList.builder(
      itemCount: state.list.length,
      itemBuilder: (context, index) {
        var model = state.list[index];
        return ViewRoot(
            history: model,
            key: ValueKey('history-${model.date}'),
            onPressed: () {
              _model.swipeReset.value++;
              Navigator.push(
                context,
                CupertinoPageRoute(
                  settings: const RouteSettings(),
                  builder: (context) {
                    return HistorPage(
                      history: model,
                      initialIndex: index,
                    );
                  },
                ),
              );
            },
            onDelete: () async {
              context.read<HomeModel>().deleteHistoryRoot([model]);
            });
      },
    );
  }

  Widget _sliverAppBar() {
    return Stack(children: [
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          color: Theme.of(context).colorScheme.colorBar,
          height: kToolbarHeight,
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 25),
                child: Text(
                  'Home',
                  style: Theme.of(context).colorScheme.homeCardH1Style,
                ),
              ),
              const Spacer()
            ],
          ),
        ),
      )
    ]);
  }
}
