import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class CustomerShell extends StatelessWidget {
  final Widget child;
  const CustomerShell({super.key, required this.child});

  static const tabs = [
    ('/customer/home', Icons.home_outlined, 'Home'),
    ('/customer/req/1', Icons.description_outlined, 'Requirements'),
    ('/customer/proposals', Icons.folder_outlined, 'Responses'),
    ('/customer/profile', Icons.person_outline, 'Profile'),
  ];

  int _index(String loc) {
    for (int i = 0; i < tabs.length; i++) {
      if (loc.startsWith(tabs[i].$1.split('/').take(3).join('/'))) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _index(loc);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, -4))],
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (i) {
                final t = tabs[i];
                final active = i == idx;
                return Expanded(
                  child: InkWell(
                    onTap: () => context.go(t.$1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(t.$2, size: 19, color: active ? AppColors.primary : AppColors.textMuted),
                        const SizedBox(height: 3),
                        Text(t.$3, style: TextStyle(fontSize: 10.5, fontWeight: active ? FontWeight.w600 : FontWeight.w500, color: active ? AppColors.primary : AppColors.textMuted)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
