import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/admin_providers.dart';
class AdminBookingsScreen extends ConsumerWidget {
  const AdminBookingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminBookingsProvider);
    return async.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('$e')), data: (list) {
      if (list.isEmpty) return const Center(child: Text('No bookings'));
      final completed = list.where((b) => b['status'] == 'completed').toList(); final total = completed.fold(0.0, (s, b) => s + (b['total_amount'] ?? 0));
      return SingleChildScrollView(padding: const EdgeInsets.all(26), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.check_circle, size: 16, color: AppColors.green), const SizedBox(width: 8), Text('${completed.length} completed · ${money(total)} revenue', style: const TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600))])),
        const SizedBox(height: 16),
        ...list.map((b) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: RichText(text: TextSpan(style: GoogleFonts.playfairDisplay(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w700), children: [TextSpan(text: b['marquees']?['name'] ?? 'Marquee'), const TextSpan(text: '  →  ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)), TextSpan(text: b['customer_name'] ?? 'Customer')]))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: b['status'] == 'completed' ? AppColors.greenSoft : (b['status'] == 'upcoming' ? AppColors.blueSoft : AppColors.redSoft), borderRadius: BorderRadius.circular(9)), child: Text(b['status'], style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: b['status'] == 'completed' ? AppColors.green : (b['status'] == 'upcoming' ? AppColors.blue : AppColors.red)))),
          ]),
          const SizedBox(height: 6), Row(children: [const Icon(Icons.calendar_today, size: 11, color: AppColors.primary), const SizedBox(width: 6), Text(fmtDate(b['event_date']), style: const TextStyle(fontSize: 10.5, color: AppColors.text))]),
          Row(children: [const Icon(Icons.people, size: 11, color: AppColors.primary), const SizedBox(width: 6), Text('${b['guests']} guests', style: const TextStyle(fontSize: 10.5, color: AppColors.text))]),
          if (b['customer_phone'] != null) Row(children: [const Icon(Icons.phone, size: 11, color: AppColors.primary), const SizedBox(width: 6), Text(b['customer_phone'], style: const TextStyle(fontSize: 10.5, color: AppColors.text))]),
          const SizedBox(height: 6), Text(money(b['total_amount']), style: GoogleFonts.playfairDisplay(fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.w700)),
        ]))),
      ]));
    });
  }
}
