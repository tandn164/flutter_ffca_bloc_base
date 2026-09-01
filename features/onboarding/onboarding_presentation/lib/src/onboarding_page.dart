import 'package:flutter/material.dart';

import 'onboarding_step.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.steps,
    required this.onComplete,
    this.onSkip,
    this.nextLabel = 'Next',
    this.doneLabel = 'Done',
    this.skipLabel = 'Skip',
    super.key,
  });

  final List<OnboardingStep> steps;
  final Future<void> Function() onComplete;
  final VoidCallback? onSkip;
  final String nextLabel;
  final String doneLabel;
  final String skipLabel;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  var _index = 0;
  var _completing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_index < widget.steps.length - 1) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }
    setState(() => _completing = true);
    try {
      await widget.onComplete();
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) return const SizedBox.shrink();
    final last = _index == widget.steps.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: widget.onSkip == null
                  ? const SizedBox(height: 48)
                  : TextButton(
                      onPressed: widget.onSkip,
                      child: Text(widget.skipLabel),
                    ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.steps.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) {
                  final step = widget.steps[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: step.illustration(context)),
                        Text(
                          step.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(step.description, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: _completing ? null : _next,
                child: Text(last ? widget.doneLabel : widget.nextLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
