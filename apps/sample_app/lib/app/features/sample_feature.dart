import 'package:app_overlay/app_overlay.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:sample_presentation/sample_presentation.dart';
import 'sample/sample_di.dart';
import '../di.dart' as app_di;

part 'sample_feature.g.dart';

@TypedGoRoute<SampleRoute>(path: '/sample')
class SampleRoute extends GoRouteData {
  const SampleRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      buildSamplePage(context, app_di.sl);
}

void registerSampleDependencies(GetIt sl) {
  configureSampleDependencies(sl);
}

StatefulShellBranch createSampleBranch(GetIt sl) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        // Keep shell composition and scoped containers app-owned. The path is
        // generated from the same declaration used by SampleRoute().go(context).
        path: const SampleRoute().location,
        builder: (context, _) => buildSamplePage(context, sl),
      ),
    ],
  );
}

Widget buildSamplePage(BuildContext context, GetIt sl) => SamplePage(
      createBloc: () => SampleBloc(
        getSample: sl(),
        createItem: sl(),
        updateItem: sl(),
        deleteItem: sl(),
      )..add(const SampleStarted()),
      onNotice: (context, notice) {
        OverlayScope.of(context).showToast(
          type: notice.kind == SampleNoticeKind.error
              ? ToastType.error
              : ToastType.success,
          message: notice.message,
        );
      },
    );
