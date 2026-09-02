import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:local_storage/local_storage.dart';
import 'package:onboarding_data/onboarding_data.dart';
import 'package:onboarding_domain/onboarding_domain.dart';
import 'package:onboarding_presentation/onboarding_presentation.dart';

const sampleOnboardingFlowId = 'sample-main-v1';

void registerOnboardingDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<OnboardingRepository>(
      () => StoredOnboardingRepository(sl<KeyValueStore>()),
    )
    ..registerLazySingleton(
      () => ShouldShowOnboarding(sl<OnboardingRepository>()),
    )
    ..registerLazySingleton(
      () => CompleteOnboarding(sl<OnboardingRepository>()),
    );
}

List<RouteBase> createOnboardingRoutes(GetIt sl) {
  return [
    GoRoute(
      path: '/onboarding',
      builder: (context, _) => OnboardingPage(
        steps: [
          OnboardingStep(
            title: 'Reusable capabilities',
            description: 'The sample app composes features from the base.',
            illustration: (_) => const Icon(Icons.extension, size: 96),
          ),
          OnboardingStep(
            title: 'Offline-ready UX',
            description: 'Safe writes can be queued and synchronized later.',
            illustration: (_) => const Icon(Icons.cloud_sync, size: 96),
          ),
        ],
        onComplete: () async {
          await sl<CompleteOnboarding>()(sampleOnboardingFlowId);
          if (context.mounted) context.go('/home');
        },
        onSkip: () => context.go('/home'),
      ),
    ),
  ];
}
