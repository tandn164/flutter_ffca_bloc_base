import 'dart:math' as math;

enum LayoutSize { compact, medium, expanded }

LayoutSize layoutSizeFor(double maxWidth) {
  if (maxWidth < 600) return LayoutSize.compact;
  if (maxWidth < 840) return LayoutSize.medium;
  return LayoutSize.expanded;
}

class AdaptiveValue<T> {
  const AdaptiveValue({
    required this.compact,
    required this.medium,
    required this.expanded,
  });

  final T compact;
  final T medium;
  final T expanded;

  T resolve(LayoutSize size) => switch (size) {
        LayoutSize.compact => compact,
        LayoutSize.medium => medium,
        LayoutSize.expanded => expanded,
      };
}

double clampScale({
  required double value,
  required double scale,
  required double min,
  required double max,
}) =>
    math.max(min, math.min(max, value * scale));

bool useNavigationRail(double shortestSide) => shortestSide >= 600;

const kHairline = 1.0;
