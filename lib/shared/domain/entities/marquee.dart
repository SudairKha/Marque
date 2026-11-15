class Marquee {
  final String id, ownerId, name, location, whatsapp, status;
  final String? coverImage, description;
  final num price;
  final int capacity;
  Marquee({required this.id, required this.ownerId, required this.name,
    required this.location, required this.whatsapp, required this.status,
    this.coverImage, this.description, required this.price, required this.capacity});
}
