import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/owner_providers.dart';

class OwnerProposalDetailScreen extends ConsumerWidget {
  final String proposalId;
  const OwnerProposalDetailScreen({super.key, required this.proposalId});

  Future<void> _openWA(String phone) async {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = '92${digits.substring(1)}';
    final url = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ownerProposalsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.primary), onPressed: () => context.pop()),
        title: Text('Your Sent Proposal', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, color: AppColors.primary)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Error loading details')),
        data: (list) {
          // Fixed the search logic to look inside the 'proposal' map
          final item = list.firstWhere(
            (e) => e['proposal'] != null && e['proposal']['id'] == proposalId, 
            orElse: () => {}
          );
          
          if (item.isEmpty) return const Center(child: Text('Proposal not found'));
          
          final p = item['proposal'];
          final req = item['requirement'];
          final status = p['status'] ?? 'pending';
          
          // Extract menu and services properly
          final menuList = (p['menu'] as List? ?? []).where((m) => m['is_included'] == true).toList();
          final svcList = (p['services'] as List? ?? []).where((s) => s['is_included'] == true).toList();

          return SingleChildScrollView(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            
            Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: status == 'pending' ? AppColors.amberSoft : (status == 'accepted' ? AppColors.greenSoft : AppColors.redSoft), borderRadius: BorderRadius.circular(14)), child: Column(children: [
              Icon(status == 'pending' ? Icons.hourglass_empty : (status == 'accepted' ? Icons.check_circle : Icons.cancel), size: 40, color: status == 'pending' ? const Color(0xFF92400E) : (status == 'accepted' ? const Color(0xFF15803D) : const Color(0xFFB91C1C))),
              const SizedBox(height: 8),
              Text('Customer Response: ${status.toUpperCase()}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: status == 'pending' ? const Color(0xFF92400E) : (status == 'accepted' ? const Color(0xFF15803D) : const Color(0xFFB91C1C)))),
              if (status == 'pending') const Text('Waiting for customer to respond...', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ])),
            const SizedBox(height: 18),

            // Customer Info
            Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Customer Details', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)), const SizedBox(height: 12),
              Row(children: [const Icon(Icons.person, size: 16, color: AppColors.primary), const SizedBox(width: 8), Text(req['customer_name'] ?? 'N/A', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))]),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.phone, size: 16, color: AppColors.primary), const SizedBox(width: 8), Text(req['customer_phone'] ?? 'No phone', style: const TextStyle(fontSize: 13))]),
              if (req['customer_phone'] != null) ...[
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _openWA(req['customer_phone']), icon: const Icon(Icons.chat, color: Colors.white, size: 18), label: const Text('Contact on WhatsApp', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), minimumSize: const Size.fromHeight(44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
              ]
            ])),
            const SizedBox(height: 14),

            // Event Info
            Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Event Requirements', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)), const SizedBox(height: 12),
              _infoRow('Event Type', req['event_type'] ?? '-'), 
              _infoRow('Date', fmtDate(req['event_date'])), 
              _infoRow('Guests', '${req['guests']} guests'), 
              _infoRow('Location', req['location'] ?? '-'),
            ])),
            const SizedBox(height: 14),

            // Your Proposal Details (Price)
            Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your Proposal', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)), const SizedBox(height: 12),
              _infoRow('Total Price', money(p['total_price'] ?? 0), isBold: true), 
              _infoRow('Per Head', money(p['price_per_head'] ?? 0)),
              if (p['message'] != null) ...[
                const SizedBox(height: 10), 
                Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)), child: Text('"${p['message']}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)))
              ]
            ])),
            const SizedBox(height: 14),

            // Menu & Services
            if (menuList.isNotEmpty) Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Proposed Food Menu', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)), const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6, children: menuList.map((m) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)), child: Text(m['name'] ?? m['item'] ?? m['item_name'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)))).toList())
            ])),
            const SizedBox(height: 14),
            if (svcList.isNotEmpty) Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Proposed Services', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)), const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6, children: svcList.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)), child: Text(s['name'] ?? s['item'] ?? s['service_name'] ?? s['service_key'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)))).toList())
            ])),
          ]));
        },
      ),
    );
  }
  
  Widget _infoRow(String label, String value, {bool isBold = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8), 
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))), 
      Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, color: isBold ? AppColors.primary : AppColors.text)))
    ])
  );
}
