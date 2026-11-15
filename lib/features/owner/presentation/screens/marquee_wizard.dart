import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../customer/presentation/providers/customer_providers.dart';
import '../providers/owner_providers.dart';

class _Hdr extends StatelessWidget {
  final int step; const _Hdr(this.step);
  @override
  Widget build(BuildContext context) {
    const l = ['Basic', 'Menu', 'Services', 'Review'];
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20), child: Stack(children: [
      Positioned(top: 14, left: 34, right: 34, child: Container(height: 2, color: const Color(0xFFE2E8F0))),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(4, (i) {
        final n = i + 1; final a = n == step; final d = n < step;
        return SizedBox(width: 60, child: Column(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: (a || d) ? AppColors.primary : Colors.white, border: Border.all(color: (a || d) ? AppColors.primary : const Color(0xFFE2E8F0), width: 2)), child: Center(child: d ? const Icon(Icons.check, size: 13, color: Colors.white) : Text('$n', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: (a || d) ? Colors.white : const Color(0xFF94A3B8))))),
          const SizedBox(height: 4), Text(l[i], style: TextStyle(fontSize: 10, color: (a || d) ? AppColors.primary : const Color(0xFF94A3B8), fontWeight: (a || d) ? FontWeight.w700 : FontWeight.w500)),
        ]));
      })),
    ]));
  }
}

class MarqueeWizardScreen extends ConsumerStatefulWidget {
  final int step; const MarqueeWizardScreen({super.key, required this.step});
  @override ConsumerState<MarqueeWizardScreen> createState() => _State();
}
class _State extends ConsumerState<MarqueeWizardScreen> {
  final name = TextEditingController(); final wa = TextEditingController(); final loc = TextEditingController(); final price = TextEditingController(); final cap = TextEditingController(); final desc = TextEditingController();
  final Set<String> selMenu = {}; final Set<String> selSvc = {}; bool busy = false; String? activeParentId; String? activeSubCatId;

  Future<void> _submit() async {
    setState(() => busy = true);
    try {
      final sb = ref.read(supabaseProvider); final user = sb.auth.currentUser; if (user == null) throw Exception("Not logged in");
      final svcs = ref.read(servicesCatalogProvider).value ?? []; final svcPayload = svcs.map((s) => {'key': s.key, 'active': selSvc.contains(s.key)}).toList();
      await sb.rpc('save_marquee', params: { 'p_name': name.text.trim(), 'p_whatsapp': wa.text.trim(), 'p_location': loc.text.trim(), 'p_price': num.tryParse(price.text) ?? 0, 'p_capacity': int.tryParse(cap.text) ?? 0, 'p_description': desc.text.trim(), 'p_menu': selMenu.map((id) => {'catalog_item_id': id}).toList(), 'p_services': svcPayload, 'p_submit': true, 'p_cover_image': null, 'p_gallery': null, 'p_marquee_id': null });
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marquee submitted!'), backgroundColor: AppColors.green)); context.go('/owner/dashboard'); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.red)); } finally { if (mounted) setState(() => busy = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.primary), onPressed: () => context.go('/owner/dashboard')), title: Text('Register a Marquee', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, color: AppColors.primary))), body: SafeArea(bottom: false, child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(18, 0, 18, 100), child: Column(children: [
      _Hdr(widget.step), if (widget.step == 1) _step1(), if (widget.step == 2) _step2(), if (widget.step == 3) _step3(), if (widget.step == 4) _step4(), const SizedBox(height: 20),
      Row(children: [
        if (widget.step > 1) Expanded(child: OutlinedButton(onPressed: () => context.go('/owner/marquee/${widget.step - 1}'), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Previous', style: TextStyle(color: AppColors.primary)))),
        if (widget.step > 1) const SizedBox(width: 10),
        Expanded(child: ElevatedButton(onPressed: busy ? null : () { if (widget.step < 4) { context.go('/owner/marquee/${widget.step + 1}'); } else { _submit(); } }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: busy ? const CircularProgressIndicator(color: Colors.white) : Text(widget.step == 4 ? 'Submit for Approval' : 'Next', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
      ]),
    ]))));
  }

  Widget _step1() => Column(children: [
    Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(children: [
      Row(children: [const Icon(Icons.store, color: AppColors.primary), const SizedBox(width: 8), Text('Basic Information', style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary))]), const SizedBox(height: 14),
      _field('Marquee Name *', name, 'e.g. Royal Marquee'), const SizedBox(height: 12), _field('WhatsApp *', wa, '+92 300 1234567'), const SizedBox(height: 12), _field('Location *', loc, 'DHA, Lahore'), const SizedBox(height: 12),
      Row(children: [Expanded(child: _field('Price *', price, '500000', isNum: true)), const SizedBox(width: 10), Expanded(child: _field('Capacity *', cap, '300', isNum: true))]), const SizedBox(height: 12),
      TextField(controller: desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Description *', border: OutlineInputBorder(), hintText: 'Describe your marquee...')),
    ])),
  ]);

