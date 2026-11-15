import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../../domain/entities/menu_category.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/event_type.dart';

final parentCategoriesProvider = FutureProvider<List<MenuCategory>>((ref) async {
  final sb = ref.read(supabaseProvider);
  final rows = await sb.from('menu_categories').select().filter('parent_id', 'is', null).order('sort_order');
  return rows.map((r) => MenuCategory(
    id: r['id'], name: r['name'] ?? '', parentId: r['parent_id'], sortOrder: r['sort_order'] ?? 0
  )).toList();
});

final itemsForCategoryProvider = FutureProvider.family<List<MenuItem>, String>((ref, catId) async {
  final sb = ref.read(supabaseProvider);
  final rows = await sb.from('menu_catalog_items').select().eq('category_id', catId).order('sort_order');
  return rows.map((r) => MenuItem(
    id: r['id'], categoryId: r['category_id'], name: r['name'] ?? '', imageUrl: r['image_url'], sortOrder: r['sort_order'] ?? 0
  )).toList();
});

final servicesCatalogProvider = FutureProvider<List<Service>>((ref) async {
  final sb = ref.read(supabaseProvider);
  final rows = await sb.from('service_catalog').select().order('sort_order');
  return rows.map((r) => Service(
    id: r['id'], key: r['key'] ?? r['service_key'] ?? '', name: r['name'] ?? '', imageUrl: r['image_url'], description: r['description']
  )).toList();
});

final eventTypesProvider = FutureProvider<List<EventType>>((ref) async {
  final sb = ref.read(supabaseProvider);
  final rows = await sb.from('event_types').select().order('sort_order');
  return rows.map((r) => EventType(
    id: (r['id'] as num).toInt(), name: r['name'] ?? '', sortOrder: r['sort_order'] ?? 0
  )).toList();
});
