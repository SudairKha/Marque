import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../shared/domain/entities/profile.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

final authRemoteDataSourceProvider = Provider((r) => AuthRemoteDataSource(r.read(supabaseProvider)));
final authRepositoryProvider = Provider((r) => AuthRepositoryImpl(r.read(authRemoteDataSourceProvider)));
final loginUseCaseProvider = Provider((r) => LoginUseCase(r.read(authRepositoryProvider)));
final signupUseCaseProvider = Provider((r) => SignupUseCase(r.read(authRepositoryProvider)));

final currentUserProvider = FutureProvider<User?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getCurrentUser();
});

final profileProvider = Provider<Profile?>((ref) {
  return ref.watch(currentUserProvider).valueOrNull?.profile;
});
