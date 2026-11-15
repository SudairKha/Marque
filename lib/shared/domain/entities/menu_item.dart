class MenuItem {
  final String id, categoryId, name;
  final String? imageUrl;
  final int sortOrder;
  MenuItem({required this.id, required this.categoryId, required this.name, this.imageUrl, this.sortOrder = 0});
}
