import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);
  @override
  Future<User?> signIn(String email, String password) => remote.signIn(email, password);
  @override
  Future<void> signUp({required String email, required String password, required String fullName, required String phone, required String role}) =>
      remote.signUp(email: email, password: password, fullName: fullName, phone: phone, role: role);
  @override
  Future<void> signOut() => remote.signOut();
  @override
  Future<User?> getCurrentUser() => remote.getCurrentUser();
  @override
  Future<User> switchMode(String mode) => remote.switchMode(mode);
}
