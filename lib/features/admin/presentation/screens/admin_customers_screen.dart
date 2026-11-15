import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/admin_providers.dart';
class AdminCustomersScreen extends ConsumerWidget {
  const AdminCustomersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminCustomersProvider);
    return async.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('$e')), data: (d) {
      final customers = d['profiles'] as List; final reqs = d['reqs'] as List;
      final reqCount = <String, int>{};
      for (var r in reqs) { final cid = r['customer_id']?.toString(); if (cid != null) reqCount[cid] = (reqCount[cid] ?? 0) + 1; }
      return SingleChildScrollView(padding: const EdgeInsets.all(26), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: _statBox('Total Customers', '${customers.length}', AppColors.primary)), const SizedBox(width: 10), Expanded(child: _statBox('Total Requirements', '${reqs.length}', const Color(0xFF3B82F6)))]),
        const SizedBox(height: 20),
        ...customers.map((c) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)), child: Row(children: [
          CircleAvatar(radius: 22, backgroundColor: AppColors.lightBg, backgroundImage: c['avatar_url'] != null ? NetworkImage(c['avatar_url']) : null, child: c['avatar_url'] == null ? Text(initials(c['full_name']), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)) : null),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(c['full_name'] ?? 'Unnamed', style: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)), Text(c['email'] ?? '', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)), if (c['phone'] != null) Text(c['phone'], style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted))])),
          Column(children: [const Text('REQUESTS', style: TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w700)), Text('${reqCount[c['id']] ?? 0}', style: GoogleFonts.playfairDisplay(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.w700))]),
        ]))),
      ]));
    });
  }
  Widget _statBox(String label, String val, Color color) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label.toUpperCase(), style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(val, style: GoogleFonts.playfairDisplay(fontSize: 24, color: color, fontWeight: FontWeight.w700))]));
}
