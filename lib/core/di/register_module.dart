import 'package:flutter_demo/features/settings/data/repo/settings_repo_impl.dart';
import 'package:flutter_demo/features/settings/domain/repo/settings_repo.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  SettingsRepo settings(SharedPreferences prefs) {
    return SettingsRepoImpl(prefs);
  }
}
