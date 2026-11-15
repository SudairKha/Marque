import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase implements UseCase<void, Map<String, String>> {
  final AuthRepository repository;
  SignupUseCase(this.repository);
  @override
  Future<void> call(Map<String, String> params) => repository.signUp(
    email: params['email']!, password: params['password']!,
    fullName: params['fullName']!, phone: params['phone']!, role: params['role']!);
}
