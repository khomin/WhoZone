import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/components/item_in_menu_list.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/pages/alert/alert_model.dart';
import 'package:flutter_demo/pages/settings/settings_about.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/repository/history_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/utils/converter.dart';
import 'package:flutter_demo/utils/file_utils.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late AlertModel _model;
  final _itemHeight = 60.0;
  final tag = 'settingsPage';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      _model.init();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _model = context.read<AlertModel>();
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
          CustomScrollView(physics: const ClampingScrollPhysics(), slivers: [
            SliverAppBar(
                backgroundColor: Theme.of(context).colorScheme.colorBar,
                automaticallyImplyLeading: false,
                flexibleSpace: _sliverAppBar()),
            SliverToBoxAdapter(child: _header()),
            DecoratedSliver(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.colorBgUnderCard,
                ),
                sliver: _list())
          ])
        ]));
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
                  child: Text('Settings',
                      style: Theme.of(context).colorScheme.homeCardH1Style),
                ),
                const Spacer()
              ])))
    ]);
  }

  Widget _header() {
    return SizedBox(
        width: 300,
        height: 30,
        child: Stack(children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.colorBgUnderCard,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)))))
        ]));
  }

  Widget _list() {
    return SliverList.list(children: [
      //
      _account(),
      //
      _others()
    ]);
  }

  Widget _account() {
    return Builder(builder: (context) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
                padding:
                    EdgeInsets.only(top: 10, bottom: 30, left: 25, right: 25),
                child: Row(children: [
                  Text('Account',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.menuFontColor1,
                          fontSize: Constants.menuFontSize1,
                          fontWeight: FontWeight.w400))
                ])),
            //
            // data
            ItemInMenuList(
                height: _itemHeight,
                useBorderTop: true,
                useBorderBot: true,
                onClicked: () {
                  showModalBottomSheet(
                      context: context,
                      barrierColor: Colors.black26,
                      builder: (BuildContext context) {
                        return Container(
                            height: 200,
                            color:
                                Theme.of(context).colorScheme.colorBgUnderCard,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Want to free data?',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .menuFontColor1,
                                          fontSize: Constants.menuFontSize1,
                                          fontWeight: FontWeight.w400)),
                                  const SizedBox(height: 30),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        RoundButton(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .colorButtonRed
                                                .withValues(alpha: 0.8),
                                            iconColor: Theme.of(context)
                                                .colorScheme
                                                .colorCard
                                                .withValues(alpha: 0.8),
                                            size: 55,
                                            radius: 20,
                                            useScaleAnimation: true,
                                            iconData: Icons.delete,
                                            onPressed: (v) async {
                                              Navigator.of(context).pop();
                                              getIt<HistoryRep>().freeData();
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
                                            size: 55,
                                            radius: 20,
                                            useScaleAnimation: true,
                                            iconData: Icons.close,
                                            onPressed: (v) {
                                              Navigator.of(context).pop();
                                            })
                                      ])
                                ]));
                      });
                },
                child: Row(children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Used disk',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .menuFontColor1,
                                fontSize: Constants.menuFontSize2,
                                fontWeight: FontWeight.w400))
                      ]),
                  const Spacer(),
                  const SizedBox(width: 20),
                  StreamBuilder(
                      stream: getIt<CameraRep>().onHistoryDataSize,
                      initialData:
                          getIt<CameraRep>().onHistoryDataSize.valueOrNull,
                      builder: (context, snapshot) {
                        var size = snapshot.data ?? Int64.ZERO;
                        return Text(' ${Converter.convertBytesToKbMbGb(size)}',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .menuFontColor1,
                                fontSize: Constants.menuFontSize2,
                                fontWeight: FontWeight.w400));
                      }),
                  const SizedBox(width: 20),
                  Icon(Icons.delete_rounded,
                      color: Theme.of(context).colorScheme.colorPrimary)
                ]))
          ]);
    });
  }

  Widget _others() {
    return Builder(builder: (context) {
      return Column(children: [
        Padding(
            padding: EdgeInsets.only(top: 40, bottom: 30, left: 25, right: 25),
            child: Row(children: [
              Text('Others',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.menuFontColor2,
                      fontSize: Constants.menuFontSize1,
                      fontWeight: FontWeight.w400))
            ])),
        //
        // share
        ItemInMenuList(
            useBorderTop: true,
            useBorderBot: false,
            onClicked: () {
              Utils().shareApp();
            },
            height: _itemHeight,
            child: Row(children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Share this app',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.menuFontColor1,
                            fontSize: Constants.menuFontSize2,
                            fontWeight: FontWeight.w400))
                  ]),
              Spacer(),
              Icon(Icons.link,
                  color: Theme.of(context).colorScheme.colorPrimary)
            ])),
        //
        // about the app
        ItemInMenuList(
            useBorderTop: true,
            useBorderBot: false,
            onClicked: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      settings: const RouteSettings(),
                      builder: (context) {
                        return const SettingsAbout();
                      }));
            },
            height: _itemHeight,
            child: Row(children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.menuFontColor1,
                          fontSize: Constants.menuFontSize2,
                          fontWeight: FontWeight.w400),
                    ),
                  ]),
              Spacer(),
              Icon(
                Icons.info_rounded,
                color: Theme.of(context).colorScheme.colorPrimary,
              )
            ])),
        //
        // lincenses
        ItemInMenuList(
            useBorderTop: true,
            useBorderBot: true,
            onClicked: () {
              showLicensePage(context: context);
            },
            height: _itemHeight,
            child: Row(children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Licenses',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.menuFontColor1,
                            fontSize: Constants.menuFontSize2,
                            fontWeight: FontWeight.w400))
                  ]),
              Spacer(),
              Icon(
                Icons.description,
                color: Theme.of(context).colorScheme.colorPrimary,
              )
            ])),
        //
        // version
        ItemInMenuList(
            useBorderTop: false,
            useBorderBot: false,
            height: 170,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Column(children: [
                  const SizedBox(height: 30),
                  Text('${Constants.appName} ${Constants.appVersion}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.menuFontColor2,
                          fontSize: Constants.menuFontSize3,
                          fontWeight: FontWeight.w400))
                ])
              ]),
              const SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset(
                  'assets/logo.png',
                  width: 60,
                  height: 60,
                  cacheWidth: 150,
                )
              ])
            ]))
      ]);
    });
  }
}
