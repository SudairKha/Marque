import '../../domain/entities/user.dart';
import '../../../../shared/domain/entities/profile.dart';

class UserModel extends User {
  UserModel({required super.id, required super.email, required super.profile});

  factory UserModel.fromJson(Map<String, dynamic> j, Map<String, dynamic> profileJson) => UserModel(
    id: j['id'],
    email: j['email'] ?? '',
    profile: Profile(
      id: profileJson['id'], fullName: profileJson['full_name'], email: profileJson['email'],
      phone: profileJson['phone'], avatarUrl: profileJson['avatar_url'], address: profileJson['address'],
      activeMode: profileJson['active_mode'] ?? 'customer', isAdmin: profileJson['is_admin'] == true,
    ),
  );
}
