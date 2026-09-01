import 'package:flutter/material.dart';

class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        Icons.check_rounded,
        color: scheme.primary,
        size: size * 0.48,
      ),
    );
  }
}
