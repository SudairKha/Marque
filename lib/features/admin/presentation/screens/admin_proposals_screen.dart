import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/admin_providers.dart';
class AdminProposalsScreen extends ConsumerWidget {
  const AdminProposalsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminProposalsProvider);
    return async.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('$e')), data: (list) {
      if (list.isEmpty) return const Center(child: Text('No proposals'));
      final pending = list.where((p) => p['status'] == 'pending').length; final accepted = list.where((p) => p['status'] == 'accepted').length; final rejected = list.where((p) => p['status'] == 'rejected').length;
      return SingleChildScrollView(padding: const EdgeInsets.all(26), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: _statBox('PENDING', '$pending', const Color(0xFF92400E), AppColors.amberSoft)), const SizedBox(width: 6), Expanded(child: _statBox('ACCEPTED', '$accepted', const Color(0xFF1E40AF), AppColors.blueSoft)), const SizedBox(width: 6), Expanded(child: _statBox('REJECTED', '$rejected', const Color(0xFFB91C1C), AppColors.redSoft))]),
        const SizedBox(height: 20),
        ...list.map((p) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: RichText(text: TextSpan(style: GoogleFonts.playfairDisplay(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w700), children: [TextSpan(text: p['marquees']?['name'] ?? 'Marquee'), const TextSpan(text: '  →  ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)), TextSpan(text: p['profiles']?['full_name'] ?? 'Customer')]))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: p['status'] == 'pending' ? AppColors.amberSoft : (p['status'] == 'accepted' ? AppColors.blueSoft : AppColors.redSoft), borderRadius: BorderRadius.circular(9)), child: Text(p['status'], style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: p['status'] == 'pending' ? const Color(0xFF92400E) : (p['status'] == 'accepted' ? const Color(0xFF1E40AF) : const Color(0xFFB91C1C))))),
          ]),
          const SizedBox(height: 6), Row(children: [const Icon(Icons.calendar_today, size: 11, color: AppColors.primary), const SizedBox(width: 6), Text(fmtDate(p['event_date']), style: const TextStyle(fontSize: 10.5, color: AppColors.text))]),
          Row(children: [const Icon(Icons.people, size: 11, color: AppColors.primary), const SizedBox(width: 6), Text('${p['guests']} guests', style: const TextStyle(fontSize: 10.5, color: AppColors.text))]),
          const SizedBox(height: 6), Text(money(p['total_price']), style: GoogleFonts.playfairDisplay(fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.w700)),
        ]))),
      ]));
    });
  }
  Widget _statBox(String label, String val, Color fg, Color bg) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Column(children: [Text(val, style: GoogleFonts.playfairDisplay(fontSize: 18, color: fg, fontWeight: FontWeight.w700)), Text(label, style: TextStyle(fontSize: 9.5, color: fg, fontWeight: FontWeight.w600))]));
}
