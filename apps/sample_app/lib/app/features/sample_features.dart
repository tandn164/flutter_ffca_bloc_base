import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_feature.dart';
import 'sample_feature.dart';
import 'showcase_feature.dart';

/// The build-time feature set selected by sample_app.
void registerSampleFeatureDependencies(GetIt sl) {
  registerSampleDependencies(sl);
  registerOnboardingDependencies(sl);
}

List<RouteBase> createSamplePublicFeatureRoutes(GetIt sl) {
  return [
    ...createOnboardingRoutes(sl),
    ...createShowcaseRoutes(),
  ];
}

List<StatefulShellBranch> createSampleShellBranches(GetIt sl) {
  return [createShowcaseBranch(sl), createSampleBranch(sl)];
}
