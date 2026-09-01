import 'package:flutter/material.dart';

import 'tutorial_controller.dart';

typedef TutorialContentBuilder = Widget Function(
  BuildContext context,
  String tourId,
  VoidCallback complete,
);

class TutorialLayer extends StatefulWidget {
  const TutorialLayer({
    required this.controller,
    required this.contentBuilder,
    super.key,
  });

  final TutorialController controller;
  final TutorialContentBuilder contentBuilder;

  @override
  State<TutorialLayer> createState() => _TutorialLayerState();
}

class _TutorialLayerState extends State<TutorialLayer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final tourId = widget.controller.activeTourId;
    if (tourId == null) return const SizedBox.shrink();

    final global = widget.controller.spotlightRect();
    Rect? hole;
    if (global != null) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        hole = (box.globalToLocal(global.topLeft) & global.size).inflate(8);
      }
    }

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AbsorbPointer(
              child: CustomPaint(painter: _SpotlightPainter(hole: hole)),
            ),
          ),
          SafeArea(
            child: widget.contentBuilder(
              context,
              tourId,
              () => widget.controller.complete(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({this.hole});

  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    var overlay = Path()..addRect(Offset.zero & size);
    if (hole != null) {
      overlay = Path.combine(
        PathOperation.difference,
        overlay,
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(hole!, const Radius.circular(16)),
          ),
      );
    }
    canvas.drawPath(overlay, Paint()..color = const Color(0x99000000));
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.hole != hole;
}
