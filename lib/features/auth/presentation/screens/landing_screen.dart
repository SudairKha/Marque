import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(fit: StackFit.expand, children: [
      Image.network('https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=1000', fit: BoxFit.cover),
      Container(color: Colors.black.withOpacity(0.6)),
      Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(
        mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.celebration, color: AppColors.gold, size: 60),
          const SizedBox(height: 12),
          const Text('MarqueeFinder', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('FIND • COMPARE • BOOK', style: TextStyle(fontSize: 10, letterSpacing: 4, color: AppColors.gold, fontWeight: FontWeight.w600)),
          const SizedBox(height: 40),
          const Text('Connect. Bid. Grow Your Business.', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 18, color: Colors.white70), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
            child: const Text('Get Started', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
          const SizedBox(height: 16),
          TextButton(onPressed: () => context.go('/signup'), child: const Text('Create an account', style: TextStyle(color: AppColors.gold, decoration: TextDecoration.underline))),
        ]))),
    ]));
}
