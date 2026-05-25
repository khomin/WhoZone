import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/core/di/di.dart';
import 'package:flutter_demo/features/app/domain/entities/page_type.dart';
import 'package:flutter_demo/features/capture_settings/presentation/pages/capture_settings_page.dart';
import 'package:flutter_demo/components/splash.dart';
import 'package:flutter_demo/core/native-api/service_api.dart';
import 'package:flutter_demo/features/alert/presentation/pages/alert_page.dart';
import 'package:flutter_demo/features/capture/presentation/pages/capture_page.dart';
import 'package:flutter_demo/features/history/data/repo/history_repo_impl.dart';
import 'package:flutter_demo/features/history/domain/repo/history_repo.dart';
import 'package:flutter_demo/features/home/presentation/pages/home_page.dart';
import 'package:flutter_demo/features/app/data/models/app_model.dart';
import 'package:flutter_demo/pages/settings/settings_page.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    _bootstrap();
  }

  void _bootstrap() async {
    await Future.wait([
      Jiffy.setLocale(Constants.locale),
      ServiceApi().initLib(),
    ]);
    await getIt<CameraRep>().init();
    context.read<AppModel>().setReady(true);
    getIt<HistoryRepoImpl>().updateHistory();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.select<AppModel, bool>((v) => v.ready)) {
      return const Splash();
    }
    var padding = MediaQuery.paddingOf(context);
    var collapse = context.select<AppModel, bool>((v) => v.collapse);
    return Container(
        color: Theme.of(context).colorScheme.colorBar,
        child: SafeArea(
            bottom: false,
            child: OrientationBuilder(builder: (context, orientation) {
              return Stack(children: [
                //
                CaptureSettingsPage(),
                //
                AnimatedPositioned(
                    duration: Constants.durationPanel,
                    curve: Curves.easeIn,
                    top: collapse ? Constants.collapseMenuHeight : 0,
                    left: 0,
                    right: 0,
                    bottom: collapse ? -Constants.collapseMenuHeight : 0,
                    child: Stack(children: [
                      Scaffold(
                          body: Stack(children: [
                            Builder(builder: (context) {
                              switch (context
                                  .select<AppModel, PageType>((v) => v.page)) {
                                case PageType.home:
                                  return const HomePagePage();
                                case PageType.capture:
                                  return const CapturePage();
                                case PageType.alert:
                                  return const AlertPage();
                                case PageType.settings:
                                  return const SettingsPage();
                                default:
                                  return const Text('Invalid type');
                              }
                            }),
                          ]),
                          bottomNavigationBar: Container(
                              height: 70 + padding.bottom,
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.bottomNavBg,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 0),
                                    )
                                  ]),
                              child: Builder(builder: (context) {
                                var page = context
                                    .select<AppModel, PageType>((v) => v.page);
                                return SafeArea(
                                    child: BottomNavigationBar(
                                        elevation: 0,
                                        selectedFontSize: 12,
                                        unselectedFontSize: 12,
                                        type: BottomNavigationBarType.fixed,
                                        backgroundColor: Colors.transparent,
                                        selectedItemColor: Theme.of(context)
                                            .colorScheme
                                            .bottomNavIconSelected,
                                        unselectedItemColor: Theme.of(context)
                                            .colorScheme
                                            .bottomNavIconUnselected,
                                        selectedLabelStyle: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        items: const <BottomNavigationBarItem>[
                                          BottomNavigationBarItem(
                                            icon: Icon(Icons.home),
                                            label: 'Home',
                                          ),
                                          BottomNavigationBarItem(
                                              icon: Icon(Icons
                                                  .create_new_folder_rounded),
                                              label: 'Capture'),
                                          BottomNavigationBarItem(
                                              icon: Icon(Icons.notifications),
                                              label: 'Alert'),
                                          BottomNavigationBarItem(
                                              icon: Icon(Icons.settings),
                                              label: 'Settings'),
                                        ],
                                        currentIndex: page.index,
                                        onTap: (value) async {
                                          if (collapse) {
                                            context
                                                .read<AppModel>()
                                                .setCollapse(false);
                                          }
                                          context
                                              .read<AppModel>()
                                              .setPage(PageType.values[value]);
                                        }));
                              })))
                    ]))
              ]);
            })));
  }
}
