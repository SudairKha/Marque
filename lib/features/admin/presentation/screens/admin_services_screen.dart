import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';
class AdminServicesScreen extends ConsumerStatefulWidget {
  const AdminServicesScreen({super.key});
  @override
  ConsumerState<AdminServicesScreen> createState() => _State();
}
class _State extends ConsumerState<AdminServicesScreen> {
  bool busy = false;
  void _showForm(Map<String, dynamic>? s) {
    final nameCtrl = TextEditingController(text: s?['name'] ?? '');
    final imgCtrl = TextEditingController(text: s?['image_url'] ?? '');
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(s == null ? 'Add Service' : 'Edit Service'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Service Name')), const SizedBox(height: 8),
      TextField(controller: imgCtrl, decoration: const InputDecoration(hintText: 'Image URL')), const SizedBox(height: 8),
      ElevatedButton.icon(onPressed: () async {
        final file = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (file == null) return; final bytes = await file.readAsBytes(); final path = 'services/img-${DateTime.now().millisecondsSinceEpoch}.jpg';
        await ref.read(supabaseProvider).storage.from('marquee-images').uploadBinary(path, bytes);
        imgCtrl.text = ref.read(supabaseProvider).storage.from('marquee-images').getPublicUrl(path);
      }, icon: const Icon(Icons.upload_file, size: 16), label: const Text('Upload Image'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.soft, foregroundColor: AppColors.primary)),
    ]), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () async {
        if (nameCtrl.text.trim().isEmpty || imgCtrl.text.trim().isEmpty) return;
        setState(() => busy = true);
        await ref.read(supabaseProvider).rpc('admin_upsert_service', params: {'p_id': s?['id'], 'p_key': null, 'p_name': nameCtrl.text.trim(), 'p_description': null, 'p_icon': 'fa-gear', 'p_image_url': imgCtrl.text.trim(), 'p_sort_order': 0});
        ref.invalidate(adminServicesProvider); if (ctx.mounted) Navigator.pop(ctx); setState(() => busy = false);
      }, child: const Text('Save')),
    ]));
  }
  void _delete(int id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete Service?'), content: const Text('Are you sure?'), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
    ]));
    if (confirm != true) return;
    setState(() => busy = true);
    await ref.read(supabaseProvider).rpc('admin_delete_service', params: {'p_id': id});
    ref.invalidate(adminServicesProvider); setState(() => busy = false);
  }
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminServicesProvider);
    return Stack(children: [
      async.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('$e')), data: (list) => SingleChildScrollView(padding: const EdgeInsets.all(26), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ElevatedButton.icon(onPressed: () => _showForm(null), icon: const Icon(Icons.add, size: 16), label: const Text('Add Service'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(180, 44))),
        const SizedBox(height: 16),
        ...list.map((s) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)), child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(9), child: Image.network(s['image_url'] ?? '', width: 52, height: 52, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 52, height: 52, color: AppColors.soft))),
          const SizedBox(width: 12), Expanded(child: Text(s['name'], style: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary))),
          IconButton(onPressed: () => _showForm(s), icon: const Icon(Icons.edit, color: AppColors.primary, size: 18)),
          IconButton(onPressed: () => _delete(s['id']), icon: const Icon(Icons.delete, color: AppColors.red, size: 18)),
        ]))),
      ]))),
      if (busy) Positioned.fill(child: Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: AppColors.primary)))),
    ]);
  }
}
