import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/customer_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});
  @override ConsumerState<CustomerHomeScreen> createState() => _State();
}

class _State extends ConsumerState<CustomerHomeScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0; Timer? _timer;
  @override void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_currentPage < 2) { _currentPage++; } else { _currentPage = 0; }
      if (_pageCtrl.hasClients) _pageCtrl.animateToPage(_currentPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    });
  }
  @override void dispose() { _timer?.cancel(); _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider); final events = ref.watch(eventTypesProvider);
    final first = profile?.fullName?.split(' ').first ?? 'User';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Welcome,', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                Text('$first 👋', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary, height: 1.15)),
              ])),
              Column(children: [
                const Icon(Icons.celebration, color: AppColors.gold, size: 22),
                RichText(text: TextSpan(style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary), children: const [TextSpan(text: 'Marquee'), TextSpan(text: 'Finder', style: TextStyle(color: AppColors.gold))])),
                const Text('FIND • COMPARE • BOOK', style: TextStyle(fontSize: 7, letterSpacing: 2, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ]),
              GestureDetector(
                onTap: () => context.go('/customer/profile'),
                child: CircleAvatar(
                  radius: 18, backgroundColor: AppColors.lightBg,
                  backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
                  child: profile?.avatarUrl == null ? Text(first[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13)) : null,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            const Text('Plan. Compare. Book with confidence.', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
            const SizedBox(height: 14),
            SizedBox(height: 200, child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView(controller: _pageCtrl, onPageChanged: (i) => setState(() => _currentPage = i), children: const [
                _HeroSlide('https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=1000'),
                _HeroSlide('https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=1000'),
                _HeroSlide('https://images.unsplash.com/photo-1530103862676-de8c9debad1d?q=80&w=1000'),
              ]),
            )),
            const SizedBox(height: 20),
            Text('Plan Your Event', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 4), const Text('Tell us what you need and get offers.', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () => context.go('/customer/req/1'),
              icon: const Icon(Icons.description_outlined, size: 18, color: Colors.white),
              label: const Text('Create Your Requirement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
            )),
            const SizedBox(height: 22),
            Text('Explore Event Types', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 4), const Text('Choose an event type to start.', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            events.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (list) => SizedBox(height: 80, child: ListView.separated(
                scrollDirection: Axis.horizontal, itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => context.go('/customer/req/1'),
                  child: SizedBox(width: 76, child: Column(children: [
                    Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.celebration, color: AppColors.primary, size: 22)),
                    const SizedBox(height: 6),
                    Text(list[i].name.split(' ').first, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.text), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                  ])),
                ),
              )),
            ),
          ]),
        ),
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final String img; const _HeroSlide(this.img);
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)),
    child: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xE60E4B3B), Color(0x660E4B3B)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('TURN YOUR MOMENTS', style: TextStyle(fontSize: 9.5, letterSpacing: 2, fontWeight: FontWeight.w600, color: Colors.white70)),
        const SizedBox(height: 8),
        const Text('Into Beautiful\nMemories', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 24, height: 1.15, color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8), const Text('Find and book the perfect marquee.', style: TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => context.go('/customer/req/1'), icon: const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
          label: const Text('Create Requirement', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10)),
        ),
      ]),
    ),
  );
}
