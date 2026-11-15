import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class OwnerShell extends StatelessWidget {
  final Widget child;
  const OwnerShell({super.key, required this.child});
  static const tabs = [
    ('/owner/dashboard', Icons.home_outlined, 'Home'),
    ('/owner/reqs', Icons.description_outlined, 'Proposals'),
    ('/owner/bookings', Icons.calendar_today_outlined, 'Bookings'),
    ('/owner/profile', Icons.person_outline, 'Profile'),
  ];
  int _index(String loc) { for (int i = 0; i < tabs.length; i++) { if (loc.startsWith(tabs[i].$1)) return i; } return 0; }
  @override
  Widget build(BuildContext context) {
    final idx = _index(GoRouterState.of(context).matchedLocation);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, -4))], border: Border(top: BorderSide(color: AppColors.border))),
        child: SafeArea(top: false, child: SizedBox(height: 72, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(tabs.length, (i) {
          final active = i == idx;
          return Expanded(child: InkWell(onTap: () => context.go(tabs[i].$1), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(tabs[i].$2, size: 19, color: active ? AppColors.primary : AppColors.textMuted), const SizedBox(height: 3),
            Text(tabs[i].$3, style: TextStyle(fontSize: 10.5, fontWeight: active ? FontWeight.w600 : FontWeight.w500, color: active ? AppColors.primary : AppColors.textMuted)),
          ])));
        })))),
      ),
    );
  }
}

class OwnerHdr extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const OwnerHdr({super.key, required this.title, required this.onBack});
  
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), // Reduced padding
    child: Row(children: [
      InkWell(onTap: onBack, child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.menu, size: 24, color: AppColors.primary))),
      Expanded(child: Center(child: Text(title, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)))),
      GestureDetector(
        onTap: () => context.go('/customer/home'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(20)),
          child: const Row(children: [Icon(Icons.store, size: 12, color: AppColors.primary), SizedBox(width: 6), Text('Owner', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)), SizedBox(width: 4), Icon(Icons.keyboard_arrow_down, size: 12, color: AppColors.primary)]),
        ),
      ),
    ]),
  );
}
