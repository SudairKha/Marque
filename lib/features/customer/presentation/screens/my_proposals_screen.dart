import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/customer_providers.dart';

class MyProposalsScreen extends ConsumerStatefulWidget {
  const MyProposalsScreen({super.key});
  @override
  ConsumerState<MyProposalsScreen> createState() => _MyProposalsState();
}

class _MyProposalsState extends ConsumerState<MyProposalsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(customerProposalsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(customerProposalsProvider),
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) {
              final filtered = list.where((p) {
                if (_filter == 'all') return true;
                return p.status == _filter;
              }).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                children: [
                  Row(children: [
                    const SizedBox(width: 30),
                    Expanded(child: Center(child: RichText(text: TextSpan(style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary), children: const [TextSpan(text: 'Marquee'), TextSpan(text: 'Finder', style: TextStyle(color: AppColors.gold))])))),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.person_outline, size: 12, color: AppColors.primary), SizedBox(width: 6), Text('Customer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary))])),
                  ]),
                  const SizedBox(height: 14),
                  Text('My Responses', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 4), 
                  const Text('Track all proposals from owners', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                  const SizedBox(height: 14),
                  
                  // HTML Tabs
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: ['all', 'pending', 'accepted'].map((f) {
                        final active = _filter == f;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _filter = f),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(color: active ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(9)),
                              child: Center(
                                child: Text(
                                  f[0].toUpperCase() + f.substring(1),
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.text),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (filtered.isEmpty)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: Column(children: [Icon(Icons.folder_open, size: 48, color: AppColors.border), SizedBox(height: 12), Text('No responses yet', style: TextStyle(fontSize: 12, color: AppColors.textMuted))])))
                  else
                    ...filtered.map((p) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                      child: InkWell(
                        onTap: () => context.go('/customer/proposal/${p.id}'), borderRadius: BorderRadius.circular(14),
                        child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(p.marqueeCover ?? '', width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: AppColors.soft))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text(p.referenceId, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                              const Spacer(),
                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: p.status == 'pending' ? AppColors.amberSoft : (p.status == 'accepted' ? AppColors.greenSoft : AppColors.redSoft), borderRadius: BorderRadius.circular(9)), child: Text(p.status, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: p.status == 'pending' ? const Color(0xFF92400E) : (p.status == 'accepted' ? const Color(0xFF15803D) : const Color(0xFFB91C1C))))),
                            ]),
                            const SizedBox(height: 4),
                            Text(p.marqueeName, style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.wallet, size: 12, color: AppColors.primary), const SizedBox(width: 4), Text(money(p.totalPrice), style: const TextStyle(fontSize: 10.5, color: AppColors.text)),
                              const SizedBox(width: 10),
                              const Icon(Icons.calendar_today, size: 12, color: AppColors.primary), const SizedBox(width: 4), Text(fmtDate(p.eventDate), style: const TextStyle(fontSize: 10.5, color: AppColors.text)),
                            ]),
                          ])),
                        ])),
                      ),
                    )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
