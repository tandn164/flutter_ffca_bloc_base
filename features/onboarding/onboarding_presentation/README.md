# Onboarding Presentation

A configurable `PageView` onboarding screen. The application owns copy,
illustrations, localization, navigation, and completion behavior.

```dart
OnboardingPage(
  steps: [
    OnboardingStep(
      title: strings.welcome,
      description: strings.welcomeBody,
      illustration: (_) => const WelcomeIllustration(),
    ),
  ],
  onComplete: () async {
    await completeOnboarding('main-v1');
    router.go('/home');
  },
)
```

The page does not import storage, GetIt, or a router.
