import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/network/supabase_client.dart';
import '../providers/owner_providers.dart';

class OwnerReqDetailScreen extends ConsumerWidget {
  final String id; const OwnerReqDetailScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reqDetailProvider(id));
    return Scaffold(backgroundColor: Colors.white, appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.primary), onPressed: () => context.pop()), title: Text('Requirement Details', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, color: AppColors.primary))), body: async.when(
      loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('$e')),
      data: (d) {
        final r = d['req'] as Map<String, dynamic>; final menu = d['menu'] as List; final svc = d['svc'] as List; final isPending = r['requirement_status'] == 'pending';
        return SingleChildScrollView(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Row(children: [CircleAvatar(radius: 26, backgroundColor: AppColors.primary, child: Text(r['customer_name']?.substring(0, 1) ?? 'C', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r['customer_name'] ?? '', style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)), const Text('Customer', style: TextStyle(fontSize: 10, color: AppColors.textMuted)), if (r['customer_phone'] != null) Row(children: [const Icon(Icons.phone, size: 11, color: AppColors.primary), const SizedBox(width: 4), Text(r['customer_phone'], style: const TextStyle(fontSize: 10.5))])]))])),
          const SizedBox(height: 14),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 100, height: 100, decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.event, color: AppColors.primary, size: 40)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r['event_type'] ?? '', style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)), const SizedBox(height: 6), _line(Icons.calendar_today, fmtDate(r['event_date'])), _line(Icons.access_time, r['event_time'] ?? '-'), _line(Icons.location_on, r['location'] ?? ''), _line(Icons.people, '${r['guests']} guests'), _line(Icons.wallet, money(r['budget']), isBold: true)]))])),
          const SizedBox(height: 14),
          if (menu.isNotEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.restaurant, size: 14, color: AppColors.primary), const SizedBox(width: 6), Text('Requested Menu', style: GoogleFonts.playfairDisplay(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.primary))]), const SizedBox(height: 10), Wrap(spacing: 6, runSpacing: 6, children: menu.map((m) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)), child: Text(m['item_name'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)))).toList())])),
          if (menu.isNotEmpty) const SizedBox(height: 14),
          if (svc.isNotEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.settings, size: 14, color: AppColors.primary), const SizedBox(width: 6), Text('Requested Services', style: GoogleFonts.playfairDisplay(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.primary))]), const SizedBox(height: 10), Wrap(spacing: 6, runSpacing: 6, children: svc.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)), child: Text(s['service_name'] ?? s['service_key'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)))).toList())])),
          const SizedBox(height: 14),
          if (isPending) Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => context.push('/owner/send-proposal/${r['id']}'), icon: const Icon(Icons.send, size: 14), label: const Text('Send Proposal'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(onPressed: () async {
              final sb = ref.read(supabaseProvider);
              final mqs = await sb.from('marquees').select('id').eq('owner_id', sb.auth.currentUser!.id).eq('status', 'approved').limit(1);
              if (mqs.isEmpty) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No approved marquee'), backgroundColor: AppColors.red)); return; }
              await sb.rpc('send_proposal', params: {'p_requirement_id': id, 'p_marquee_id': mqs[0]['id'], 'p_price_per_head': null, 'p_message': 'We accept as-is!', 'p_event_date': r['event_date'], 'p_event_time': r['event_time'], 'p_location': r['location'], 'p_menu_items': null, 'p_services': null, 'p_as_is': true});
              if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proposal Sent!'), backgroundColor: AppColors.green)); context.pop(); }
            }, icon: const Icon(Icons.check, size: 14, color: Colors.white), label: const Text('Accept As-Is', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))))),
          ]) else Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(10)), child: Text('Requirement is ${r['requirement_status']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600))),
        ]));
      },
    ));
  }
  Widget _line(IconData ic, String text, {bool isBold = false}) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [Icon(ic, size: 11, color: AppColors.textMuted), const SizedBox(width: 6), Expanded(child: Text(text, style: TextStyle(fontSize: 10.5, color: isBold ? AppColors.primary : AppColors.text, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)))]));
}
