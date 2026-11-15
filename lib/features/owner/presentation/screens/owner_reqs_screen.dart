import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/owner_providers.dart';
import 'owner_shell.dart';

class OwnerReqsScreen extends ConsumerStatefulWidget {
  const OwnerReqsScreen({super.key});
  @override
  ConsumerState<OwnerReqsScreen> createState() => _State();
}

class _State extends ConsumerState<OwnerReqsScreen> {
  String _filter = 'all'; String _search = '';
  
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(ownerProposalsProvider);
    return Scaffold(backgroundColor: Colors.white, body: SafeArea(bottom: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      OwnerHdr(title: 'Proposals', onBack: _empty),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 40, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)), child: Row(children: [const SizedBox(width: 12), const Icon(Icons.search, size: 16, color: AppColors.textMuted), const SizedBox(width: 8), Expanded(child: TextField(onChanged: (v) => setState(() => _search = v.toLowerCase()), style: const TextStyle(fontSize: 12), decoration: const InputDecoration(hintText: 'Search...', hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 10))))])),
        const SizedBox(height: 12),
        Container(decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(4), child: Row(children: ['all', 'new', 'responded'].map((f) { final active = _filter == f; return Expanded(child: GestureDetector(onTap: () => setState(() => _filter = f), child: Container(padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: active ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(9)), child: Center(child: Text(f[0].toUpperCase() + f.substring(1), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.text)))))); }).toList())),
      ])),
      const SizedBox(height: 14),
      Expanded(child: async.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('$e')), data: (list) {
        final filtered = list.where((item) {
          final req = item['requirement'];
          final prop = item['proposal'];
          final isResponded = prop != null;
          
          if (_filter == 'new' && isResponded) return false;
          if (_filter == 'responded' && !isResponded) return false;
          
          if (_search.isNotEmpty) { 
            final txt = '${req['event_type']} ${req['location']} ${req['customer_name']}'.toLowerCase(); 
            if (!txt.contains(_search)) return false; 
          }
          return true;
        }).toList();
        
        if (filtered.isEmpty) return const Center(child: Text('No proposals found', style: TextStyle(fontSize: 12, color: AppColors.textMuted)));
        
        return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4), itemCount: filtered.length, itemBuilder: (_, i) {
          final item = filtered[i];
          final req = item['requirement']; 
          final prop = item['proposal'];
          final isResponded = prop != null;
          
          return InkWell(
            onTap: () => context.push(isResponded ? '/owner/proposal/${prop['id']}' : '/owner/req/${req['id']}'), 
            child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 30)), 
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(req['event_type'] ?? 'Event', style: GoogleFonts.playfairDisplay(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.primary)), 
                    const Spacer(), 
                    // Clear Status Chip: NEW vs PROPOSAL SENT
                    isResponded 
                      ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.circular(8)), child: const Text('PROPOSAL SENT', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: AppColors.blue)))
                      : Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.amberSoft, borderRadius: BorderRadius.circular(8)), child: const Text('NEW', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF92400E))))
                  ]),
                  Text(req['customer_name'] ?? 'Customer', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)), 
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 6, children: [_meta(Icons.calendar_today, fmtDate(req['event_date'])), _meta(Icons.people, '${req['guests']}'), _meta(Icons.wallet, money(req['budget']))]),
                ])),
              ]),
              const Divider(height: 20, color: AppColors.border),
              Row(children: [
                Text(isResponded ? 'Your Price: ${money(prop['total_price'])}' : 'Budget: ${money(req['budget'])}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)), 
                const Spacer(), 
                TextButton(onPressed: () => context.push(isResponded ? '/owner/proposal/${prop['id']}' : '/owner/req/${req['id']}'), child: Text(isResponded ? 'View Proposal' : 'Send Proposal', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)))
              ]),
            ])),
          );
        });
      })),
    ])));
  }
  void _empty() {}
  Widget _meta(IconData ic, String text) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(ic, size: 10, color: AppColors.primary), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 10, color: AppColors.text))]);
}
