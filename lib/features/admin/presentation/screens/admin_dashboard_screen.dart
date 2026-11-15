import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminStatsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: async.when(
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary))),
        error: (e, _) => Center(child: Text('$e')),
        data: (d) => Column(children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive Grid: 2 columns on mobile, 4 on desktop
              int crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount, 
                crossAxisSpacing: 10, 
                mainAxisSpacing: 10, 
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                childAspectRatio: 1.8,
                children: [
                  _card('Total Customers', '${d['customerCount']}', const Color(0xFF3B82F6), const Color(0xFFDBEAFE), Icons.people),
                  _card('Total Marquees', '${d['totalMarquees']}', AppColors.primary, AppColors.soft, Icons.store),
                  _card('Pending Approvals', '${d['pendingApprovals']}', AppColors.amber, const Color(0xFFFEF3C7), Icons.access_time),
                  _card('Categories', '${d['categories']}', const Color(0xFF8B5CF6), const Color(0xFFEDE9FE), Icons.layers),
                  _card('Menu Items', '${d['menuItems']}', AppColors.primary, AppColors.soft, Icons.restaurant),
                  _card('Services', '${d['services']}', const Color(0xFF0891B2), const Color(0xFFCFFAFE), Icons.settings),
                  _card('Proposals', '${d['proposals']}', const Color(0xFF8B5CF6), const Color(0xFFEDE9FE), Icons.description),
                  _card('Completed Deals', '${d['completedDeals']}', AppColors.green, const Color(0xFFDCFCE7), Icons.check_circle),
                ],
              );
            }
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome, Admin 👋', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 4),
              const Text('Use the sidebar to manage marquees, proposals, and platform data.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _card(String label, String val, Color color, Color bg, IconData icon) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5), maxLines: 2, overflow: TextOverflow.ellipsis)),
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 12, color: color)),
      ]),
      Text(val, style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}
