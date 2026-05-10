import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/pages/history/history_page.dart';
import 'package:flutter_demo/pages/history/view_root.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/repository/history_rep.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:rxdart/rxdart.dart';

class HomePagePage extends StatefulWidget {
  const HomePagePage({super.key});

  @override
  State<HomePagePage> createState() => HomePagePageState();
}

class HomePagePageState extends State<HomePagePage>
    with TickerProviderStateMixin {
  final _scrollCtr = ScrollController();
  final _focus = FocusNode();
  late final Animation<double> _slideHeight;
  late AnimationController _ctrSlideTop;
  late AnimationController _ctrShakeIcon;
  late final Animation<double> _iconRotate;
  Timer? _scrollThrottleTm;
  final _onCloseSlide = BehaviorSubject<bool>.seeded(false);
  final _dispStream = DisposableStream();
  final tag = 'homePage';

  @override
  void initState() {
    super.initState();

    _ctrSlideTop = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideHeight = Tween<double>(
      begin: kToolbarHeight,
      end: kToolbarHeight * 3,
    ).animate(CurvedAnimation(
        parent: _ctrSlideTop.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    _ctrShakeIcon = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _iconRotate = TweenSequence<double>([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: 0.005), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.005, end: 0), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: -0.005), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: -0.005, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _ctrShakeIcon.view,
      curve: Curves.linear,
    ));

    _scrollCtr.addListener(() {
      _scrollThrottleTm?.cancel();
      _scrollThrottleTm = Timer(const Duration(milliseconds: 50), () {
        _focus.unfocus();
        _onCloseSlide.add(true);
        if (_ctrSlideTop.isForwardOrCompleted) {
          _ctrSlideTop.reverse().orCancel;
        }
      });
    });

    Timer(const Duration(milliseconds: 100), () async {
      if (await getIt<HistoryRep>().isEmpty()) {
        if (!mounted) return;
        if (_ctrShakeIcon.isForwardOrCompleted) {
          _ctrShakeIcon.reverse().orCancel;
        } else {
          _ctrShakeIcon.forward().orCancel;
        }
      }
      getIt<HistoryRep>().updateHistory();
    });
  }

  @override
  void dispose() {
    _ctrSlideTop.dispose();
    _ctrShakeIcon.dispose();
    _scrollCtr.dispose();
    _dispStream.dispose();
    _onCloseSlide.close();
    _scrollThrottleTm?.cancel();
    super.dispose();
  }

  void _handleOnSlide() {
    if (getIt<CameraRep>().onCaptureTime.valueOrNull == null) return;
    if (_ctrSlideTop.isForwardOrCompleted) {
      _ctrSlideTop.reverse().orCancel;
    } else {
      _ctrSlideTop.forward().orCancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.colorBar,
        body: Stack(alignment: Alignment.center, children: [
          Positioned(
              top: (kToolbarHeight * 2) - 30,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.colorBgUnderCard,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))))),
          CustomScrollView(
              physics: const ClampingScrollPhysics(),
              controller: _scrollCtr,
              slivers: [
                AnimatedBuilder(
                    animation: _ctrSlideTop,
                    builder: (context, child) {
                      return SliverAppBar(
                          backgroundColor:
                              Theme.of(context).colorScheme.colorBar,
                          toolbarHeight: _slideHeight.value,
                          automaticallyImplyLeading: false,
                          flexibleSpace: _sliverAppBar());
                    }),
                SliverToBoxAdapter(child: _header()),
                //
                DecoratedSliver(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.colorBgUnderCard,
                    ),
                    sliver: SliverToBoxAdapter(child: _gallery()))
              ])
        ]));
  }

  Widget _header() {
    return SizedBox(
        width: 300,
        height: 60,
        child: Stack(children: [
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
                          topRight: Radius.circular(20))))),
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
                            offset: const Offset(0, 0))
                      ]),
                  child: Row(children: [
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Icon(
                          Icons.search_outlined,
                          color: Theme.of(context).colorScheme.colorTextSecond,
                          size: 28,
                        )),
                    Flexible(
                        child: HoverClick(
                            onPressedL: (p0) {
                              // Navigator.push(
                              //     context,
                              //     CupertinoPageRoute(
                              //       settings: const RouteSettings(),
                              //       builder: (context) {
                              //         return const SearchPage();
                              //       },
                              //     ));
                            },
                            child: Stack(children: [
                              // SizedBox(
                              //     height: 50,
                              //     width: double.infinity,
                              //     child: Row(children: [
                              //       Expanded(
                              //           child: Text('Search',
                              //               style: TextStyle(
                              //                   color: Theme.of(context)
                              //                       .colorScheme
                              //                       .colorTextSecond,
                              //                   fontSize: 15,
                              //                   fontWeight: FontWeight.w400))),
                              //     ])),
                              Positioned(
                                  right: 15,
                                  bottom: 0,
                                  top: 0,
                                  child: StreamBuilder(
                                      stream: getIt<HistoryRep>().onHistory,
                                      initialData: getIt<HistoryRep>()
                                          .onHistory
                                          .valueOrNull,
                                      builder: (context, snapshot) {
                                        var data = snapshot.data ?? [];
                                        var countDay =
                                            snapshot.data?.length ?? 0;
                                        var count = 0;
                                        for (var it in data) {
                                          count += it.framesCount;
                                        }
                                        return Center(
                                            child: Text('$countDay/$count',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .colorTextSecond,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w400)));
                                      }))
                            ])))
                  ])))
        ]));
  }

  Widget _gallery() {
    return StreamBuilder(
        stream: getIt<HistoryRep>().onHistory,
        builder: (context, snapshot) {
          var history = snapshot.data;
          var size = MediaQuery.of(context).size;
          if (history == null || history.isEmpty) {
            return RotationTransition(
                turns: _iconRotate,
                child: SizedBox(
                    height: size.height / 1.5,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RoundButton(
                              iconData: Icons.create_new_folder_rounded,
                              color: Theme.of(context).colorScheme.colorPrimary,
                              iconColor: Theme.of(context).colorScheme.colorBar,
                              size: (size.width / 5) + 15,
                              iconSize: size.width / 5,
                              useScaleAnimation: true,
                              useShadow: true,
                              onPressed: (p0) {
                                if (_ctrShakeIcon.isForwardOrCompleted) {
                                  _ctrShakeIcon.reverse().orCancel;
                                } else {
                                  _ctrShakeIcon.forward().orCancel;
                                }
                              }),
                          const SizedBox(height: 20),
                          Text('There are no entries yet',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .colorTextAccent,
                                  fontSize: 18)),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Click',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .colorTextAccent,
                                        fontSize: 18)),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Icon(Icons.create_new_folder_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .colorTextSecond
                                            .withValues(alpha: 0.5))),
                                Text('to start',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .colorTextAccent,
                                        fontSize: 18))
                              ])
                        ])));
          }
          return SizedBox(
              height: ((270 + 28) * history.length).toDouble(),
              child: CustomScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  slivers: [
                    SliverList.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          var model = history[index];
                          return ViewRoot(
                              history: model,
                              onCloseSlide: _onCloseSlide,
                              key: ValueKey('history-${model.date}'),
                              onPressed: () {
                                HistoryPageDialog()
                                    .show(
                                        context: context,
                                        history: model,
                                        initialIndex: index)
                                    .then((value) {});
                              },
                              onDelete: () async {
                                await getIt<HistoryRep>()
                                    .deleteHistoryRoot([model]);
                              });
                        })
                  ]));
        });
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
              child: Row(children: [
                Container(
                    width: 100,
                    margin: const EdgeInsets.only(left: 25),
                    child: Text(
                      'Home',
                      style: Theme.of(context).colorScheme.homeCardH1Style,
                    )),
                const Spacer()
              ])))
    ]);
  }
}
