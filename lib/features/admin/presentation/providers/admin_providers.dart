import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';

final adminStatsProvider = FutureProvider.autoDispose((ref) async {
  ref.keepAlive();
  final sb = ref.read(supabaseProvider);
  final results = await Future.wait([
    sb.from('marquees').select('id, status'),
    sb.from('requirements').select('id, customer_id'),
    sb.from('proposals').select('id, status'),
    sb.from('bookings').select('id, status'),
    sb.from('menu_categories').select('id'),
    sb.from('menu_catalog_items').select('id'),
    sb.from('service_catalog').select('id')
  ]);
  final mqs = results[0] as List;
  final reqs = results[1] as List;
  final props = results[2] as List;
  final books = results[3] as List;
  return {
    'customerCount': reqs.map((r) => r['customer_id']).toSet().length,
    'totalMarquees': mqs.length,
    'pendingApprovals': mqs.where((m) => m['status'] == 'pending').length,
    'categories': (results[4] as List).length,
    'menuItems': (results[5] as List).length,
    'services': (results[6] as List).length,
    'proposals': props.length,
    'completedDeals': books.where((b) => b['status'] == 'completed').length,
  };
});

final adminMarqueesProvider = FutureProvider.autoDispose((ref) async {
  ref.keepAlive();
  final rows = await ref.read(supabaseProvider).from('marquees').select('*').order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(rows);
});

final adminCustomersProvider = FutureProvider.autoDispose((ref) async {
  ref.keepAlive();
  final sb = ref.read(supabaseProvider);
  final results = await Future.wait([
    sb.from('profiles').select('id, full_name, email, phone, avatar_url, is_admin, created_at').order('created_at', ascending: false),
    sb.from('requirements').select('customer_id')
  ]);
  return {
    'profiles': List<Map<String, dynamic>>.from(results[0] as List).where((p) => p['is_admin'] != true).toList(),
    'reqs': List<Map<String, dynamic>>.from(results[1] as List),
  };
});

final adminProposalsProvider = FutureProvider.autoDispose((ref) async {
  ref.keepAlive();
  final rows = await ref.read(supabaseProvider).from('proposals').select('*, marquees(name), profiles!proposals_customer_id_fkey(full_name, phone)').order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(rows);
});

final adminBookingsProvider = FutureProvider.autoDispose((ref) async {
  ref.keepAlive();
  final rows = await ref.read(supabaseProvider).from('bookings').select('*, marquees(name)').order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(rows);
});

final adminEventTypesProvider = FutureProvider.autoDispose((ref) async {
  ref.keepAlive();
  final rows = await ref.read(supabaseProvider).from('event_types').select().order('sort_order');
  return List<Map<String, dynamic>>.from(rows);
});

final adminServicesProvider = FutureProvider.autoDispose((ref) async {
  ref.keepAlive();
  final rows = await ref.read(supabaseProvider).from('service_catalog').select().order('sort_order');
  return List<Map<String, dynamic>>.from(rows);
});

final adminLandingImagesProvider = FutureProvider.autoDispose((ref) async {
  ref.keepAlive();
  final rows = await ref.read(supabaseProvider).from('landing_images').select().order('position');
  return List<Map<String, dynamic>>.from(rows);
});

final adminFoodMenuProvider = FutureProvider.autoDispose((ref) async {
  ref.keepAlive();
  final sb = ref.read(supabaseProvider);
  final results = await Future.wait([
    sb.from('menu_categories').select('*').order('sort_order'),
    sb.from('menu_catalog_items').select('*').order('sort_order')
  ]);
  return {
    'cats': List<Map<String, dynamic>>.from(results[0] as List),
    'items': List<Map<String, dynamic>>.from(results[1] as List),
  };
});
