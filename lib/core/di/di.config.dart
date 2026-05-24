// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i409;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/alert/data/models/alert_model.dart' as _i389;
import '../../features/alert/domain/repo/alert_repo.dart' as _i764;
import '../../features/capture/data/models/capture_model.dart' as _i161;
import '../../features/capture_settings/data/models/capture_settings_model.dart'
    as _i979;
import '../../native-api/service_api.dart' as _i987;
import '../../pages/app_model.dart' as _i248;
import '../../pages/history/history_model.dart' as _i30;
import '../../pages/home/filter_model.dart' as _i392;
import '../../pages/settings/settings_model.dart' as _i878;
import '../../repository/camera_rep.dart' as _i973;
import '../../repository/history_rep.dart' as _i837;
import '../../repository/settings_rep.dart' as _i68;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.factory<_i30.HistoryModel>(() => _i30.HistoryModel());
    gh.factory<_i392.FilterModel>(() => _i392.FilterModel());
    gh.factory<_i878.SettingsModel>(() => _i878.SettingsModel());
    gh.lazySingleton<_i837.HistoryRep>(() => _i837.HistoryRep());
    gh.lazySingleton<_i764.AlertRep>(
        () => _i764.AlertRep(gh<_i987.ServiceApi>()));
    gh.factory<_i248.AppModel>(
        () => _i248.AppModel(theme: gh<_i409.ThemeMode>()));
    gh.lazySingleton<_i973.CameraRep>(() => _i973.CameraRep(
          gh<_i987.ServiceApi>(),
          gh<_i764.AlertRep>(),
        ));
    gh.lazySingleton<_i68.SettingsRep>(
        () => _i68.SettingsRep(gh<_i460.SharedPreferences>()));
    gh.factory<_i161.CaptureModel>(() => _i161.CaptureModel(
          cameraRep: gh<_i973.CameraRep>(),
          settingsRep: gh<_i68.SettingsRep>(),
        ));
    gh.factory<_i389.AlertModel>(() => _i389.AlertModel(
          gh<_i68.SettingsRep>(),
          gh<_i764.AlertRep>(),
        ));
    gh.factory<_i979.CaptureSettingsModel>(() => _i979.CaptureSettingsModel(
          gh<_i973.CameraRep>(),
          gh<_i68.SettingsRep>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
