import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../customer/presentation/providers/customer_providers.dart';
import '../providers/owner_providers.dart';
import 'owner_shell.dart';

final ownerProfileProvider = FutureProvider.autoDispose((ref) async {
  final sb = ref.read(supabaseProvider); final user = sb.auth.currentUser;
  if (user == null) return null;
  final profile = await sb.from('profiles').select().eq('id', user.id).single();
  
  final activeMqId = ref.read(activeMarqueeProvider);
  final marquee = await sb.from('marquees').select().eq('owner_id', user.id).eq('id', activeMqId ?? '').maybeSingle();
  
  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> services = [];
  
  if (marquee != null) {
    final mqId = marquee['id'].toString();
    menuItems = List<Map<String, dynamic>>.from(await ref.watch(marqueeMenuItemsProvider(mqId).future));
    services = List<Map<String, dynamic>>.from(await ref.watch(marqueeServicesProvider(mqId).future));
  }

  return { 'profile': profile, 'marquee': marquee, 'menuItems': menuItems, 'services': services };
});

class OwnerProfileScreen extends ConsumerWidget {
  const OwnerProfileScreen({super.key});

  void _showEdit(BuildContext context, WidgetRef ref, Map<String, dynamic> p, Map<String, dynamic>? mq, List<Map<String, dynamic>> existingMenu, List<Map<String, dynamic>> existingSvc) {
    final nameCtrl = TextEditingController(text: mq?['name'] ?? '');
    final ownerCtrl = TextEditingController(text: p['full_name'] ?? '');
    final waCtrl = TextEditingController(text: mq?['whatsapp'] ?? p['phone'] ?? '');
    final locCtrl = TextEditingController(text: mq?['location'] ?? '');
    final priceCtrl = TextEditingController(text: mq?['price']?.toString() ?? '');
    final capCtrl = TextEditingController(text: mq?['capacity']?.toString() ?? '');
    final descCtrl = TextEditingController(text: mq?['description'] ?? '');
    String coverUrl = mq?['cover_image'] ?? '';
    
    final Set<String> selMenu = existingMenu.map((e) => e['catalog_item_id'].toString()).toSet();
    final Set<String> selSvc = existingSvc.map((e) => e['service_key'].toString()).toSet();
    String? activeCatId;
    bool busy = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final catsAsync = ref.watch(allMenuCategoriesProvider);
          final svcsAsync = ref.watch(servicesCatalogProvider);

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.95,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(children: [
              Container(width: 44, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text('Edit Marquee Profile', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (file == null) return;
                          setState(() => busy = true);
                          try {
                            final ext = file.name.split('.').last;
                            final path = 'marquees/${p['id']}-${DateTime.now().millisecondsSinceEpoch}.$ext';
                            final sb = ref.read(supabaseProvider);
                            final bytes = await file.readAsBytes();
                            await sb.storage.from('marquee-images').uploadBinary(path, bytes);
                            setState(() => coverUrl = sb.storage.from('marquee-images').getPublicUrl(path));
                          } catch (e) {
                            if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('$e')));
                          } finally {
                            setState(() => busy = false);
                          }
                        },
                        child: Container(
                          height: 120, width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.soft,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                            image: coverUrl.isNotEmpty ? DecorationImage(image: NetworkImage(coverUrl), fit: BoxFit.cover) : null,
                          ),
                          child: coverUrl.isEmpty
                              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, color: AppColors.textMuted), SizedBox(height: 4), Text('Upload Cover Image', style: TextStyle(fontSize: 12, color: AppColors.textMuted))]))
                              : const SizedBox(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Marquee Name *', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: ownerCtrl, decoration: const InputDecoration(labelText: 'Owner Name *', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: waCtrl, decoration: const InputDecoration(labelText: 'WhatsApp *', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location *', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price *', border: OutlineInputBorder()))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: capCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity *', border: OutlineInputBorder()))),
                    ]),
                    const SizedBox(height: 12),
                    TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
                    const SizedBox(height: 20),
                    Text('Menu Items', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(height: 8),
                    catsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('$e'),
                      data: (cats) {
                        final parents = cats.where((c) => c['parent_id'] == null).toList();
                        if (parents.isEmpty) return const Text('No categories');
                        activeCatId ??= parents.first['id'].toString();
                        final subCats = cats.where((c) => c['parent_id'] == activeCatId).toList();
                        final displayCats = subCats.isNotEmpty ? subCats : parents;
                        final currentSubId = displayCats.any((c) => c['id'] == activeCatId) ? activeCatId : displayCats.first['id'].toString();
                        final catItems = ref.watch(itemsForCategoryProvider(currentSubId!));

                        return Column(children: [
                          SizedBox(
                            height: 40,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: displayCats.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 6),
                              itemBuilder: (_, i) {
                                final sel = currentSubId == displayCats[i]['id'];
                                return GestureDetector(
                                  onTap: () => setState(() => activeCatId = displayCats[i]['id'].toString()),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.white, border: Border.all(color: sel ? AppColors.primary : AppColors.border), borderRadius: BorderRadius.circular(18)),
                                    child: Text(displayCats[i]['name'], style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: sel ? Colors.white : AppColors.text)),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          catItems.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, _) => Text('$e'),
                            data: (items) => GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85),
                              itemCount: items.length,
                              itemBuilder: (_, i) {
                                final sel = selMenu.contains(items[i].id);
                                return GestureDetector(
                                  onTap: () => setState(() { if (sel) { selMenu.remove(items[i].id); } else { selMenu.add(items[i].id); } }),
                                  child: Container(
                                    decoration: BoxDecoration(border: Border.all(color: sel ? AppColors.primary : AppColors.border, width: sel ? 2 : 1), borderRadius: BorderRadius.circular(8), color: sel ? AppColors.soft : Colors.white),
                                    child: Column(children: [
                                      Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(8)), child: Image.network(items[i].imageUrl ?? '', fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => Container(color: AppColors.soft)))),
                                      Padding(padding: const EdgeInsets.all(4), child: Text(items[i].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9))),
                                    ]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ]);
                      },
                    ),
                    const SizedBox(height: 20),
                    Text('Services', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(height: 8),
                    svcsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('$e'),
                      data: (list) => Wrap(spacing: 6, runSpacing: 6, children: list.map((s) {
                        final on = selSvc.contains(s.key);
                        return GestureDetector(
                          onTap: () => setState(() { if (on) { selSvc.remove(s.key); } else { selSvc.add(s.key); } }),
                          child: Chip(label: Text(s.name, style: TextStyle(fontSize: 11, color: on ? Colors.white : AppColors.text)), backgroundColor: on ? AppColors.primary : Colors.white, side: BorderSide(color: on ? AppColors.primary : AppColors.border)),
                        );
                      }).toList()),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: busy ? null : () async {
                      setState(() => busy = true);
                      try {
                        final sb = ref.read(supabaseProvider);
                        String finalMqId = mq?['id']?.toString() ?? '';

                        if (finalMqId.isEmpty) {
                          final res = await sb.from('marquees').insert({'owner_id': p['id'], 'name': nameCtrl.text, 'whatsapp': waCtrl.text, 'location': locCtrl.text, 'price': num.tryParse(priceCtrl.text) ?? 0, 'capacity': int.tryParse(capCtrl.text) ?? 0, 'description': descCtrl.text, 'status': 'pending', 'cover_image': coverUrl.isEmpty ? null : coverUrl}).select().single();
                          finalMqId = res['id'].toString();
                        } else {
                          await sb.from('marquees').update({'name': nameCtrl.text, 'whatsapp': waCtrl.text, 'location': locCtrl.text, 'price': num.tryParse(priceCtrl.text) ?? 0, 'capacity': int.tryParse(capCtrl.text) ?? 0, 'description': descCtrl.text, 'cover_image': coverUrl.isEmpty ? null : coverUrl}).eq('id', finalMqId);
                        }

                        await sb.from('marquee_menu_items').delete().eq('marquee_id', finalMqId);
                        if (selMenu.isNotEmpty) {
                          final menuRows = await sb.from('menu_catalog_items').select().inFilter('id', selMenu.toList());
                          final menuInserts = menuRows.map((item) => {'marquee_id': finalMqId, 'catalog_item_id': item['id'], 'category_id': item['category_id'], 'name': item['name'], 'image_url': item['image_url'], 'is_active': true}).toList();
                          await sb.from('marquee_menu_items').insert(menuInserts);
                        }

                        await sb.from('marquee_services').delete().eq('marquee_id', finalMqId);
                        if (selSvc.isNotEmpty) {
                          final svcRows = await sb.from('service_catalog').select().inFilter('key', selSvc.toList());
                          final svcInserts = svcRows.map((item) => {'marquee_id': finalMqId, 'service_key': item['key'], 'name': item['name'], 'icon': item['icon'], 'is_active': true}).toList();
                          await sb.from('marquee_services').insert(svcInserts);
                        }

                        ref.invalidate(ownerProfileProvider);
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.red));
                      } finally {
                        setState(() => busy = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: busy ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ownerProfileProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (d) {
            if (d == null) return const Center(child: Text('Not logged in'));
            final rawP = d['profile'];
            if (rawP is! Map<String, dynamic>) return const Center(child: Text('Not logged in'));
            final p = rawP;
            final rawMq = d['marquee'];
            final Map<String, dynamic>? mq = rawMq is Map<String, dynamic> ? rawMq : null;
            final List<Map<String, dynamic>> menuItems = (d['menuItems'] as List? ?? []).cast<Map<String, dynamic>>();
            final List<Map<String, dynamic>> services = (d['services'] as List? ?? []).cast<Map<String, dynamic>>();

            return Column(children: [
              OwnerHdr(title: 'Profile', onBack: _empty),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Profile', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    const Text('Account settings', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFEEF6F0), Color(0xFFD5E9DF)]), borderRadius: BorderRadius.circular(16)),
                      child: Column(children: [
                        CircleAvatar(radius: 40, backgroundColor: AppColors.primary, child: Text(initials(p['full_name']), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700))),
                        const SizedBox(height: 12),
                        Text(p['full_name'] ?? 'Owner', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        Text(p['email'] ?? '', style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), child: const Text('Owner', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700))),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                      child: Column(children: [
                        ListTile(leading: const Icon(Icons.edit, color: AppColors.primary), title: const Text('Edit Profile & Marquee'), trailing: const Icon(Icons.chevron_right), onTap: () => _showEdit(context, ref, p, mq, menuItems, services)),
                        const Divider(height: 1),
                        ListTile(leading: const Icon(Icons.person, color: AppColors.primary), title: const Text('Switch to Customer'), trailing: const Icon(Icons.chevron_right), onTap: () async { await ref.read(supabaseProvider).rpc('switch_mode', params: {'p_mode': 'customer'}); if (context.mounted) context.go('/customer/home'); }),
                        const Divider(height: 1),
                        if (p['is_admin'] == true) ...[
                          ListTile(leading: const Icon(Icons.shield, color: AppColors.primary), title: const Text('Switch to Admin Mode'), trailing: const Icon(Icons.chevron_right), onTap: () async { await ref.read(supabaseProvider).rpc('switch_mode', params: {'p_mode': 'admin'}); if (context.mounted) context.go('/admin/dashboard'); }),
                          const Divider(height: 1),
                        ],
                        ListTile(leading: const Icon(Icons.logout, color: AppColors.red), title: const Text('Logout', style: TextStyle(color: AppColors.red)), onTap: () async { await ref.read(supabaseProvider).auth.signOut(); if (context.mounted) context.go('/login'); }),
                      ]),
                    ),
                  ]),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }
  void _empty() {}
}
