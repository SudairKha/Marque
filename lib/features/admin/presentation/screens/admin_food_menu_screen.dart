import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class AdminFoodMenuScreen extends ConsumerStatefulWidget {
  const AdminFoodMenuScreen({super.key});
  @override
  ConsumerState<AdminFoodMenuScreen> createState() => _State();
}

class _State extends ConsumerState<AdminFoodMenuScreen> {
  bool busy = false;

  Future<void> _saveParent(String? id, String name) async {
    if (name.isEmpty) return;
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(id == null ? 'Add Category?' : 'Edit Category?'),
      content: Text('Are you sure you want to save "$name"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Save')),
      ],
    ));
    if (confirm != true) return;

    setState(() => busy = true);
    try {
      await ref.read(supabaseProvider).rpc('admin_upsert_menu_category', params: {'p_id': id, 'p_name': name, 'p_icon': 'fa-utensils', 'p_parent_id': null, 'p_sort_order': 0});
      ref.invalidate(adminFoodMenuProvider); 
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category saved'), backgroundColor: AppColors.green));
    } catch (e) {
      debugPrint('DB Error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operation failed. Please try again.'), backgroundColor: AppColors.red));
    } finally { 
      if (mounted) setState(() => busy = false); 
    }
  }

  Future<void> _saveChild(String? id, String catId, String name, String img) async {
    if (name.isEmpty || img.isEmpty) { 
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and Image required'), backgroundColor: AppColors.red)); 
      return; 
    }
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(id == null ? 'Add Item?' : 'Edit Item?'),
      content: Text('Are you sure you want to save "$name"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Save')),
      ],
    ));
    if (confirm != true) return;

    setState(() => busy = true);
    try {
      await ref.read(supabaseProvider).rpc('admin_upsert_menu_item', params: {'p_id': id, 'p_category_id': catId, 'p_name': name, 'p_image_url': img, 'p_sort_order': 0});
      ref.invalidate(adminFoodMenuProvider); 
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item saved'), backgroundColor: AppColors.green));
    } catch (e) {
      debugPrint('DB Error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operation failed. Please try again.'), backgroundColor: AppColors.red));
    } finally { 
      if (mounted) setState(() => busy = false); 
    }
  }

  Future<void> _deleteParent(String id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Category?'),
      content: const Text('Are you sure you want to delete this category and all its items?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Delete')),
      ],
    ));
    if (confirm != true) return;

    setState(() => busy = true);
    try {
      final sb = ref.read(supabaseProvider);
      
      // 1. Delete by category_id (Fixes the exact error shown: marquee_menu_items_category_id_fkey)
      await sb.from('marquee_menu_items').delete().eq('category_id', id);
      
      // 2. Get item IDs to clean up other references
      final items = await sb.from('menu_catalog_items').select('id').eq('category_id', id);
      final itemIds = items.map((i) => i['id']).toList();
      
      if (itemIds.isNotEmpty) {
        await sb.from('marquee_menu_items').delete().inFilter('catalog_item_id', itemIds);
        await sb.from('requirement_menu_items').delete().inFilter('catalog_item_id', itemIds);
      }
      
      // 3. Delete the items
      await sb.from('menu_catalog_items').delete().eq('category_id', id);
      
      // 4. Delete the category
      await sb.rpc('admin_delete_menu_category', params: {'p_id': id});
      
      ref.invalidate(adminFoodMenuProvider); 
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category deleted'), backgroundColor: AppColors.green));
    } catch (e) {
      debugPrint('DB Error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not delete category. It might be in use.'), backgroundColor: AppColors.red));
    } finally { 
      if (mounted) setState(() => busy = false); 
    }
  }

  Future<void> _deleteItem(String id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Item?'),
      content: const Text('Are you sure you want to delete this item?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Delete')),
      ],
    ));
    if (confirm != true) return;

    setState(() => busy = true);
    try {
      final sb = ref.read(supabaseProvider);
      // Delete references first, then the item
      await sb.from('marquee_menu_items').delete().eq('catalog_item_id', id);
      await sb.rpc('admin_delete_menu_item', params: {'p_id': id});
      
      ref.invalidate(adminFoodMenuProvider); 
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted'), backgroundColor: AppColors.green));
    } catch (e) {
      debugPrint('DB Error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operation failed. Please try again.'), backgroundColor: AppColors.red));
    } finally { 
      if (mounted) setState(() => busy = false); 
    }
  }

  void _showParentModal(Map<String, dynamic>? cat) {
    final ctrl = TextEditingController(text: cat?['name'] ?? '');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(cat == null ? 'Add Category' : 'Edit Category'), 
      content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Name')), 
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () { 
          final text = ctrl.text.trim();
          Navigator.pop(ctx); 
          _saveParent(cat?['id']?.toString(), text); 
        }, child: const Text('Save')),
      ]
    ));
  }

  void _showChildModal(String catId, Map<String, dynamic>? item) {
    final nameCtrl = TextEditingController(text: item?['name'] ?? '');
    final imgCtrl = TextEditingController(text: item?['image_url'] ?? '');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(item == null ? 'Add Item' : 'Edit Item'), 
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Item Name')), 
        const SizedBox(height: 8),
        TextField(controller: imgCtrl, decoration: const InputDecoration(hintText: 'Image URL')), 
        const SizedBox(height: 8),
        ElevatedButton.icon(onPressed: () async {
          final file = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (file == null) return; 
          final bytes = await file.readAsBytes(); 
          final path = 'menu/img-${DateTime.now().millisecondsSinceEpoch}.jpg';
          await ref.read(supabaseProvider).storage.from('marquee-images').uploadBinary(path, bytes);
          imgCtrl.text = ref.read(supabaseProvider).storage.from('marquee-images').getPublicUrl(path);
        }, icon: const Icon(Icons.upload_file, size: 16), label: const Text('Upload Image'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.soft, foregroundColor: AppColors.primary)),
      ]), 
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () { 
          final name = nameCtrl.text.trim();
          final img = imgCtrl.text.trim();
          Navigator.pop(ctx); 
          _saveChild(item?['id']?.toString(), catId, name, img); 
        }, child: const Text('Save Item')),
      ]
    ));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminFoodMenuProvider);
    return Stack(children: [
      async.when(
        loading: () => const Center(child: CircularProgressIndicator()), 
        error: (e, _) => Center(child: Text('Error: $e')), 
        data: (d) {
          final parents = (d['cats'] as List).where((c) => c['parent_id'] == null).toList(); 
          final items = d['items'] as List;
          return SingleChildScrollView(padding: const EdgeInsets.all(26), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ElevatedButton.icon(onPressed: () => _showParentModal(null), icon: const Icon(Icons.add, size: 16), label: const Text('Add Parent Category'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(200, 44))),
            const SizedBox(height: 16),
            ...parents.map((c) {
              final cItems = items.where((i) => i['category_id'] == c['id']).toList();
              return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)), child: Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent), child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12), childrenPadding: const EdgeInsets.all(12),
                title: Row(children: [
                  const Icon(Icons.chevron_right, size: 18, color: AppColors.primary), const SizedBox(width: 8),
                  Text(c['name']?.toString() ?? '', style: GoogleFonts.playfairDisplay(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary), onPressed: () => _showChildModal(c['id'].toString(), null)),
                  IconButton(icon: const Icon(Icons.edit, size: 16, color: AppColors.primary), onPressed: () => _showParentModal(c)),
                  IconButton(icon: const Icon(Icons.delete, size: 16, color: AppColors.red), onPressed: () => _deleteParent(c['id'].toString())),
                ]),
                children: [
                  if (cItems.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No items', style: TextStyle(fontSize: 11, color: AppColors.textMuted))))
                  else Wrap(spacing: 8, runSpacing: 8, children: cItems.map((i) => Stack(children: [
                    Container(width: 100, height: 120, decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(9)), child: Column(children: [
                      Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(9)), child: Image.network(i['image_url'] ?? '', fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => Container(color: AppColors.soft)))),
                      Container(padding: const EdgeInsets.all(4), color: AppColors.soft, child: Text(i['name']?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700))),
                    ])),
                    Positioned(top: 4, right: 4, child: Row(children: [
                      GestureDetector(onTap: () => _showChildModal(c['id'].toString(), i), child: const Icon(Icons.edit, size: 14, color: Colors.white)),
                      const SizedBox(width: 4),
                      GestureDetector(onTap: () => _deleteItem(i['id'].toString()), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                    ])),
                  ])).toList()),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _showChildModal(c['id'].toString(), null), icon: const Icon(Icons.add, size: 14), label: Text('Add Item to ${c['name'] ?? ''}'), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border)))),
                ],
              )));
            }),
          ]));
        }
      ),
      if (busy) Positioned.fill(child: Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: AppColors.primary)))),
    ]);
  }
}
