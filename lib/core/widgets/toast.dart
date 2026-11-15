import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

void showToast(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: error ? AppColors.red : AppColors.text,
    behavior: SnackBarBehavior.floating));
}
