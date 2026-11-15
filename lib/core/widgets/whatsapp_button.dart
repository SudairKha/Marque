import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'toast.dart';

class WhatsAppButton extends StatelessWidget {
  final String phone;
  final String greeting;
  const WhatsAppButton({super.key, required this.phone, required this.greeting});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, height: 50,
      child: ElevatedButton.icon(
        onPressed: () async {
          var digits = phone.replaceAll(RegExp(r'\D'), '');
          if (digits.startsWith('0')) digits = '92${digits.substring(1)}';
          if (digits.length == 10) digits = '92$digits';
          final uri = Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent(greeting)}');
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            if (context.mounted) showToast(context, 'Could not open WhatsApp', error: true);
          }
        },
        icon: const Icon(Icons.chat, color: Colors.white),
        label: const Text('Contact on WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25D366),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)))));
  }
}
