import 'package:app_overlay/app_overlay.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// App bootstrap splash — not a business feature. Session restore is injected.
class SplashPage extends StatefulWidget {
  const SplashPage({required this.onRestore, super.key});

  final Future<void> Function() onRestore;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    widget.onRestore();
  }

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      pageConfig: PageConfig.splash,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppMark(size: 72),
            SizedBox(height: 28),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ],
        ),
      ),
    );
  }
}
