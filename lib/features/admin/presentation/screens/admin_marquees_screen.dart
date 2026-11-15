import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/admin_providers.dart';

class AdminMarqueesScreen extends ConsumerStatefulWidget {
  const AdminMarqueesScreen({super.key});
  @override
  ConsumerState<AdminMarqueesScreen> createState() => _State();
}

class _State extends ConsumerState<AdminMarqueesScreen> {
  String filter = 'pending';
  bool busy = false;

  Future<void> _setStatus(String id, String status) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text('Confirm ${status.toUpperCase()}'),
      content: Text('Are you sure you want to set this marquee to $status?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Confirm')),
      ],
    ));
    if (confirm != true) return;

    setState(() => busy = true);
    try {
      await ref.read(supabaseProvider).rpc('admin_set_marquee_status', params: {'p_marquee_id': id, 'p_status': status, 'p_note': null});
      ref.invalidate(adminMarqueesProvider);
      ref.invalidate(adminStatsProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marquee $status'), backgroundColor: AppColors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminMarqueesProvider);
    return Stack(children: [
      async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
        data: (allMqs) {
          final pending = allMqs.where((m) => m['status'] == 'pending').length;
          final approved = allMqs.where((m) => m['status'] == 'approved').length;
          final rejected = allMqs.where((m) => m['status'] == 'rejected').length;
          final suspended = allMqs.where((m) => m['status'] == 'suspended').length;
          final list = filter == 'all' ? allMqs : allMqs.where((m) => m['status'] == filter).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Tabs (Responsive Scroll)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _tab('Pending', pending, 'pending'),
                  const SizedBox(width: 6),
                  _tab('Approved', approved, 'approved'),
                  const SizedBox(width: 6),
                  _tab('Rejected', rejected, 'rejected'),
                  const SizedBox(width: 6),
                  _tab('Suspended', suspended, 'suspended'),
                  const SizedBox(width: 6),
                  _tab('All', allMqs.length, 'all'),
                ]),
              ),
              const SizedBox(height: 16),
              
              // List
              if (list.isEmpty) 
                Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('No ${filter == 'all' ? '' : filter} marquees found.', style: const TextStyle(color: AppColors.textMuted))))
              else 
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final m = list[index];
                    
                    final ownerId = m['owner_id']?.toString() ?? 'unknown';
                    final shortId = ownerId.length > 8 ? ownerId.substring(0, 8) : ownerId;
                    final imageUrl = (m['cover_image']?.toString().isNotEmpty == true) ? m['cover_image'].toString() : 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=200';
                    final status = m['status']?.toString() ?? 'pending';
                    final capacity = int.tryParse(m['capacity']?.toString() ?? '0') ?? 0;
                    final price = num.tryParse(m['price']?.toString() ?? '0') ?? 0;
                    
                    // ✅ THE FIX: ClipRRect fixes the "non-uniform colors with borderRadius" crash
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: const BorderSide(color: AppColors.border),
                            right: const BorderSide(color: AppColors.border),
                            bottom: const BorderSide(color: AppColors.border),
                            left: BorderSide(
                              color: status == 'pending' ? AppColors.amber : (status == 'approved' ? AppColors.green : (status == 'rejected' ? AppColors.red : AppColors.textMuted)),
                              width: 4,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Image.network(
                                    imageUrl,
                                    width: 60, height: 60, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: AppColors.soft, child: const Icon(Icons.store, color: AppColors.textMuted)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m['name']?.toString() ?? 'Unnamed Marquee', style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                      const SizedBox(height: 2),
                                      Text('ID: $shortId...', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                      const SizedBox(height: 4),
                                      Row(children: [const Icon(Icons.location_on, size: 10, color: AppColors.primary), Expanded(child: Text(' ${m['location'] ?? '-'}', style: const TextStyle(fontSize: 10.5, color: AppColors.text), maxLines: 1, overflow: TextOverflow.ellipsis))]),
                                      Row(children: [const Icon(Icons.phone, size: 10, color: AppColors.primary), Expanded(child: Text(' ${m['whatsapp'] ?? '-'}', style: const TextStyle(fontSize: 10.5, color: AppColors.text), maxLines: 1, overflow: TextOverflow.ellipsis))]),
                                      Row(children: [
                                        const Icon(Icons.people, size: 10, color: AppColors.primary), 
                                        Expanded(child: Text(' $capacity guests · ${money(price)}', style: const TextStyle(fontSize: 10.5, color: AppColors.text), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      ]),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == 'pending' ? AppColors.amberSoft : (status == 'approved' ? AppColors.greenSoft : (status == 'rejected' ? AppColors.redSoft : AppColors.border)),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 9.5, fontWeight: FontWeight.w700,
                                      color: status == 'pending' ? const Color(0xFF92400E) : (status == 'approved' ? const Color(0xFF15803D) : (status == 'rejected' ? const Color(0xFFB91C1C) : AppColors.textMuted)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (m['description'] != null && m['description'].toString().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                                child: Text(m['description'].toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: AppColors.text)),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                if (status == 'pending') ...[
                                  Expanded(child: ElevatedButton.icon(onPressed: busy ? null : () => _setStatus(m['id'], 'approved'), icon: const Icon(Icons.check, size: 14, color: Colors.white), label: const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size.fromHeight(38), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
                                  const SizedBox(width: 8),
                                  Expanded(child: ElevatedButton.icon(onPressed: busy ? null : () => _setStatus(m['id'], 'rejected'), icon: const Icon(Icons.close, size: 14, color: AppColors.red), label: const Text('Reject'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.redSoft, foregroundColor: AppColors.red, minimumSize: const Size.fromHeight(38), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
                                ],
                                if (status == 'approved')
                                  Expanded(child: ElevatedButton.icon(onPressed: busy ? null : () => _setStatus(m['id'], 'suspended'), icon: const Icon(Icons.pause, size: 14, color: AppColors.red), label: const Text('Suspend'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.redSoft, foregroundColor: AppColors.red, minimumSize: const Size.fromHeight(38), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
                                if (status == 'rejected' || status == 'suspended')
                                  Expanded(child: ElevatedButton.icon(onPressed: busy ? null : () => _setStatus(m['id'], 'approved'), icon: const Icon(Icons.check, size: 14, color: Colors.white), label: const Text('Approve'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size.fromHeight(38), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ]),
          );
        },
      ),
      if (busy) Positioned.fill(child: Container(color: Colors.black.withOpacity(0.3), child: const Center(child: CircularProgressIndicator(color: AppColors.primary)))),
    ]);
  }

  Widget _tab(String label, int count, String key) {
    final active = filter == key;
    return InkWell(
      onTap: () => setState(() => filter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: active ? AppColors.primary : Colors.white, border: Border.all(color: active ? AppColors.primary : AppColors.border), borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.text)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), 
            decoration: BoxDecoration(color: active ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(8)), 
            child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.text))
          ),
        ]),
      ),
    );
  }
}
