import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> signIn(String email, String password);
  Future<void> signUp({required String email, required String password, required String fullName, required String phone, required String role});
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Future<User> switchMode(String mode);
}
