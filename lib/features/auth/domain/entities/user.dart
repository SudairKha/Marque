import '../../../../shared/domain/entities/profile.dart';

class User {
  final String id;
  final String email;
  final Profile profile;
  User({required this.id, required this.email, required this.profile});
}
