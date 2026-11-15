class MenuCategory {
  final String id, name;
  final String? parentId;
  final int sortOrder;
  MenuCategory({required this.id, required this.name, this.parentId, this.sortOrder = 0});
}
