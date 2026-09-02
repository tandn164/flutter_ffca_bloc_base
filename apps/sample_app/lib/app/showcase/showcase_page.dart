import 'dart:async';

import 'package:app_connectivity/app_connectivity.dart';
import 'package:app_logging/app_logging.dart';
import 'package:app_navigation/app_navigation.dart';
import 'package:app_overlay/app_overlay.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({
    required this.connectivity,
    required this.logSink,
    required this.logReader,
    required this.openLocation,
    super.key,
  });

  final MutableConnectivityHint connectivity;
  final LogSink logSink;
  final LogReader logReader;
  final ValueChanged<String> openLocation;

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _showSkeleton = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Base capabilities',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Trigger reusable building blocks here. The Sample list tab shows '
            'a complete feature-first clean architecture flow.',
          ),
          const SizedBox(height: 16),
          _CapabilityCard(
            title: 'Global overlay',
            description: 'Toast, loading, and tutorial live above navigation.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in ToastType.values.take(3))
                  OutlinedButton(
                    onPressed: () => _showToast(type),
                    child: Text(type.name),
                  ),
                FilledButton(
                  onPressed: _showLoading,
                  child: const Text('Loading'),
                ),
                OutlinedButton(
                  onPressed: () => OverlayScope.of(context).startTutorial(
                    'sample.capabilities',
                    force: true,
                  ),
                  child: const Text('Tutorial'),
                ),
              ],
            ),
          ),
          _CapabilityCard(
            title: 'Connectivity policy',
            description: 'The app default is a banner; a page can override it.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: _toggleOffline,
                  child: Text(
                    widget.connectivity.isSureOffline
                        ? 'Restore connection'
                        : 'Simulate offline',
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    widget.connectivity.setOffline(true);
                    widget.openLocation('/offline-block');
                  },
                  child: const Text('Open blocking page'),
                ),
              ],
            ),
          ),
          _CapabilityCard(
            title: 'Skeleton',
            description:
                'Reusable skeleton views can be composed by a feature.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton(
                  onPressed: () =>
                      setState(() => _showSkeleton = !_showSkeleton),
                  child:
                      Text(_showSkeleton ? 'Hide skeleton' : 'Show skeleton'),
                ),
                if (_showSkeleton) ...[
                  const SizedBox(height: 8),
                  for (var i = 0; i < 3; i++)
                    SkeletonTile(delay: Duration(milliseconds: i * 80)),
                ],
              ],
            ),
          ),
          _CapabilityCard(
            title: 'Validation',
            description: 'Rules stay reusable while messages remain app-owned.',
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validators: [
                      localizedValidator(
                        rules: const [
                          RequiredRule(),
                          EmailRule(allowEmpty: false)
                        ],
                        messageFor: (error) => switch (error.code) {
                          ValidationErrorCode.required => 'Email is required',
                          _ => 'Enter a valid email',
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => _formKey.currentState?.validate(),
                    child: const Text('Validate'),
                  ),
                ],
              ),
            ),
          ),
          _CapabilityCard(
            title: 'Logging and deep link',
            description: 'Record a user action or map a provider payload.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _writeLog,
                  child: Text('Log action (${widget.logReader.recent.length})'),
                ),
                OutlinedButton(
                  onPressed: () {
                    final location = locationFromPayload(
                      const {'path': '/sample'},
                    );
                    if (location != null) widget.openLocation(location);
                  },
                  child: const Text('Open sample deep link'),
                ),
                OutlinedButton(
                  onPressed: () => widget.openLocation('/onboarding'),
                  child: const Text('Onboarding'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(ToastType type) {
    OverlayScope.of(context).showToast(
      type: type,
      message: '${type.name} from the global toast queue',
      dedupeKey: 'showcase-${type.name}',
    );
  }

  Future<void> _showLoading() async {
    final handle = OverlayScope.of(context).showLoading(
      contentBuilder: (context) => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Custom loading content'),
            ],
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 900));
    handle.close();
  }

  void _toggleOffline() {
    widget.connectivity.setOffline(!widget.connectivity.isSureOffline);
    setState(() {});
  }

  void _writeLog() {
    widget.logSink.add(
      const LogEvent(kind: 'user.action', message: 'showcase.log_button'),
    );
    setState(() {});
  }
}

class OfflineBlockSamplePage extends StatelessWidget {
  const OfflineBlockSamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Blocking policy',
      pageConfig: PageConfig(noInternet: NoInternetMode.block),
      body: Center(child: Text('This content is blocked while offline.')),
    );
  }
}

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
