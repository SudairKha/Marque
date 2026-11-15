import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './core/router/app_router.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
  );
  runApp(const ProviderScope(child: MarqueeApp()));
}

class MarqueeApp extends ConsumerWidget {
  const MarqueeApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = appRouter;
    return MaterialApp.router(
      title: 'MarqueeFinder',
      theme: AppTheme.light(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
