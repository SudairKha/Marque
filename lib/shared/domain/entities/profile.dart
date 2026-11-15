class Profile {
  final String id;
  final String? fullName, email, phone, avatarUrl, address;
  final String activeMode;
  final bool isAdmin;
  Profile({required this.id, this.fullName, this.email, this.phone,
    this.avatarUrl, this.address, this.activeMode = 'customer', this.isAdmin = false});
  String get firstName => (fullName ?? email ?? 'there').split(' ').first;
}
