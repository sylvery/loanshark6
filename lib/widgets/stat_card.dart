import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.accent,
    this.icon,
  });

  final String label;
  final String value;
  final Color? accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Icon(icon, color: accent ?? Theme.of(context).colorScheme.primary),
            if (icon != null) const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
