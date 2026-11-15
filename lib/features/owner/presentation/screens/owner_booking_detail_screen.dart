import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/owner_providers.dart';

class OwnerBookingDetailScreen extends ConsumerWidget {
  final String id;
  const OwnerBookingDetailScreen({super.key, required this.id});

  Future<void> _openWA(String phone) async {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = '92${digits.substring(1)}';
    final url = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bookingDetailProvider(id));
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, 
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.primary), onPressed: () => context.pop()), 
        title: Text('Booking Details', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, color: AppColors.primary))
      ), 
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()), 
        error: (e, _) => const Center(child: Text('Error loading details')),
        data: (d) {
          final b = d['booking'] as Map<String, dynamic>; 
          final proposal = d['proposal'];
          final req = d['req']; 
          
          // Safely parse the accepted menu and services from the proposal JSON
          final rawMenu = (proposal?['menu'] as List? ?? []);
          final rawSvc = (proposal?['services'] as List? ?? []);
          
          final menu = rawMenu.where((m) => m['is_included'] == true).toList();
          final svc = rawSvc.where((s) => s['is_included'] == true).toList();
          
          return SingleChildScrollView(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            
            // 1. Customer Info
            Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Customer Details', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)), const SizedBox(height: 12),
              Row(children: [const Icon(Icons.person, size: 16, color: AppColors.primary), const SizedBox(width: 8), Text(req?['customer_name'] ?? b['customer_name'] ?? 'N/A', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))]),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.phone, size: 16, color: AppColors.primary), const SizedBox(width: 8), Text(req?['customer_phone'] ?? b['customer_phone'] ?? 'No phone', style: const TextStyle(fontSize: 13))]),
              if (req?['customer_phone'] != null || b['customer_phone'] != null) ...[
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _openWA(req?['customer_phone'] ?? b['customer_phone']), icon: const Icon(Icons.chat, color: Colors.white, size: 18), label: const Text('Contact on WhatsApp', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), minimumSize: const Size.fromHeight(44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
              ]
            ])),
            const SizedBox(height: 14),

            // 2. Event Info
            if (req != null) Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Event Details', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)), const SizedBox(height: 12),
              _infoRow('Event Type', req['event_type'] ?? '-'), 
              _infoRow('Date', fmtDate(req['event_date'])), 
              _infoRow('Time', req['event_time'] ?? '-'),
              _infoRow('Guests', '${req['guests']} guests'), 
              _infoRow('Location', req['location'] ?? '-'),
            ])),
            const SizedBox(height: 14),

            // 3. Pricing
            if (proposal != null) Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Accepted Agreement & Pricing', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)), const SizedBox(height: 12),
              _infoRow('Final Price', money(proposal['total_price'] ?? 0), isBold: true),
              _infoRow('Per Head', money(proposal['price_per_head'] ?? 0)),
            ])),
            const SizedBox(height: 14),

            // 4. Menu
            if (menu.isNotEmpty) Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Accepted Food Menu', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)), const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6, children: menu.map((m) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)), child: Text(m['name'] ?? m['item'] ?? m['item_name'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)))).toList())
            ])),
            const SizedBox(height: 14),

            // 5. Services
            if (svc.isNotEmpty) Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Accepted Services', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)), const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6, children: svc.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)), child: Text(s['name'] ?? s['item'] ?? s['service_name'] ?? s['service_key'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)))).toList())
            ])),
            const SizedBox(height: 30),
          ]));
        },
      ),
    );
  }
  Widget _infoRow(String label, String value, {bool isBold = false}) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))), Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, color: isBold ? AppColors.primary : AppColors.text)))]));
}
