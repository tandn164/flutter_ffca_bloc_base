import 'package:api_client/api_client.dart';
import 'package:app_overlay/app_overlay.dart';
import 'package:flutter/material.dart';
import 'package:sample_app/app/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorial_engine/tutorial_engine.dart';

OverlayController _controller({
  FakeConnectivity? net,
  AppConfig config = const AppConfig(),
  TutorialStore? tutorials,
}) {
  return OverlayController(
    connectivity: net ?? FakeConnectivity(),
    defaultPageConfig: PageConfig(
      noInternet: config.defaultNoInternet,
    ),
    tutorialController: TutorialController(store: tutorials),
  );
}

void main() {
  test('loading ref-count hides at 0', () {
    final overlay = _controller();
    overlay.pushLoading();
    overlay.pushLoading();
    expect(overlay.loadingCount, 2);
    overlay.popLoading();
    expect(overlay.isLoading, isTrue);
    overlay.popLoading();
    expect(overlay.isLoading, isFalse);
    overlay.popLoading();
    expect(overlay.loadingCount, 0);
  });

  test('toast queue caps at 5, dedupes, and shows one fixed item', () {
    final overlay = _controller();
    for (var i = 0; i < 6; i++) {
      overlay.showToast(type: ToastType.info, message: 'm$i');
    }
    expect(overlay.queuedToastCount, 5);
    expect(overlay.toasts, hasLength(1));
    overlay.showToast(type: ToastType.info, message: 'm5');
    expect(overlay.queuedToastCount, 5);
  });

  test('PageConfig off does not show banner or block while offline', () {
    final net = FakeConnectivity()..setOffline(true);
    final overlay = _controller(net: net);
    overlay.setPageConfig(PageConfig.splash);
    expect(overlay.showBanner, isFalse);
    expect(overlay.showBlock, isFalse);

    overlay.setPageConfig(const PageConfig(noInternet: NoInternetMode.banner));
    expect(overlay.showBanner, isTrue);

    overlay.setPageConfig(const PageConfig(noInternet: NoInternetMode.block));
    expect(overlay.showBlock, isTrue);
    expect(overlay.showBanner, isFalse);
  });

  test('visible page wins when another scaffold deactivates', () {
    final net = FakeConnectivity()..setOffline(true);
    final overlay = _controller(net: net);
    final splash = Object();
    final home = Object();
    overlay.activatePage(splash, PageConfig.splash);
    overlay.activatePage(
        home, const PageConfig(noInternet: NoInternetMode.banner));
    expect(overlay.showBanner, isTrue);
    overlay.deactivatePage(home);
    expect(overlay.showBanner, isFalse);
  });

  test('tutorial hasSeen skips second start unless forced', () {
    final store = MemoryTutorialStore();
    final overlay = _controller(tutorials: store);
    expect(overlay.startTutorial('onboarding'), isTrue);
    overlay.endTutorial();
    expect(store.hasSeen('onboarding'), isTrue);
    expect(overlay.startTutorial('onboarding'), isFalse);
    expect(overlay.tutorialTourId, isNull);
    expect(overlay.startTutorial('onboarding', force: true), isTrue);
  });

  testWidgets('overlay ticks do not duplicate navigator GlobalKeys',
      (tester) async {
    final overlay = _controller();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => OverlayHost(
          controller: overlay,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const Scaffold(body: Text('home')),
      ),
    );

    overlay.showToast(type: ToastType.info, message: 'hi');
    overlay.pushLoading();
    await tester.pump();
    overlay.popLoading();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('home'), findsOneWidget);
    expect(find.text('hi'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('toast survives Navigator.pop', (tester) async {
    final overlay = _controller();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => OverlayHost(
          controller: overlay,
          child: child ?? const SizedBox.shrink(),
        ),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  overlay.showToast(type: ToastType.success, message: 'Saved');
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(body: Text('second')),
                    ),
                  );
                },
                child: const Text('go'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('second'), findsOneWidget);

    Navigator.of(tester.element(find.text('second'))).pop();
    await tester.pump();
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('second'), findsNothing);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('loading layer covers the tab bar', (tester) async {
    final overlay = _controller();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => OverlayHost(
          controller: overlay,
          child: child ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: NavigationBar(
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.person), label: 'Me'),
            ],
          ),
        ),
      ),
    );

    overlay.pushLoading();
    await tester.pump();

    final loading = tester.getRect(find.byType(ColoredBox).last);
    final tab = tester.getRect(find.byType(NavigationBar));
    expect(loading.overlaps(tab), isTrue);
    expect(loading.top, lessThanOrEqualTo(tab.top));
    expect(loading.bottom, greaterThanOrEqualTo(tab.bottom));
  });

  testWidgets('Done dismisses tutorial overlay', (tester) async {
    final overlay = _controller();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => OverlayHost(
          controller: overlay,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const Scaffold(body: Text('page')),
      ),
    );
    overlay.startTutorial('demo', force: true);
    await tester.pump();
    await tester.pump();
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pump();
    expect(overlay.tutorialTourId, isNull);
    expect(overlay.tutorialStore.hasSeen('demo'), isTrue);
    expect(find.text('Done'), findsNothing);
  });

  test('cancelTutorial does not persist hasSeen', () {
    final overlay = _controller();
    overlay.startTutorial('demo');
    overlay.cancelTutorial();
    expect(overlay.tutorialTourId, isNull);
    expect(overlay.tutorialStore.hasSeen('demo'), isFalse);
  });
}
