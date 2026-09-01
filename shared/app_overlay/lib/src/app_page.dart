import 'package:flutter/material.dart';

import 'overlay_controller.dart';
import 'overlay_scope.dart';
import 'page_policy.dart';

class AppPage extends StatefulWidget {
  const AppPage({
    required this.child,
    this.pageConfig = PageConfig.inherit,
    super.key,
  });

  final Widget child;
  final PageConfig pageConfig;

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  final Object _owner = Object();
  OverlayController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = OverlayScope.of(context);
    _sync();
  }

  @override
  void didUpdateWidget(covariant AppPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageConfig != widget.pageConfig) _sync();
  }

  void _sync() {
    if (!TickerMode.of(context)) return;
    final controller = _controller!;
    final config = widget.pageConfig;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.activatePage(_owner, config);
    });
  }

  @override
  void dispose() {
    _controller?.deactivatePage(_owner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.pageConfig = PageConfig.inherit,
    this.actions,
    this.floatingActionButton,
    super.key,
  });

  final Widget body;
  final String? title;
  final PageConfig pageConfig;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      pageConfig: pageConfig,
      child: Scaffold(
        appBar: title == null
            ? null
            : AppBar(title: Text(title!), actions: actions),
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
