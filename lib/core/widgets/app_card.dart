import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final EdgeInsets? padding;

  const AppCard({super.key, required this.child, this.borderColor, this.padding});

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: borderColor ?? AppColors.border, width: borderColor != null ? 2 : 1),
      borderRadius: BorderRadius.circular(14)),
    child: child);
}
