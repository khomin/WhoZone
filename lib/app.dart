import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/camera_settings_page.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/components/splash.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/native-api/service_api.dart';
import 'package:flutter_demo/pages/alert/alert_model.dart';
import 'package:flutter_demo/pages/alert/alert_page.dart';
import 'package:flutter_demo/pages/capture/capture_page.dart';
import 'package:flutter_demo/pages/home/home_page.dart';
import 'package:flutter_demo/pages/capture/capture_model.dart';
import 'package:flutter_demo/pages/app_model.dart';
import 'package:flutter_demo/pages/settings/settings_page.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/repository/nav_rep.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/utils/file_utils.dart';
import 'package:flutter_demo/utils/log_printer.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  late AppModel _appModel;
  late final AlertModel _alertModel;
  late final CaptureModel _captureModel;

  @override
  void initState() {
    super.initState();

    _captureModel = CaptureModel(
      captureIntervalSec: getIt<SettingsRep>().getCaptureIntervalSec(),
    );
    _alertModel = AlertModel();

    _bootstrap();
  }

  void _bootstrap() async {
    Loggy.initLoggy(logPrinter: LogPrinter());

    Future.wait([
      Jiffy.setLocale('uk'),
      Utils.init(),
      ServiceApi().initLib(),
    ]);
    _alertModel.init();

    await getIt<CameraRep>().init();

    _appModel.setReady(true);

    _handleInitialRoute();
  }

  void _handleInitialRoute() {
    if (Constants.isTestMode) {
      Timer(const Duration(seconds: 1), () {
        NavigatorRep().routeBloc.goto(Panel(type: PageType.capture));
      });
    }
  }

  @override
  void didChangeDependencies() {
    _appModel = context.read<AppModel>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _alertModel.dispose();
    _captureModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<CaptureModel>.value(value: _captureModel),
          ChangeNotifierProvider<AlertModel>.value(value: _alertModel)
        ],
        builder: (context, child) {
          var collapse = context.select<AppModel, bool>((v) => v.collapse);
          var size = MediaQuery.sizeOf(context);
          if (!context.select<AppModel, bool>((v) => v.ready)) {
            return const Splash();
          }
          var padding = MediaQuery.paddingOf(context);
          return RepaintBoundary(
              child: Container(
                  color: Theme.of(context).colorScheme.colorBar,
                  child: SafeArea(
                      bottom: false,
                      child: Stack(children: [
                        const CameraSettingsPage(),
                        AnimatedPositioned(
                            duration: Constants.durationPanel,
                            curve: Curves.easeIn,
                            top: collapse ? Constants.collapseMenuHeight : 0,
                            left: 0,
                            right: 0,
                            bottom:
                                collapse ? -Constants.collapseMenuHeight : 0,
                            child: Stack(children: [
                              Scaffold(
                                  body: Stack(children: [
                                    StreamBuilder(
                                        stream: NavigatorRep().routeBloc.onGoto,
                                        builder: (context, snapshot) {
                                          var page = snapshot.data?.type;
                                          switch (page) {
                                            case PageType.home:
                                              return const HomePagePage();
                                            case PageType.capture:
                                              return const CapturePage();
                                            case PageType.alert:
                                              return const AlertPage();
                                            case PageType.settings:
                                              return const SettingsPage();
                                            default:
                                              return const HomePagePage();
                                          }
                                        }),
                                  ]),
                                  bottomNavigationBar: Container(
                                      height: 70 + padding.bottom,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .bottomNavBg,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 10,
                                              offset: const Offset(0, 0),
                                            )
                                          ]),
                                      child: StreamBuilder(
                                          stream:
                                              NavigatorRep().routeBloc.onGoto,
                                          builder: (context, snapshot) {
                                            var page = snapshot.data?.type;
                                            return SafeArea(
                                                child: BottomNavigationBar(
                                                    elevation: 0,
                                                    selectedFontSize: 12,
                                                    unselectedFontSize: 12,
                                                    type: BottomNavigationBarType
                                                        .fixed,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    selectedItemColor: Theme.of(
                                                            context)
                                                        .colorScheme
                                                        .bottomNavIconSelected,
                                                    unselectedItemColor: Theme
                                                            .of(context)
                                                        .colorScheme
                                                        .bottomNavIconUnselected,
                                                    selectedLabelStyle:
                                                        const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                                          icon: Icon(Icons
                                                              .notifications),
                                                          label: 'Alert'),
                                                      BottomNavigationBarItem(
                                                          icon: Icon(
                                                              Icons.settings),
                                                          label: 'Settings'),
                                                    ],
                                                    currentIndex:
                                                        page?.index ?? 0,
                                                    onTap: (value) async {
                                                      if (collapse) {
                                                        context
                                                            .read<AppModel>()
                                                            .setCollapse(false);
                                                      }
                                                      NavigatorRep()
                                                          .routeBloc
                                                          .goto(Panel(
                                                              type: PageType
                                                                      .values[
                                                                  value]));
                                                    }));
                                          })))
                            ]))
                      ]))));
        });
  }
}