  Widget _step2() {
    final allCatsAsync = ref.watch(allMenuCategoriesProvider);
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.restaurant, color: AppColors.primary), const SizedBox(width: 8), Text('Menu Selection', style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary))]), const SizedBox(height: 14),
      allCatsAsync.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Text('$e'), data: (allCats) {
        final parents = allCats.where((c) => c['parent_id'] == null).toList(); if (parents.isEmpty) return const Text('No categories'); activeParentId ??= parents.first['id'].toString();
        final subCats = allCats.where((c) => c['parent_id'] == activeParentId).toList(); final displayCats = subCats.isNotEmpty ? subCats : parents;
        if (activeSubCatId == null || !displayCats.any((c) => c['id'] == activeSubCatId)) { activeSubCatId = displayCats.first['id']; }
        final itemsAsync = ref.watch(itemsForCategoryProvider(activeSubCatId!));
        
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 40, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: parents.length, separatorBuilder: (_, __) => const SizedBox(width: 6), itemBuilder: (_, i) {
            final sel = activeParentId == parents[i]['id'];
            return GestureDetector(onTap: () => setState(() => activeParentId = parents[i]['id'].toString()), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.white, border: Border.all(color: sel ? AppColors.primary : AppColors.border), borderRadius: BorderRadius.circular(20)), child: Center(child: Text(parents[i]['name'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.text)))));
          })),
          if (subCats.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(height: 36, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: subCats.length, separatorBuilder: (_, __) => const SizedBox(width: 6), itemBuilder: (_, i) {
              final sel = activeSubCatId == subCats[i]['id'];
              return GestureDetector(onTap: () => setState(() => activeSubCatId = subCats[i]['id'].toString()), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: sel ? AppColors.soft : Colors.white, border: Border.all(color: sel ? AppColors.primary : AppColors.border), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(subCats[i]['name'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? AppColors.primary : AppColors.textMuted)))));
            })),
          ],
          const SizedBox(height: 16),
          itemsAsync.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Text('$e'), data: (its) {
            if (its.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('No items in this category'));
            return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.8), itemCount: its.length, itemBuilder: (_, i) {
              final sel = selMenu.contains(its[i].id);
              return GestureDetector(onTap: () => setState(() { if (sel) { selMenu.remove(its[i].id); } else { selMenu.add(its[i].id); } }), child: Container(decoration: BoxDecoration(border: Border.all(color: sel ? AppColors.primary : AppColors.border, width: sel ? 2 : 1), borderRadius: BorderRadius.circular(8), color: sel ? AppColors.soft : Colors.white), child: Column(children: [Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(8)), child: Image.network(its[i].imageUrl ?? '', fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => Container(color: AppColors.soft)))), Padding(padding: const EdgeInsets.all(4), child: Text(its[i].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)))])));
            });
          }),
        ]);
      }),
    ]));
  }

  Widget _step3() {
    final svcs = ref.watch(servicesCatalogProvider);
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.settings, color: AppColors.primary), const SizedBox(width: 8), Text('Services', style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary))]), const SizedBox(height: 14),
      svcs.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Text('$e'), data: (l) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.9), itemCount: l.length, itemBuilder: (_, i) {
        final s = l[i]; final sel = selSvc.contains(s.key);
        return GestureDetector(onTap: () => setState(() { if (sel) { selSvc.remove(s.key); } else { selSvc.add(s.key); } }), child: Container(decoration: BoxDecoration(border: Border.all(color: sel ? AppColors.primary : AppColors.border, width: sel ? 2 : 1), borderRadius: BorderRadius.circular(10), color: sel ? AppColors.soft : Colors.white), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(sel ? Icons.check_circle : Icons.radio_button_unchecked, color: sel ? AppColors.primary : AppColors.textMuted, size: 24), const SizedBox(height: 8), Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(s.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? AppColors.primary : AppColors.text)))])));
      })),
    ]));
  }

  Widget _step4() {
    final menuItems = ref.watch(parentCategoriesProvider).value ?? []; final allItems = <Map<String, dynamic>>[]; for (final cat in menuItems) { final items = ref.watch(itemsForCategoryProvider(cat.id)).value ?? []; allItems.addAll(items.map((i) => {'id': i.id, 'name': i.name})); }
    final selectedMenuNames = selMenu.map((id) { final m = allItems.firstWhere((i) => i['id'] == id, orElse: () => {'name': 'Unknown'}); return m['name']; }).toList();
    final svcs = ref.watch(servicesCatalogProvider).value ?? []; final selectedSvcNames = selSvc.map((key) { final s = svcs.firstWhere((s) => s.key == key, orElse: () => throw Exception()); return s.name; }).toList();
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.store, color: AppColors.primary), const SizedBox(width: 8), Text(name.text, style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary))]), const SizedBox(height: 6), Text(loc.text, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)), const SizedBox(height: 10), Text(desc.text, style: const TextStyle(fontSize: 12)), const SizedBox(height: 10), Text('PKR ${price.text} · ${cap.text} guests', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)), const SizedBox(height: 16), const Divider(), const SizedBox(height: 8),
      Row(children: [const Icon(Icons.restaurant, color: AppColors.primary, size: 16), const SizedBox(width: 8), Text('Menu (${selectedMenuNames.length})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))]), const SizedBox(height: 8), Wrap(spacing: 6, runSpacing: 6, children: selectedMenuNames.map((n) => Chip(label: Text(n, style: const TextStyle(fontSize: 11)))).toList()), const SizedBox(height: 16), const Divider(), const SizedBox(height: 8),
      Row(children: [const Icon(Icons.settings, color: AppColors.primary, size: 16), const SizedBox(width: 8), Text('Services (${selectedSvcNames.length})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))]), const SizedBox(height: 8), Wrap(spacing: 6, runSpacing: 6, children: selectedSvcNames.map((n) => Chip(label: Text(n, style: const TextStyle(fontSize: 11)))).toList()),
    ]));
  }
  Widget _field(String lbl, TextEditingController c, String hint, {bool isNum = false}) => TextField(controller: c, keyboardType: isNum ? TextInputType.number : TextInputType.text, decoration: InputDecoration(labelText: lbl, hintText: hint, border: const OutlineInputBorder()));
}
