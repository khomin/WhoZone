import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/app.dart';
import 'package:flutter_demo/pages/app_model.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/repository/history_rep.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  getIt.registerLazySingleton<CameraRep>(() => CameraRep());
  getIt.registerLazySingleton<HistoryRep>(() => HistoryRep());

  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SettingsRep>(() => SettingsRep(prefs));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.instantiate(FlavorType.google);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
    statusBarColor: Colors.transparent,
  ));

  await initDependencies();

  await getIt<SettingsRep>().init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppModel(
        theme: getIt<SettingsRep>().getTheme(),
      ),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = context.select<AppModel, ThemeMode>((v) => v.theme);
    final bool isDark = theme == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
        : theme == ThemeMode.dark;
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
