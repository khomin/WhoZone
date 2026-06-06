import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/page_background.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/components/item_in_menu_list.dart';
import 'package:flutter_demo/core/di/di.dart';
import 'package:flutter_demo/features/app/data/models/app_model.dart';
import 'package:flutter_demo/pages/settings/settings_about.dart';
import 'package:flutter_demo/pages/settings/settings_model.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/utils/converter.dart';
import 'package:flutter_demo/utils/utils.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final _model = getIt<SettingsModel>();
  final tag = 'settingsPage';

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsModel>.value(
      value: _model,
      child: Scaffold(
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
                      flexibleSpace: _sliverAppBar()),
                  SliverToBoxAdapter(child: _header()),
                  DecoratedSliver(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.colorBgUnderCard,
                      ),
                      sliver: SliverList.list(children: [
                        _account(),
                      ]))
                ],
              )
            ],
          ),
        ),
      ),
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
      height: 15,
      child: Stack(children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 15,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.colorBgUnderCard,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
        )
      ]),
    );
  }

  Widget _account() {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      //
      // data
      ItemInMenuList(
          useBorderTop: false,
          useBorderBot: true,
          margin: Constants.marginCard,
          onPressed: (_) {
            showModalBottomSheet(
                context: context,
                barrierColor: Colors.black26,
                builder: (BuildContext context) {
                  var padding = MediaQuery.paddingOf(context);
                  return Container(
                      height: 250,
                      padding: EdgeInsets.only(bottom: padding.bottom),
                      color: Theme.of(context).colorScheme.colorBgUnderCard,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RoundButton(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .colorButtonRed
                                          .withValues(alpha: 0.8),
                                      size: 55,
                                      radius: 20,
                                      useScaleAnimation: true,
                                      iconData: Icons.delete,
                                      onPressed: (v) async {
                                        context
                                            .read<SettingsModel>()
                                            .freeData();
                                        Navigator.of(context).pop();
                                      }),
                                  const SizedBox(width: 15),
                                  RoundButton(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .colorSecondary
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
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              'Used disk',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.menuFontColor1,
                  fontSize: Constants.menuFontSize2,
                  fontWeight: FontWeight.w400),
            ),
            Row(children: [
              Builder(builder: (context) {
                var mode = context.watch<SettingsModel>();
                return Text(
                  ' ${Converter.convertBytesToKbMbGb(mode.usedDiskSize)}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.menuFontColor1,
                      fontSize: Constants.menuFontSize2,
                      fontWeight: FontWeight.w400),
                );
              }),
              const SizedBox(width: 20),
              Icon(
                Icons.delete_rounded,
                color: Theme.of(context).colorScheme.colorPrimary,
                size: Constants.menuIconSize,
              )
            ]),
          ])),
      //
      // dark-light
      ItemInMenuList(
          useBorderTop: false,
          useBorderBot: false,
          margin: Constants.marginCard,
          child: Row(children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dark mode',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.menuFontColor1,
                          fontSize: Constants.menuFontSize2,
                          fontWeight: FontWeight.w400))
                ]),
            Spacer(),
            Builder(builder: (context) {
              var theme = context.watch<AppModel>().theme;
              var brightness = MediaQuery.platformBrightnessOf(context);
              var isDark = false;
              if (theme == ThemeMode.dark) {
                isDark = true;
              }
              if (theme == ThemeMode.system) {
                isDark = brightness == Brightness.dark;
              }
              return Row(children: [
                Switch(
                    value: isDark,
                    padding: EdgeInsets.zero,
                    onChanged: (value) async {
                      context
                          .read<AppModel>()
                          .setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
                    })
              ]);
            })
          ])),
      //
      // share
      ItemInMenuList(
          useBorderTop: true,
          useBorderBot: false,
          margin: Constants.marginCard,
          onPressed: (_) {
            Utils().shareApp();
          },
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
            Icon(
              Icons.link,
              color: Theme.of(context).colorScheme.colorPrimary,
              size: Constants.menuIconSize,
            )
          ])),
      //
      // about the app
      ItemInMenuList(
          useBorderTop: true,
          useBorderBot: false,
          margin: Constants.marginCard,
          onPressed: (_) {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    settings: const RouteSettings(),
                    builder: (context) {
                      return const SettingsAbout();
                    }));
          },
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
              size: Constants.menuIconSize,
            )
          ])),
      //
      // license
      ItemInMenuList(
          useBorderTop: true,
          useBorderBot: true,
          margin: Constants.marginCard,
          onPressed: (_) {
            showLicensePage(context: context);
          },
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
              size: Constants.menuIconSize,
            )
          ])),
      //
      // version
      ItemInMenuList(
          useBorderTop: false,
          useBorderBot: false,
          margin: Constants.marginCard,
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
  }
}
