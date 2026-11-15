import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<User?, Map<String, String>> {
  final AuthRepository repository;
  LoginUseCase(this.repository);
  @override
  Future<User?> call(Map<String, String> params) => repository.signIn(params['email']!, params['password']!);
}
