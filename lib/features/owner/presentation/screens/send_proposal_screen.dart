import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/error_parser.dart';
import '../providers/owner_providers.dart';

final propSetupProvider = FutureProvider.family.autoDispose((ref, String reqId) async {
  final sb = ref.read(supabaseProvider); final user = sb.auth.currentUser; if (user == null) throw Exception("Not logged in");
  final req = await sb.from('v_owner_requirements').select().eq('id', reqId).single(); final reqMenu = await sb.from('requirement_menu_items').select().eq('requirement_id', reqId); final reqSvc = await sb.from('requirement_services').select().eq('requirement_id', reqId);
  final mq = await sb.from('marquees').select().eq('owner_id', user.id).eq('status', 'approved').limit(1).maybeSingle(); if (mq == null) throw Exception("You need an approved marquee to send a proposal.");
  final mqMenu = await sb.from('marquee_menu_items').select().eq('marquee_id', mq['id']).eq('is_active', true); final mqSvc = await sb.from('marquee_services').select().eq('marquee_id', mq['id']).eq('is_active', true);
  return {'req': req, 'reqMenu': reqMenu, 'reqSvc': reqSvc, 'marquee': mq, 'mqMenu': mqMenu, 'mqSvc': mqSvc};
});

class SendProposalScreen extends ConsumerStatefulWidget {
  final String reqId; const SendProposalScreen({super.key, required this.reqId});
  @override ConsumerState<SendProposalScreen> createState() => _State();
}
class _State extends ConsumerState<SendProposalScreen> {
  int _pph = 0; int _guests = 0; final _msgCtrl = TextEditingController(); bool _busy = false; final Set<String> _menuSel = {}; final Set<String> _svcSel = {}; bool _initialized = false;
  void _init(Map<String, dynamic> d) {
    if (_initialized) return; _guests = d['req']['guests'] ?? 1; _pph = (d['req']['budget'] as num).round() ~/ _guests;
    final reqMenuIds = (d['reqMenu'] as List).map((m) => m['catalog_item_id']).whereType<String>().toSet(); for (var m in d['mqMenu'] as List) { if (reqMenuIds.contains(m['catalog_item_id'])) _menuSel.add(m['id']); }
    final reqSvcKeys = (d['reqSvc'] as List).map((s) => s['service_key']).whereType<String>().toSet(); for (var s in d['mqSvc'] as List) { if (reqSvcKeys.contains(s['service_key'])) _svcSel.add(s['service_key']); }
    _initialized = true;
  }
  Future<void> _send(Map<String, dynamic> d) async {
    setState(() => _busy = true);
    try {
      final sb = ref.read(supabaseProvider);
      final existing = await sb.from('proposals').select('id').eq('requirement_id', widget.reqId).eq('owner_id', sb.auth.currentUser!.id).maybeSingle();
      if (existing != null) throw Exception("You have already sent a proposal for this requirement.");
      await sb.rpc('send_proposal', params: {
        'p_requirement_id': widget.reqId, 'p_marquee_id': d['marquee']['id'], 'p_price_per_head': _pph, 'p_message': _msgCtrl.text.trim().isEmpty ? null : _msgCtrl.text.trim(), 'p_event_date': d['req']['event_date'], 'p_event_time': d['req']['event_time'], 'p_location': d['req']['location'],
        'p_menu_items': (d['mqMenu'] as List).map((m) => {
          'id': m['id'],
          'name': m['name'], // Added name
          'is_included': _menuSel.contains(m['id'])
        }).toList(),
        'p_services': (d['mqSvc'] as List).map((s) => {
          'key': s['service_key'],
          'name': s['name'], // Added name
          'is_included': _svcSel.contains(s['service_key'])
        }).toList(),
        'p_as_is': false
      });
      ref.invalidate(existingProposalProvider(widget.reqId)); if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proposal Sent Successfully!'), backgroundColor: AppColors.green)); context.pop(); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorParser.getMessage(e)), backgroundColor: AppColors.red)); } finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(propSetupProvider(widget.reqId));
    return Scaffold(backgroundColor: const Color(0xFFF1F5F9), appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.primary), onPressed: () => context.pop()), title: Text('Send Proposal', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, color: AppColors.primary))), body: async.when(
      loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text(ErrorParser.getMessage(e))),
      data: (d) {
        _init(d); final req = d['req'] as Map<String, dynamic>;
        return SingleChildScrollView(padding: const EdgeInsets.all(18), child: Column(children: [
          _card('Customer Request', Icons.event_note, Wrap(spacing: 8, runSpacing: 8, children: [_ov('Event', req['event_type']), _ov('Date', fmtDate(req['event_date'])), _ov('Guests', '${req['guests']}'), _ov('Budget', money(req['budget']))])),
          _card('Pricing', Icons.local_offer, Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Price Per Head', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Container(height: 38, decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10), color: Colors.white), child: Row(children: [InkWell(onTap: () => setState(() => _pph = (_pph - 100).clamp(0, 999999)), child: Container(width: 45, alignment: Alignment.center, child: const Text('-100', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)))), Expanded(child: Text('$_pph', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))), InkWell(onTap: () => setState(() => _pph += 100), child: Container(width: 45, alignment: Alignment.center, child: const Text('+100', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))))]))])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total Price', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Container(height: 38, padding: const EdgeInsets.symmetric(horizontal: 12), alignment: Alignment.centerLeft, decoration: BoxDecoration(color: AppColors.soft, border: Border.all(color: AppColors.primary), borderRadius: BorderRadius.circular(10)), child: Text(money(_pph * _guests), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)))])),
          ])),
          _card('Menu', Icons.restaurant, _grid((d['mqMenu'] as List).map((m) => _item(m['id'], m['name'], m['image_url'], _menuSel.contains(m['id']), () => setState(() { if (_menuSel.contains(m['id'])) { _menuSel.remove(m['id']); } else { _menuSel.add(m['id']); } }))).toList())),
          _card('Services', Icons.settings, _grid((d['mqSvc'] as List).map((s) => _item(s['service_key'], s['name'], s['image_url'] ?? '', _svcSel.contains(s['service_key']), () => setState(() { if (_svcSel.contains(s['service_key'])) { _svcSel.remove(s['service_key']); } else { _svcSel.add(s['service_key']); } }))).toList())),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.chat, size: 14, color: AppColors.primary), const SizedBox(width: 6), Text('Message', style: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary))]), const SizedBox(height: 10), TextField(controller: _msgCtrl, maxLines: 3, style: const TextStyle(fontSize: 12.5), decoration: const InputDecoration(hintText: 'Add a personal message...', hintStyle: TextStyle(fontSize: 11.5, color: AppColors.textMuted), border: OutlineInputBorder(), contentPadding: EdgeInsets.all(12)))])),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _busy ? null : () => _send(d), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _busy ? const CircularProgressIndicator(color: Colors.white) : const Text('Send Proposal', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)))),
        ]));
      },
    ));
  }
  Widget _card(String title, IconData icon, Widget child) => Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, size: 14, color: AppColors.primary), const SizedBox(width: 6), Text(title, style: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary))]), const SizedBox(height: 12), child]));
  Widget _ov(String lbl, String val) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(lbl, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)), Text(val, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))]));
  Widget _grid(List<Widget> items) => items.isEmpty ? const Text('No items') : GridView.count(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: items);
  Widget _item(String id, String name, String? img, bool sel, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(decoration: BoxDecoration(border: Border.all(color: sel ? AppColors.primary : AppColors.border, width: sel ? 2 : 1), borderRadius: BorderRadius.circular(10), color: sel ? const Color(0xFFF0FDF4) : Colors.white), clipBehavior: Clip.antiAlias, child: Stack(children: [Column(children: [Expanded(child: Image.network(img ?? '', fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => Container(color: AppColors.soft))), Container(padding: const EdgeInsets.all(4), width: double.infinity, color: Colors.white, child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600)))]), Positioned(top: 4, right: 4, child: Container(width: 16, height: 16, decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.black26, border: Border.all(color: Colors.white, width: 1.5), borderRadius: BorderRadius.circular(4)), child: sel ? const Icon(Icons.check, size: 10, color: Colors.white) : null))])));
}
