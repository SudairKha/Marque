import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/owner_providers.dart';
import 'owner_shell.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ownerDashboardProvider);
    final userProfile = ref.watch(userProfileProvider);
    final activeMqId = ref.watch(activeMarqueeProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            OwnerHdr(title: 'Dashboard', onBack: _empty),
            async.when(
              loading: () => const SizedBox(height: 135),
              error: (_, __) => const SizedBox(),
              data: (d) {
                String coverImage = 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=800';
                if (d != null && (d['marquees'] as List).isNotEmpty) {
                  final marquees = d['marquees'] as List;
                  Map<String, dynamic> activeMq = marquees.first;
                  if (activeMqId != null) { for (var m in marquees) { if (m['id'] == activeMqId) { activeMq = m; break; } } }
                  if (activeMq['cover_image'] != null && activeMq['cover_image'].toString().isNotEmpty) { coverImage = activeMq['cover_image']; }
                }
                return Container(
                  width: double.infinity, 
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: NetworkImage(coverImage), fit: BoxFit.cover)), 
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xEB0e4b3b), Color(0xC70e4b3b)], begin: Alignment.topLeft, end: Alignment.bottomRight)), 
                    padding: const EdgeInsets.all(20), 
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Welcome Back,', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w400, color: Colors.white)),
                      userProfile.when(loading: () => Text('...', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)), error: (_, __) => Text('User!', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)), data: (p) => Text('${p?['full_name'] ?? 'User'}!', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white))),
                      const SizedBox(height: 6), 
                      const Text('Manage your marquee & grow your business.', style: TextStyle(fontSize: 11.5, color: Colors.white70)),
                    ]),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            async.when(
              loading: () => const SizedBox(height: 70), 
              error: (_, __) => const SizedBox(), 
              data: (d) {
                if (d == null) return const SizedBox();
                final newReqs = (d['props'] as List).where((r) => r['status'] == 'pending').length; 
                final props = (d['props'] as List).length; 
                final books = (d['books'] as List).length; 
                final rev = (d['books'] as List).where((b) => b['status'] == 'completed').fold(0.0, (s, b) => s + (b['total_amount'] ?? 0));
                return Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Row(children: [
                  _stat('$newReqs', 'New Req.', Icons.description), const SizedBox(width: 6), 
                  _stat('$props', 'Proposals', Icons.comment), const SizedBox(width: 6), 
                  _stat('$books', 'Bookings', Icons.calendar_month), const SizedBox(width: 6), 
                  _stat(rev > 0 ? '${(rev / 1000).round()}k' : '0', 'Revenue', Icons.trending_up)
                ]));
              },
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity, 
              margin: const EdgeInsets.symmetric(horizontal: 18), 
              padding: const EdgeInsets.all(14), 
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFEF9EC), Color(0xFFF6ECD0)]), border: Border.all(color: const Color(0xFFF0E6C5)), borderRadius: BorderRadius.circular(14)), 
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('LIST YOUR MARQUEE', style: TextStyle(fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: AppColors.primary)), 
                  const SizedBox(height: 3), 
                  Text('Add Your Marquee', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)), 
                  const SizedBox(height: 2), 
                  const Text('Showcase your venue, add photos, menu and services.', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted))
                ])),
                ElevatedButton.icon(onPressed: () => context.go('/owner/marquee/1'), icon: const Icon(Icons.add, size: 14, color: Colors.white), label: const Text('Add', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10))),
              ]),
            ),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Text('My Marquees', style: GoogleFonts.playfairDisplay(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primary))), 
            const SizedBox(height: 8),
            async.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())), 
              error: (e, _) => Center(child: Text('$e')), 
              data: (d) {
                if (d == null || (d['marquees'] as List).isEmpty) return const Padding(padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10), child: Text('No marquees yet', style: TextStyle(fontSize: 12, color: AppColors.textMuted)));
                if (activeMqId == null) { 
                  final approved = (d['marquees'] as List).where((m) => m['status'] == 'approved'); 
                  if (approved.isNotEmpty) { 
                    WidgetsBinding.instance.addPostFrameCallback((_) { ref.read(activeMarqueeProvider.notifier).state = approved.first['id']; }); 
                  } 
                }
                return Column(children: (d['marquees'] as List).map((m) {
                  final isActive = m['id'] == activeMqId; final isApproved = m['status'] == 'approved';
                  return Container(
                    width: double.infinity, 
                    margin: const EdgeInsets.only(left: 18, right: 18, bottom: 8), 
                    padding: const EdgeInsets.all(10), 
                    decoration: BoxDecoration(color: isActive ? AppColors.soft : Colors.white, border: Border.all(color: isActive ? AppColors.primary : AppColors.border, width: isActive ? 2 : 1), borderRadius: BorderRadius.circular(12)), 
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(m['cover_image'] ?? '', width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.soft))), 
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(m['name'] ?? 'Marquee', style: GoogleFonts.playfairDisplay(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)), 
                        Text(m['location'] ?? '', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)), 
                        Row(children: [const Icon(Icons.people, size: 10), Text(' ${m['capacity']} guests', style: const TextStyle(fontSize: 9)), const SizedBox(width: 8), const Icon(Icons.wallet, size: 10), Text(' ${money(m['price'])}', style: const TextStyle(fontSize: 9))])
                      ])),
                      if (isApproved) 
                        isActive 
                          ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: const Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))) 
                          : OutlinedButton(
                              onPressed: () => ref.read(activeMarqueeProvider.notifier).state = m['id'], 
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), minimumSize: Size.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                              child: const Text('Activate', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary))
                            ) 
                      else 
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: m['status'] == 'pending' ? AppColors.amberSoft : AppColors.redSoft, borderRadius: BorderRadius.circular(8)), child: Text(m['status'] ?? '', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: m['status'] == 'pending' ? AppColors.amber : AppColors.red))),
                    ]),
                  );
                }).toList());
              },
            ),
          ]),
        ),
      ),
    );
  }
  void _empty() {}
  Widget _stat(String val, String lbl, IconData icon) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)), child: Column(children: [Container(width: 26, height: 26, decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 12, color: AppColors.primary)), const SizedBox(height: 5), Text(val, style: GoogleFonts.playfairDisplay(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)), Text(lbl, style: const TextStyle(fontSize: 8, color: AppColors.textMuted, height: 1.15))])));
}
