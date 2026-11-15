import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/supabase_client.dart';
import '../providers/admin_providers.dart';
class AdminEventTypesScreen extends ConsumerStatefulWidget {
  const AdminEventTypesScreen({super.key});
  @override
  ConsumerState<AdminEventTypesScreen> createState() => _State();
}
class _State extends ConsumerState<AdminEventTypesScreen> {
  bool busy = false;
  void _showForm(Map<String, dynamic>? t) {
    final ctrl = TextEditingController(text: t?['name'] ?? '');
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(t == null ? 'Add Event Type' : 'Edit Event Type'), content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'e.g. Wedding')), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () async {
        if (ctrl.text.trim().isEmpty) return;
        setState(() => busy = true);
        final sb = ref.read(supabaseProvider);
        if (t == null) { await sb.from('event_types').insert({'name': ctrl.text.trim(), 'sort_order': 0}); } else { await sb.from('event_types').update({'name': ctrl.text.trim()}).eq('id', t['id']); }
        ref.invalidate(adminEventTypesProvider);
        if (ctx.mounted) Navigator.pop(ctx);
        setState(() => busy = false);
      }, child: const Text('Save')),
    ]));
  }
  void _delete(int id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete Event Type?'), content: const Text('Are you sure?'), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
    ]));
    if (confirm != true) return;
    setState(() => busy = true);
    await ref.read(supabaseProvider).from('event_types').delete().eq('id', id);
    ref.invalidate(adminEventTypesProvider);
    setState(() => busy = false);
  }
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminEventTypesProvider);
    return Stack(children: [
      async.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('$e')), data: (list) => SingleChildScrollView(padding: const EdgeInsets.all(26), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ElevatedButton.icon(onPressed: () => _showForm(null), icon: const Icon(Icons.add, size: 16), label: const Text('Add Event Type'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(180, 44))),
        const SizedBox(height: 16),
        ...list.map((t) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)), child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.event, color: AppColors.primary, size: 18)),
          const SizedBox(width: 12), Expanded(child: Text(t['name'], style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary))),
          IconButton(onPressed: () => _showForm(t), icon: const Icon(Icons.edit, color: AppColors.primary, size: 18)),
          IconButton(onPressed: () => _delete(t['id']), icon: const Icon(Icons.delete, color: AppColors.red, size: 18)),
        ]))),
      ]))),
      if (busy) Positioned.fill(child: Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: AppColors.primary)))),
    ]);
  }
}
