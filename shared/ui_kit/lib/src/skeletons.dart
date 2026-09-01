import 'dart:async';

import 'package:flutter/material.dart';

class _Bone extends StatelessWidget {
  const _Bone({this.height = 12, this.width, this.radius = 8});

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _delay;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _delay = Timer(widget.delay, () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final t = _controller.value;
            return LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.38),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [0.25, 0.5, 0.75],
              begin: Alignment(-1.6 + 3.2 * t, -0.3),
              end: Alignment(0.2 + 3.2 * t, 0.3),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = 14,
    this.delay = Duration.zero,
  });

  final double height;
  final double? width;
  final double borderRadius;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      delay: delay,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    super.key,
    this.width,
    this.height = 12,
    this.delay = Duration.zero,
  });

  final double? width;
  final double height;
  final Duration delay;

  @override
  Widget build(BuildContext context) => SkeletonBox(
        width: width,
        height: height,
        borderRadius: height / 2,
        delay: delay,
      );
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    this.size = 44,
    this.delay = Duration.zero,
  });

  final double size;
  final Duration delay;

  @override
  Widget build(BuildContext context) => SkeletonBox(
        width: size,
        height: size,
        borderRadius: size / 2,
        delay: delay,
      );
}

class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key, this.delay = Duration.zero});

  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      delay: delay,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _Bone(height: 44, width: 44, radius: 14),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bone(height: 12, width: 180),
                    SizedBox(height: 10),
                    _Bone(height: 10, width: 110),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.lines = 6});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        for (var i = 0; i < lines; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SkeletonTile(delay: Duration(milliseconds: i * 100)),
          ),
      ],
    );
  }
}
