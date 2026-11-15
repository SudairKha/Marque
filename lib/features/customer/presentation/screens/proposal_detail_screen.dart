import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/customer_providers.dart';

class ProposalDetailScreen extends ConsumerWidget {
  final String id;
  const ProposalDetailScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(proposalComparisonProvider(id));
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (c) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                InkWell(onTap: () => context.go('/customer/proposals'), child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.arrow_back, size: 16, color: AppColors.primary))),
                Expanded(child: Center(child: RichText(text: TextSpan(style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary), children: const [TextSpan(text: 'Marquee'), TextSpan(text: 'Finder', style: TextStyle(color: AppColors.gold))])))),
                const SizedBox(width: 30),
              ]),
              const SizedBox(height: 14),
              Text('Proposal Details', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 4), const Text('Review and compare before you decide', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
              const SizedBox(height: 14),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(c.marqueeCover, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: AppColors.soft))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.marqueeName, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  Row(children: [const Icon(Icons.location_on, size: 11, color: AppColors.primary), const SizedBox(width: 4), Text(c.marqueeLocation, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))]),
                  const SizedBox(height: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: c.proposal.status == 'pending' ? AppColors.amberSoft : (c.proposal.status == 'accepted' ? AppColors.greenSoft : AppColors.redSoft), borderRadius: BorderRadius.circular(9)), child: Text(c.proposal.status, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: c.proposal.status == 'pending' ? const Color(0xFF92400E) : (c.proposal.status == 'accepted' ? const Color(0xFF15803D) : const Color(0xFFB91C1C))))),
                ])),
              ])),
              const SizedBox(height: 14),
              Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.primary, width: 2), borderRadius: BorderRadius.circular(14)), child: Column(children: [
                Container(padding: const EdgeInsets.all(13), decoration: const BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.vertical(top: Radius.circular(14))), child: Row(children: [const Icon(Icons.receipt_long, size: 16, color: AppColors.primary), const SizedBox(width: 8), Text("Marquee's Proposal", style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary))])),
                Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Expanded(child: _stat('Per Person', money(c.proposal.guests > 0 ? c.proposal.totalPrice / c.proposal.guests : 0))), Expanded(child: _stat('Guests', '${c.proposal.guests}'))]),
                  const SizedBox(height: 10),
                  Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.soft, border: Border.all(color: AppColors.primary), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total Price', style: TextStyle(fontSize: 10, color: AppColors.textMuted)), Text(money(c.proposal.totalPrice), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary))])),
                  const SizedBox(height: 12), _chips('Proposed Menu', c.menu.where((m) => m.proposed).map((m) => m.item)),
                  const SizedBox(height: 10), _chips('Proposed Services', c.services.where((s) => s.proposed).map((s) => s.item)),
                  const SizedBox(height: 14),
                  if (c.proposal.status == 'pending') Row(children: [
                    Expanded(child: OutlinedButton(onPressed: () async { await _respond(context, ref, c.proposal.id, false); }, style: OutlinedButton.styleFrom(foregroundColor: AppColors.red, side: const BorderSide(color: AppColors.red, width: 1.5), minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.close, size: 16), SizedBox(width: 6), Text('Reject', style: TextStyle(fontWeight: FontWeight.w700))]))),
                    const SizedBox(width: 8),
                    Expanded(child: ElevatedButton(onPressed: () async { await _respond(context, ref, c.proposal.id, true); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check, size: 16, color: Colors.white), SizedBox(width: 6), Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]))),
                  ]),
                  if (c.proposal.status == 'accepted' && c.marqueeWhatsapp.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _openWA(c.marqueeWhatsapp, c.marqueeName, c.proposal.eventDate ?? ''), icon: const Icon(Icons.chat, color: Colors.white, size: 18), label: const Text('Contact Owner on WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))))),
                  ],
                ])),
              ])),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _stat(String lbl, String val) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(lbl, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)), Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary))]);
  Widget _chips(String title, Iterable<String> items) {
    final list = items.toList();
    if (list.isEmpty) return Text('$title\nNone', style: const TextStyle(fontSize: 11, color: AppColors.textMuted));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5)),
      const SizedBox(height: 6),
      Wrap(spacing: 6, runSpacing: 6, children: list.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.check, size: 11, color: AppColors.primary), const SizedBox(width: 5), Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500))]))).toList()),
    ]);
  }
  Future<void> _respond(BuildContext context, WidgetRef ref, String id, bool accept) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: Text(accept ? 'Accept proposal?' : 'Reject proposal?'), content: Text(accept ? 'Other proposals will be declined.' : 'You can still receive other proposals.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes'))]));
    if (ok != true || !context.mounted) return;
    await ref.read(supabaseProvider).rpc('respond_to_proposal', params: {'p_proposal_id': id, 'p_accept': accept});
    ref.invalidate(customerProposalsProvider);
    if (context.mounted) context.go('/customer/proposals');
  }
  Future<void> _openWA(String phone, String name, String eventDate) async {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = '92${digits.substring(1)}';
    if (digits.length == 10 && !digits.startsWith('92')) digits = '92$digits';
    final greeting = Uri.encodeComponent('Hello $name, this is a customer from MarqueeFinder. I\'d like to discuss our event${eventDate.isNotEmpty ? " on $eventDate" : ""}.');
    final url = Uri.parse('https://wa.me/$digits?text=$greeting');
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
