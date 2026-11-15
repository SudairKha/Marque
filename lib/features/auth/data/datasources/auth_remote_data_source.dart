import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final SupabaseClient sb;
  AuthRemoteDataSource(this.sb);

  Future<UserModel?> signIn(String email, String password) async {
    final r = await sb.auth.signInWithPassword(email: email, password: password);
    if (r.session == null) return null;
    final p = await sb.from('profiles').select().eq('id', r.user!.id).single();
    return UserModel.fromJson(r.user!.toJson(), p);
  }

  Future<void> signUp({required String email, required String password, required String fullName, required String phone, required String role}) async {
    await sb.auth.signUp(email: email, password: password, data: {'full_name': fullName, 'phone': phone, 'role': role});
  }

  Future<void> signOut() => sb.auth.signOut();

  Future<UserModel?> getCurrentUser() async {
    final u = sb.auth.currentUser;
    if (u == null) return null;
    final p = await sb.from('profiles').select().eq('id', u.id).single();
    return UserModel.fromJson(u.toJson(), p);
  }

  Future<UserModel> switchMode(String mode) async {
    final r = await sb.rpc('switch_mode', params: {'p_mode': mode});
    final u = sb.auth.currentUser!;
    return UserModel.fromJson(u.toJson(), r as Map<String, dynamic>);
  }
}
