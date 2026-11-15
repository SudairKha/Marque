import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outline;
  final Color? color;

  const AppButton(this.label, {super.key, this.onPressed, this.icon, this.outline = false, this.color});
  
  factory AppButton.primary(String l, {VoidCallback? onPressed, IconData? icon}) => AppButton(l, onPressed: onPressed, icon: icon);
  factory AppButton.danger(String l, {VoidCallback? onPressed}) => AppButton(l, onPressed: onPressed, color: AppColors.red);

  @override
  Widget build(BuildContext context) {
    final bg = outline ? Colors.white : (color ?? AppColors.primary);
    final fg = outline ? AppColors.primary : Colors.white;
    return SizedBox(width: double.infinity, height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg, foregroundColor: fg, elevation: 0,
          side: outline ? const BorderSide(color: AppColors.primary) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: 8)],
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: fg)),
        ])));
  }
}
