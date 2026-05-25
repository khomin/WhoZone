import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/app.dart';
import 'package:flutter_demo/core/di/di.dart';
import 'package:flutter_demo/features/app/data/models/app_model.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/utils/log_printer.dart';
import 'package:flutter_demo/utils/utils.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();

  AppConfig.instantiate(FlavorType.google);

  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
    Utils.init(),
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
    statusBarColor: Colors.transparent,
  ));
  Loggy.initLoggy(logPrinter: LogPrinter());

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppModel(
        theme: getIt<SettingsRep>().getTheme(),
      ),
      child: const MainApp(),
    ),
  );
}

// TODO: clean architecture
// TODO: tensorflow
// TODO: doc
// TODO: publish again
// TODO: reddit posts

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = context.select<AppModel, ThemeMode>((v) => v.theme);
    final bool isDark = theme == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
        : theme == ThemeMode.dark;
    // TODO: is this pro?
    Future.microtask(() {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ));
    });
    return MaterialApp(
      title: Constants.appName,
      themeMode: theme,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const App(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      useMaterial3: true,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark
            ? AppColorScheme.bottomBarDark
            : AppColorScheme.bottomBarLight,
      ),
    );
  }
}
