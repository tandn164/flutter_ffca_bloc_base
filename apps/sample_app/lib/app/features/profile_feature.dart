import 'package:api_client/api_client.dart';
import 'package:app_overlay/app_overlay.dart';
import 'package:app_session/app_session.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:profile_data/profile_data.dart';
import 'package:profile_domain/profile_domain.dart';
import 'package:profile_presentation/profile_presentation.dart';

import '../demo/simulate_offline_tile.dart';
import '../network/fake/fake_api_handler.dart';
import '../network/fake/fake_demo_store.dart';
import '../network/fake/fake_profile_handler.dart';
import 'feature_feedback.dart';

ProfileApi createProfileApiService() => ProfileApi.create();

FakeApiHandler createProfileFakeHandler(FakeDemoStore store) {
  return FakeProfileHandler(store);
}

void registerProfileDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<ProfileApi>(
      () => sl<ChopperClient>().getService<ProfileApi>(),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<ProfileApi>()),
    )
    ..registerLazySingleton(() => GetProfile(sl<ProfileRepository>()))
    ..registerLazySingleton(() => UpdateProfile(sl<ProfileRepository>()));
}

StatefulShellBranch createProfileBranch(GetIt sl) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: '/profile',
        builder: (context, _) => ProfilePage(
          createBloc: () => ProfileBloc(
            getProfile: sl<GetProfile>(),
            updateProfile: sl<UpdateProfile>(),
            onSignOut: () => sl<Session>().signOut(),
          ),
          onNotice: (context, notice) {
            showFeatureToast(
              context,
              type: notice.kind == ProfileNoticeKind.error
                  ? ToastType.error
                  : ToastType.success,
              message: notice.message,
            );
          },
          onBusy: busyFeedback(context),
          footer: Column(
            children: [
              SimulateOfflineTile(hint: sl<ConnectivityHint>()),
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('Open onboarding demo'),
                onTap: () => context.go('/onboarding'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
