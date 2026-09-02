// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_feature.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $sampleRoute,
    ];

RouteBase get $sampleRoute => GoRouteData.$route(
      path: '/sample',
      factory: $SampleRouteExtension._fromState,
    );

extension $SampleRouteExtension on SampleRoute {
  static SampleRoute _fromState(GoRouterState state) => const SampleRoute();

  String get location => GoRouteData.$location(
        '/sample',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
