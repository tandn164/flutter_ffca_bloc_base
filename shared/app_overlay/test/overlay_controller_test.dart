import 'package:app_connectivity/app_connectivity.dart';
import 'package:app_overlay/app_overlay.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loading handles are idempotent and reference counted', () {
    final controller =
        OverlayController(connectivity: MutableConnectivityHint());
    final first = controller.showLoading();
    final second = controller.showLoading();

    expect(controller.loadingCount, 2);
    first
      ..close()
      ..close();
    expect(controller.loadingCount, 1);
    second.close();
    expect(controller.isLoading, isFalse);
  });

  test('page policy overrides the app default', () {
    final connectivity = MutableConnectivityHint()..setOffline(true);
    final controller = OverlayController(
      connectivity: connectivity,
      defaultPageConfig: const PageConfig(
        noInternet: NoInternetMode.banner,
      ),
    );

    controller.activatePage(
      Object(),
      const PageConfig(noInternet: NoInternetMode.block),
    );

    expect(controller.showBanner, isFalse);
    expect(controller.showBlock, isTrue);
  });

  testWidgets('toasts occupy one fixed slot and advance after duration',
      (tester) async {
    final controller =
        OverlayController(connectivity: MutableConnectivityHint());
    controller.showToast(
      type: ToastType.success,
      message: 'first',
      duration: const Duration(seconds: 1),
    );
    controller.showToast(
      type: ToastType.warning,
      message: 'second',
      duration: const Duration(seconds: 1),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: OverlayHost(
          controller: controller,
          child: const SizedBox.expand(),
        ),
      ),
    );
    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('first'), findsNothing);
    expect(find.text('second'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('host covers the complete child and accepts custom loading',
      (tester) async {
    final controller =
        OverlayController(connectivity: MutableConnectivityHint());
    controller.showLoading(
      contentBuilder: (_) => const Text('custom-loading'),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: OverlayHost(
          controller: controller,
          child: const Text('navigator-and-bars'),
        ),
      ),
    );

    expect(find.text('navigator-and-bars'), findsOneWidget);
    expect(find.text('custom-loading'), findsOneWidget);
  });
}
