import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';

final activeMarqueeProvider = StateProvider<String?>((ref) => null);

final ownerDashboardProvider = FutureProvider.autoDispose((ref) async {
  ref.keepAlive();
  final sb = ref.read(supabaseProvider);
  final user = sb.auth.currentUser;
  if (user == null) return null;

  final marquees = await sb.from('marquees').select().eq('owner_id', user.id).order('created_at', ascending: false);
  final props = await sb.from('proposals').select('id, status').eq('owner_id', user.id);
  final books = await sb.from('bookings').select('id, total_amount, status').eq('owner_id', user.id);

  return {
    'marquees': List<Map<String, dynamic>>.from(marquees),
    'props': List<Map<String, dynamic>>.from(props),
    'books': List<Map<String, dynamic>>.from(books),
  };
});

final userProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  ref.keepAlive();
  final sb = ref.read(supabaseProvider);
  final user = sb.auth.currentUser;
  if (user == null) return null;
  return await sb.from('profiles').select().eq('id', user.id).single();
});

final allMenuCategoriesProvider = FutureProvider.autoDispose((ref) async {
  final rows = await ref.read(supabaseProvider).from('menu_categories').select().order('sort_order');
  return List<Map<String, dynamic>>.from(rows);
});

final ownerProposalsProvider = FutureProvider.autoDispose((ref) async {
  ref.keepAlive();
  final activeMqId = ref.watch(activeMarqueeProvider);
  if (activeMqId == null) return <Map<String, dynamic>>[];
  
  final sb = ref.read(supabaseProvider);
  // Fetch all requirements (since requirements are sent to all approved marquees)
  final reqs = await sb.from('v_owner_requirements').select().order('created_at', ascending: false);
  
  // Fetch my proposals for this specific marquee
  final myProps = await sb.from('proposals').select('*').eq('marquee_id', activeMqId);
  
  final propsByReqId = { for (var p in myProps) p['requirement_id']: p };
  
  final result = <Map<String, dynamic>>[];
  for (var r in reqs) {
    final p = propsByReqId[r['id']];
    result.add({
      'requirement': r,
      'proposal': p, // null if not responded
    });
  }
  return result;
});

final existingProposalProvider = FutureProvider.family.autoDispose((ref, String reqId) async {
  final activeMqId = ref.read(activeMarqueeProvider);
  if (activeMqId == null) return null;
  final sb = ref.read(supabaseProvider);
  return await sb.from('proposals').select('id').eq('requirement_id', reqId).eq('marquee_id', activeMqId).maybeSingle();
});

final ownerBookingsProvider = FutureProvider.autoDispose((ref) async {
  ref.keepAlive();
  final activeMqId = ref.watch(activeMarqueeProvider);
  if (activeMqId == null) return <Map<String, dynamic>>[];
  final rows = await ref.read(supabaseProvider).from('bookings').select('*').eq('marquee_id', activeMqId).order('event_date', ascending: false);
  return List<Map<String, dynamic>>.from(rows);
});

final reqDetailProvider = FutureProvider.family.autoDispose((ref, String id) async {
  final sb = ref.read(supabaseProvider);
  final req = await sb.from('v_owner_requirements').select().eq('id', id).single();
  final menu = await sb.from('requirement_menu_items').select().eq('requirement_id', id);
  final svc = await sb.from('requirement_services').select().eq('requirement_id', id);
  return {
    'req': req,
    'menu': List<Map<String, dynamic>>.from(menu),
    'svc': List<Map<String, dynamic>>.from(svc)
  };
});

final bookingDetailProvider = FutureProvider.family.autoDispose((ref, String id) async {
  final sb = ref.read(supabaseProvider);
  final b = await sb.from('bookings').select().eq('id', id).single();
  
  final proposal = await sb.from('proposals').select('*').eq('requirement_id', b['requirement_id']).eq('marquee_id', b['marquee_id']).eq('status', 'accepted').maybeSingle();
  final req = await sb.from('v_owner_requirements').select().eq('id', b['requirement_id']).maybeSingle();
  
  return {'booking': b, 'proposal': proposal, 'req': req};
});

final marqueeMenuItemsProvider = FutureProvider.family.autoDispose((ref, String mqId) async {
  final sb = ref.read(supabaseProvider);
  final rows = await sb.from('marquee_menu_items').select().eq('marquee_id', mqId);
  return List<Map<String, dynamic>>.from(rows);
});

final marqueeServicesProvider = FutureProvider.family.autoDispose((ref, String mqId) async {
  final sb = ref.read(supabaseProvider);
  final rows = await sb.from('marquee_services').select().eq('marquee_id', mqId);
  return List<Map<String, dynamic>>.from(rows);
});
