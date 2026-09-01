import 'package:api_client/api_client.dart';
import 'package:app_overlay/app_overlay.dart';
import 'package:app_session/app_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('OverlayHost + GoRouter run with StubSession', (tester) async {
    final session = StubSession(restoreDelay: Duration.zero);
    await session.restore();
    final overlay = OverlayController(
      connectivity: FakeConnectivity(),
    );
    final router = GoRouter(
      initialLocation: '/x',
      refreshListenable: session,
      routes: [
        GoRoute(
          path: '/x',
          builder: (_, __) => const Scaffold(body: Text('core-only')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        builder: (context, child) {
          return OverlayHost(
              controller: overlay, child: child ?? const SizedBox.shrink());
        },
      ),
    );

    expect(find.text('core-only'), findsOneWidget);
    expect(find.byType(OverlayHost), findsOneWidget);
    overlay.showToast(type: ToastType.info, message: 'hi');
    await tester.pump();
    expect(find.text('hi'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
