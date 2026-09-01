import 'package:flutter/widgets.dart';

class OnboardingStep {
  const OnboardingStep({
    required this.title,
    required this.description,
    required this.illustration,
  });

  final String title;
  final String description;
  final WidgetBuilder illustration;
}
