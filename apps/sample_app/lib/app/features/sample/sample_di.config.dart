// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sample_app/app/features/sample/sample_di.dart' as _i53;
import 'package:sample_domain/sample_domain.dart' as _i180;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt initSampleFeature({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final sampleModule = _$SampleModule();
    gh.lazySingleton<_i180.SampleRepository>(() => sampleModule.repository());
    gh.lazySingleton<_i180.GetSample>(
        () => sampleModule.getSample(gh<_i180.SampleRepository>()));
    gh.lazySingleton<_i180.CreateSampleItem>(
        () => sampleModule.createItem(gh<_i180.SampleRepository>()));
    gh.lazySingleton<_i180.UpdateSampleItem>(
        () => sampleModule.updateItem(gh<_i180.SampleRepository>()));
    gh.lazySingleton<_i180.DeleteSampleItem>(
        () => sampleModule.deleteItem(gh<_i180.SampleRepository>()));
    return this;
  }
}

class _$SampleModule extends _i53.SampleModule {}
