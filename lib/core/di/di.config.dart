// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/alert/data/models/alert_model.dart' as _i389;
import '../../features/alert/data/repo/alert_repo.dart' as _i925;
import '../../features/app/data/models/app_model.dart' as _i290;
import '../../features/capture/data/models/capture_model.dart' as _i161;
import '../../features/history/data/models/history_model.dart' as _i948;
import '../../features/history/data/repo/history_repo_impl.dart' as _i392;
import '../../features/history/domain/repo/history_repo.dart' as _i231;
import '../../features/home/data/models/filter_model.dart' as _i402;
import '../../features/home/data/models/home_model.dart' as _i187;
import '../../pages/settings/settings_model.dart' as _i878;
import '../../repository/camera_rep.dart' as _i973;
import '../../repository/settings_rep.dart' as _i68;
import '../native-api/service_api.dart' as _i371;
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
    gh.factory<_i402.FilterModel>(() => _i402.FilterModel());
    gh.lazySingleton<_i371.ServiceApi>(() => _i371.ServiceApi());
    gh.lazySingleton<_i231.HistoryRepo>(() => _i392.HistoryRepoImpl());
    gh.factory<_i948.HistoryModel>(
        () => _i948.HistoryModel(gh<_i231.HistoryRepo>()));
    gh.factory<_i187.HomeModel>(() => _i187.HomeModel(gh<_i231.HistoryRepo>()));
    gh.factory<_i878.SettingsModel>(
        () => _i878.SettingsModel(gh<_i231.HistoryRepo>()));
    gh.lazySingleton<_i925.AlertRep>(
        () => _i925.AlertRep(gh<_i371.ServiceApi>()));
    gh.lazySingleton<_i68.SettingsRep>(
        () => _i68.SettingsRep(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i973.CameraRep>(() => _i973.CameraRep(
          gh<_i371.ServiceApi>(),
          gh<_i925.AlertRep>(),
        ));
    gh.factory<_i389.AlertModel>(() => _i389.AlertModel(
          gh<_i68.SettingsRep>(),
          gh<_i925.AlertRep>(),
        ));
    gh.factory<_i290.AppModel>(() => _i290.AppModel(gh<_i68.SettingsRep>()));
    gh.factory<_i161.CaptureModel>(() => _i161.CaptureModel(
          cameraRep: gh<_i973.CameraRep>(),
          settingsRep: gh<_i68.SettingsRep>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
