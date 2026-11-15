import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../shared/domain/entities/menu_category.dart';
import '../../../../shared/domain/entities/menu_item.dart';
import '../../../../shared/domain/entities/service.dart';
import '../../../../shared/domain/entities/event_type.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/entities/comparison.dart';

class ReqDraft {
  final String? eventType, eventDate, location;
  final String? startHour, startMin, startAmPm, endHour, endMin, endAmPm;
  final bool isFullDay;
  final int guests;
  final num budget;
  final Set<String> menuItemIds;
  final Set<String> serviceIds;

  const ReqDraft({this.eventType, this.eventDate, this.location,
    this.startHour, this.startMin, this.startAmPm = 'PM',
    this.endHour, this.endMin, this.endAmPm = 'PM',
    this.isFullDay = false, this.guests = 0, this.budget = 0,
    this.menuItemIds = const {}, this.serviceIds = const {}});

  ReqDraft copyWith({String? eventType, String? eventDate, String? location,
    String? startHour, String? startMin, String? startAmPm,
    String? endHour, String? endMin, String? endAmPm,
    bool? isFullDay, int? guests, num? budget,
    Set<String>? menuItemIds, Set<String>? serviceIds}) => ReqDraft(
    eventType: eventType ?? this.eventType, eventDate: eventDate ?? this.eventDate,
    location: location ?? this.location, startHour: startHour ?? this.startHour,
    startMin: startMin ?? this.startMin, startAmPm: startAmPm ?? this.startAmPm,
    endHour: endHour ?? this.endHour, endMin: endMin ?? this.endMin,
    endAmPm: endAmPm ?? this.endAmPm, isFullDay: isFullDay ?? this.isFullDay,
    guests: guests ?? this.guests, budget: budget ?? this.budget,
    menuItemIds: menuItemIds ?? this.menuItemIds, serviceIds: serviceIds ?? this.serviceIds);

  String get timeString {
    if (isFullDay) return '24 Hours (Full Day)';
    if (startHour == null || endHour == null) return '';
    return '${startHour!.padLeft(2, '0')}:${(startMin ?? '00').padLeft(2, '0')} $startAmPm - '
           '${endHour!.padLeft(2, '0')}:${(endMin ?? '00').padLeft(2, '0')} $endAmPm';
  }
}

class ReqDraftCtrl extends StateNotifier<ReqDraft> {
  ReqDraftCtrl() : super(const ReqDraft());
  void setEventType(String v) => state = state.copyWith(eventType: v);
  void setDate(String v) => state = state.copyWith(eventDate: v);
  void setLocation(String v) => state = state.copyWith(location: v);
  void setGuests(int v) => state = state.copyWith(guests: v);
  void setBudget(num v) => state = state.copyWith(budget: v);
  void setStart(String h, String m, String ap) => state = state.copyWith(startHour: h, startMin: m, startAmPm: ap);
  void setEnd(String h, String m, String ap) => state = state.copyWith(endHour: h, endMin: m, endAmPm: ap);
  void setFullDay(bool v) => state = state.copyWith(isFullDay: v);
  void toggleMenu(String id) {
    final s = Set<String>.from(state.menuItemIds);
    s.contains(id) ? s.remove(id) : s.add(id);
    state = state.copyWith(menuItemIds: s);
  }
  void toggleService(String id) {
    final s = Set<String>.from(state.serviceIds);
    s.contains(id) ? s.remove(id) : s.add(id);
    state = state.copyWith(serviceIds: s);
  }
  void reset() => state = const ReqDraft();
}

final reqDraftProvider = StateNotifierProvider<ReqDraftCtrl, ReqDraft>((r) => ReqDraftCtrl());

final parentCategoriesProvider = FutureProvider<List<MenuCategory>>((ref) async {
  final sb = ref.read(supabaseProvider);
  final rows = await sb.from('menu_categories').select().filter('parent_id', 'is', null).order('sort_order');
  return rows.map((r) => MenuCategory(id: r['id'], name: r['name'] ?? '', parentId: r['parent_id'])).toList();
});

