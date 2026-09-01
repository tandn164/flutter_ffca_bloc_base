import 'package:flutter/material.dart';
import 'package:tutorial_engine/tutorial_engine.dart';

import 'loading_handle.dart';
import 'overlay_controller.dart';
import 'overlay_feedback.dart';
import 'overlay_scope.dart';
import 'toast_queue.dart';

typedef ToastBuilder = Widget Function(BuildContext context, ToastItem item);
typedef OfflineBuilder = Widget Function(BuildContext context);

class OverlayHost extends StatelessWidget {
  const OverlayHost({
    required this.controller,
    required this.child,
    this.loadingBuilder,
    this.toastBuilder,
    this.offlineBannerBuilder,
    this.offlineBlockBuilder,
    this.tutorialContentBuilder,
    super.key,
  });

  final OverlayController controller;
  final Widget child;
  final LoadingContentBuilder? loadingBuilder;
  final ToastBuilder? toastBuilder;
  final OfflineBuilder? offlineBannerBuilder;
  final OfflineBuilder? offlineBlockBuilder;
  final TutorialContentBuilder? tutorialContentBuilder;

  @override
  Widget build(BuildContext context) {
    return OverlayScope(
      controller: controller,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          ListenableBuilder(
            listenable: Listenable.merge([
              controller,
              controller.tutorialController,
            ]),
            builder: (context, _) {
              final tutorial = controller.tutorialController.isActive;
              final blocking =
                  controller.showBlock || controller.isLoading || tutorial;
              return IgnorePointer(
                ignoring: !blocking,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (controller.showBanner)
                      (offlineBannerBuilder ?? _defaultOfflineBanner)(context),
                    _ToastLayer(
                      toasts: controller.toasts,
                      builder: toastBuilder ?? _defaultToast,
                    ),
                    if (controller.showBlock)
                      Positioned.fill(
                        child: (offlineBlockBuilder ?? _defaultOfflineBlock)(
                          context,
                        ),
                      ),
                    if (controller.isLoading)
                      Positioned.fill(
                        child: _LoadingLayer(
                          builder: controller.loadingContentBuilder ??
                              loadingBuilder,
                        ),
                      ),
                    if (tutorial)
                      Positioned.fill(
                        child: TutorialLayer(
                          controller: controller.tutorialController,
                          contentBuilder:
                              tutorialContentBuilder ?? _defaultTutorialContent,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LoadingLayer extends StatelessWidget {
  const _LoadingLayer({this.builder});

  final LoadingContentBuilder? builder;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.18),
      child: Center(
        child: builder?.call(context) ??
            const SizedBox.square(
              dimension: 36,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
      ),
    );
  }
}

class _ToastLayer extends StatelessWidget {
  const _ToastLayer({required this.toasts, required this.builder});

  final List<ToastItem> toasts;
  final ToastBuilder builder;

  @override
  Widget build(BuildContext context) {
    if (toasts.isEmpty) return const SizedBox.shrink();
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: builder(context, toasts.single),
    );
  }
}

Widget _surface(BuildContext context, Widget child) {
  return Material(
    color: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Padding(padding: const EdgeInsets.all(14), child: child),
  );
}

Widget _defaultToast(BuildContext context, ToastItem item) {
  final color = switch (item.type) {
    ToastType.success => Colors.green,
    ToastType.error => Theme.of(context).colorScheme.error,
    ToastType.warning => Colors.orange,
    ToastType.info => Theme.of(context).colorScheme.primary,
  };
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: _surface(
      context,
      Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(item.message)),
        ],
      ),
    ),
  );
}

Widget _defaultOfflineBanner(BuildContext context) {
  return Positioned(
    top: 0,
    left: 16,
    right: 16,
    child: SafeArea(
      bottom: false,
      child: _surface(
        context,
        const Row(
          children: [
            Icon(Icons.wifi_off_rounded, size: 18),
            SizedBox(width: 10),
            Text('No internet'),
          ],
        ),
      ),
    ),
  );
}

Widget _defaultOfflineBlock(BuildContext context) {
  return Stack(
    fit: StackFit.expand,
    children: [
      ModalBarrier(
        dismissible: false,
        color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.18),
      ),
      Center(
        child: _surface(
          context,
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 36),
              SizedBox(height: 12),
              Text('No internet'),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _defaultTutorialContent(
  BuildContext context,
  String tourId,
  VoidCallback complete,
) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: _surface(
        context,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tourId, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton(onPressed: complete, child: const Text('Done')),
          ],
        ),
      ),
    ),
  );
}
