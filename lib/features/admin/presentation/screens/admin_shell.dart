import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/supabase_client.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  static const nav = [
    ('/admin/dashboard', Icons.dashboard_outlined, 'Dashboard Overview'),
    ('/admin/food', Icons.restaurant_menu, 'Food Menu'),
    ('/admin/event-types', Icons.event_note, 'Event Types'),
    ('/admin/services', Icons.settings_outlined, 'Services'),
    ('/admin/marquees', Icons.store_outlined, 'Marquee Management'),
    ('/admin/customers', Icons.people_outline, 'Customer Management'),
    ('/admin/proposals', Icons.description_outlined, 'Proposals'),
    ('/admin/bookings', Icons.calendar_today_outlined, 'Deals'),
    ('/admin/landing', Icons.image_outlined, 'Landing Page Images'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).matchedLocation;
    final wide = MediaQuery.of(context).size.width > 900;

    if (wide) {
      return Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Row(children: [
          _sidebar(context, ref, loc, wide: true),
          Expanded(child: Column(children: [
            _header(context, ref, loc),
            Expanded(child: child),
          ])),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      drawer: Drawer(child: SafeArea(child: _sidebar(context, ref, loc))),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(_getTitle(loc), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.primary)),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: child,
    );
  }

  Widget _header(BuildContext context, WidgetRef ref, String loc) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
    color: const Color(0xFFF1F5F9),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_getTitle(loc), style: GoogleFonts.playfairDisplay(fontSize: 23, fontWeight: FontWeight.w700, color: AppColors.primary, height: 1.15)),
        const SizedBox(height: 3),
        Text(_getSub(loc), style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
      ])),
      IconButton(
        onPressed: () async {
          await ref.read(supabaseProvider).rpc('switch_mode', params: {'p_mode': 'customer'});
          if (context.mounted) context.go('/customer/home');
        },
        icon: const Icon(Icons.sync_rounded, color: AppColors.primary, size: 18),
        style: IconButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.all(12)),
        tooltip: 'Switch to Customer',
      ),
    ]),
  );

  String _getTitle(String loc) {
    if (loc.contains('/dashboard')) return 'Dashboard Overview';
    if (loc.contains('/food')) return 'Food Menu Management';
    if (loc.contains('/event-types')) return 'Event Types';
    if (loc.contains('/services')) return 'Services Management';
    if (loc.contains('/marquees')) return 'Marquee Management';
    if (loc.contains('/customers')) return 'Customer Management';
    if (loc.contains('/proposals')) return 'Proposals';
    if (loc.contains('/bookings')) return 'Deals';
    if (loc.contains('/landing')) return 'Landing Page Images';
    return 'Admin Panel';
  }

  String _getSub(String loc) {
    if (loc.contains('/dashboard')) return 'Platform overview and recent activity';
    if (loc.contains('/food')) return 'Parent categories appear as navigation tabs';
    if (loc.contains('/event-types')) return 'Manage event types shown to customers';
    if (loc.contains('/services')) return 'Manage the services offered across marquees';
    if (loc.contains('/marquees')) return 'Approve, suspend, or manage registered marquees';
    if (loc.contains('/customers')) return 'View registered customers and their activity';
    if (loc.contains('/proposals')) return 'All proposals sent between customers and marquees';
    if (loc.contains('/bookings')) return 'Completed and ongoing bookings across all marquees';
    if (loc.contains('/landing')) return 'Manage the promotional images on the public landing page';
    return 'Welcome back, Admin';
  }

  Widget _sidebar(BuildContext context, WidgetRef ref, String loc, {bool wide = false}) {
    return Container(
      width: 248,
      decoration: const BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: AppColors.border))),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.celebration, color: AppColors.gold, size: 18)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(text: TextSpan(style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary), children: const [TextSpan(text: 'Marquee'), TextSpan(text: 'Finder', style: TextStyle(color: AppColors.gold))])),
              const Text('ADMIN PANEL', style: TextStyle(fontSize: 8.5, letterSpacing: 1.5, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
            ]),
          ]),
        ),
        Expanded(child: ListView(padding: const EdgeInsets.all(10), children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14), child: Text('CATALOG', style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: AppColors.textMuted, fontWeight: FontWeight.w700))),
          ...nav.take(4).map((n) => _navItem(context, n, loc, wide)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14), child: Text('MANAGEMENT', style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: AppColors.textMuted, fontWeight: FontWeight.w700))),
          ...nav.skip(4).take(4).map((n) => _navItem(context, n, loc, wide)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14), child: Text('WEBSITE', style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: AppColors.textMuted, fontWeight: FontWeight.w700))),
          ...nav.skip(8).map((n) => _navItem(context, n, loc, wide)),
        ])),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
          child: ListTile(
            leading: const Icon(Icons.logout, color: AppColors.red, size: 18),
            title: const Text('Logout', style: TextStyle(color: AppColors.red, fontSize: 12.5, fontWeight: FontWeight.w600)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onTap: () async {
              if (!wide) Navigator.pop(context);
              await ref.read(supabaseProvider).auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        )
      ]),
    );
  }

  Widget _navItem(BuildContext context, (String, IconData, String) n, String loc, bool wide) {
    final active = loc.startsWith(n.$1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: () {
          if (!wide) Navigator.pop(context);
          context.go(n.$1);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: active ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(n.$2, color: active ? Colors.white : AppColors.textMuted, size: 15),
            const SizedBox(width: 12),
            Expanded(child: Text(n.$3, style: TextStyle(color: active ? Colors.white : AppColors.text, fontSize: 12.5, fontWeight: FontWeight.w600))),
          ]),
        ),
      ),
    );
  }
}