final itemsForCategoryProvider = FutureProvider.family<List<MenuItem>, String>((ref, catId) async {
  final sb = ref.read(supabaseProvider);
  final rows = await sb.from('menu_catalog_items').select().eq('category_id', catId).order('sort_order');
  return rows.map((r) => MenuItem(id: r['id'], categoryId: r['category_id'], name: r['name'] ?? '', imageUrl: r['image_url'])).toList();
});

final servicesCatalogProvider = FutureProvider<List<Service>>((ref) async {
  final sb = ref.read(supabaseProvider);
  final rows = await sb.from('service_catalog').select().order('sort_order');
  return rows.map((r) => Service(id: r['id'], key: r['key'] ?? '', name: r['name'] ?? '', imageUrl: r['image_url'], description: r['description'])).toList();
});

final eventTypesProvider = FutureProvider<List<EventType>>((ref) async {
  final sb = ref.read(supabaseProvider);
  final rows = await sb.from('event_types').select().order('sort_order');
  return rows.map((r) => EventType(id: (r['id'] as num).toInt(), name: r['name'] ?? '', sortOrder: r['sort_order'] ?? 0)).toList();
});

final customerProposalsProvider = FutureProvider.autoDispose<List<Proposal>>((ref) async {
  final sb = ref.read(supabaseProvider);
  final rows = await sb.from('v_customer_proposals').select().neq('status', 'withdrawn').order('created_at', ascending: false);
  return rows.map((r) => Proposal(id: r['id'], status: r['status'] ?? 'pending', referenceId: r['reference_id'] ?? '', marqueeName: r['marquee_name'] ?? 'Marquee', eventDate: r['event_date'], marqueeCover: r['marquee_cover'], totalPrice: (r['total_price'] ?? 0) as num, guests: (r['guests'] ?? 0) as int)).toList();
});

final proposalComparisonProvider = FutureProvider.family.autoDispose<ProposalComparison, String>((ref, id) async {
  final sb = ref.read(supabaseProvider);
  final r = await sb.rpc('get_proposal_comparison', params: {'p_proposal_id': id});
  final j = r as Map<String, dynamic>;
  final m = j['marquee'] ?? {};
  return ProposalComparison(
    proposal: Proposal(id: j['proposal']['id'], status: j['proposal']['status'] ?? 'pending', referenceId: j['proposal']['reference_id'] ?? '', marqueeName: m['name'] ?? '', eventDate: j['proposal']['event_date'], marqueeCover: m['cover_image'], totalPrice: (j['proposal']['total_price'] ?? 0) as num, guests: (j['proposal']['guests'] ?? 0) as int),
    marqueeName: m['name'] ?? 'Marquee', marqueeCover: m['cover_image'] ?? '', marqueeLocation: m['location'] ?? '-', marqueeWhatsapp: m['whatsapp'] ?? '',
    requestedTotal: (j['requested_total'] ?? 0) as num, requestedPerHead: (j['requested_per_head'] ?? 0) as num,
    menu: (j['menu'] as List? ?? []).map((e) => ComparisonItem(item: e['item'] ?? '', requested: e['requested'] == true, proposed: e['proposed'] == true)).toList(),
    services: (j['services'] as List? ?? []).map((e) => ComparisonItem(item: e['item'] ?? '', requested: e['requested'] == true, proposed: e['proposed'] == true)).toList(),
  );
});

final allMenuItemsProvider = FutureProvider<List<MenuItem>>((ref) async {
  final sb = ref.read(supabaseProvider);
  final rows = await sb.from('menu_catalog_items').select().order('sort_order');
  return rows.map((r) => MenuItem(id: r['id'], categoryId: r['category_id'], name: r['name'] ?? '', imageUrl: r['image_url'])).toList();
});