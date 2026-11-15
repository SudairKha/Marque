import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/network/supabase_client.dart';
import '../providers/owner_providers.dart';
import 'owner_shell.dart';

class OwnerBookingsScreen extends ConsumerStatefulWidget {
  const OwnerBookingsScreen({super.key});
  @override ConsumerState<OwnerBookingsScreen> createState() => _State();
}

class _State extends ConsumerState<OwnerBookingsScreen> {
  String _filter = 'upcoming';
  bool busy = false;

  Future<void> _markCompleted(String id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Mark as Completed?'),
      content: const Text('Are you sure you want to mark this booking as completed?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.green), onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Complete')),
      ],
    ));
    if (confirm != true) return;
    
    setState(() => busy = true);
    try {
      await ref.read(supabaseProvider).from('bookings').update({'status': 'completed'}).eq('id', id);
      ref.invalidate(ownerBookingsProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking completed!'), backgroundColor: AppColors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update status.'), backgroundColor: AppColors.red));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(ownerBookingsProvider);
    return Scaffold(backgroundColor: Colors.white, body: SafeArea(bottom: false, child: Column(children: [
      OwnerHdr(title: 'My Bookings', onBack: _empty),
      const SizedBox(height: 10),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Container(decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(4), child: Row(children: ['upcoming', 'completed'].map((f) { final active = _filter == f; return Expanded(child: GestureDetector(onTap: () => setState(() => _filter = f), child: Container(padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: active ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(9)), child: Center(child: Text(f[0].toUpperCase() + f.substring(1), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.text)))))); }).toList()))),
      const SizedBox(height: 14),
      
      Expanded(child: async.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('$e')), data: (list) {
        final filtered = list.where((b) { 
          final status = b['status'] ?? 'pending';
          if (_filter == 'upcoming') return status == 'upcoming' || status == 'accepted' || status == 'pending';
          if (_filter == 'completed') return status == 'completed';
          return true; 
        }).toList();
        
        if (filtered.isEmpty) return const Center(child: Text('No bookings in this category', style: TextStyle(fontSize: 12, color: AppColors.textMuted)));
        
        return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 18), itemCount: filtered.length, itemBuilder: (_, i) {
          final b = filtered[i];
          final isUpcoming = b['status'] != 'completed';
          return Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(b['customer_name'] ?? 'Customer', style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)), 
              const Spacer(), 
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: isUpcoming ? AppColors.blueSoft : AppColors.greenSoft, borderRadius: BorderRadius.circular(8)), child: Text((b['status'] ?? '').toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isUpcoming ? AppColors.blue : AppColors.green)))
            ]), 
            const SizedBox(height: 10),
            Row(children: [const Icon(Icons.calendar_today, size: 12, color: AppColors.primary), const SizedBox(width: 6), Text(fmtDate(b['event_date']), style: const TextStyle(fontSize: 11.5))]),
            Row(children: [const Icon(Icons.people, size: 12, color: AppColors.primary), const SizedBox(width: 6), Text('${b['guests']} guests', style: const TextStyle(fontSize: 11.5))]),
            const SizedBox(height: 10),
            Text(money(b['total_amount']), style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 14),
            
            if (isUpcoming) ...[
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: busy ? null : () => _markCompleted(b['id']),
                icon: const Icon(Icons.check_circle, size: 16, color: Colors.white),
                label: const Text('Mark as Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size.fromHeight(40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              )),
              const SizedBox(height: 8),
            ],
            
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () => context.push('/owner/booking/${b['id']}'),
              icon: const Icon(Icons.receipt_long, size: 16, color: AppColors.primary),
              label: const Text('View Details', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), minimumSize: const Size.fromHeight(40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            )),
          ]));
        });
      })),
    ])));
  }
  void _empty() {}
}
