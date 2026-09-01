import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../network/fake/fake_api_handler.dart';
import '../network/fake/fake_demo_store.dart';
import 'auth_feature.dart';
import 'feed_feature.dart';
import 'onboarding_feature.dart';
import 'profile_feature.dart';

/// The build-time feature set selected by sample_app.
void registerDemoFeatureDependencies(GetIt sl) {
  registerAuthDependencies(sl);
  registerFeedDependencies(sl);
  registerProfileDependencies(sl);
  registerOnboardingDependencies(sl);
}

List<ChopperService> createDemoApiServices() {
  return [
    createAuthApiService(),
    createFeedApiService(),
    createProfileApiService(),
  ];
}

Set<String> get demoHandshakePaths => authHandshakePaths;

List<RouteBase> createDemoPublicFeatureRoutes(GetIt sl) {
  return [
    ...createAuthRoutes(sl),
    ...createOnboardingRoutes(sl),
  ];
}

List<StatefulShellBranch> createDemoShellBranches(GetIt sl) {
  return [createFeedBranch(sl), createProfileBranch(sl)];
}

List<FakeApiHandler> createDemoFakeHandlers() {
  final store = FakeDemoStore();
  return [
    createAuthFakeHandler(store),
    createProfileFakeHandler(store),
    createFeedFakeHandler(store),
  ];
}
