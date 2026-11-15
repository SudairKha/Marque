import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

Future<bool> showConfirm(BuildContext context, String title, String msg, {bool destructive = false}) async =>
    await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(title), content: Text(msg),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true),
            child: Text('OK', style: TextStyle(color: destructive ? AppColors.red : AppColors.primary))),
      ])) ?? false;
