import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/toast.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final pass = TextEditingController();
  String role = 'customer';
  bool busy = false;

  @override
  void dispose() { name.dispose(); email.dispose(); phone.dispose(); pass.dispose(); super.dispose(); }

  Future<void> _signup() async {
    if ([name, email, phone, pass].any((c) => c.text.trim().isEmpty)) { showToast(context, 'Fill all fields', error: true); return; }
    if (pass.text.length < 6) { showToast(context, 'Password min 6 chars', error: true); return; }
    setState(() => busy = true);
    try {
      await ref.read(signupUseCaseProvider).call({
        'email': email.text.trim().toLowerCase(), 'password': pass.text,
        'fullName': name.text.trim(), 'phone': phone.text.trim(), 'role': role
      });
      if (mounted) { showToast(context, 'Account created!'); context.go('/login'); }
    } catch (e) {
      if (mounted) showToast(context, '$e', error: true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create Account')),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
      TextField(controller: name, decoration: const InputDecoration(hintText: 'Full Name', prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted))),
      const SizedBox(height: 12),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted))),
      const SizedBox(height: 12),
      TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone (+92...)', prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textMuted))),
      const SizedBox(height: 12),
      TextField(controller: pass, obscureText: true, decoration: const InputDecoration(hintText: 'Password (min 6)', prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted))),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(value: role, items: const [
        DropdownMenuItem(value: 'customer', child: Text('Customer (Book events)')),
        DropdownMenuItem(value: 'owner', child: Text('Owner (List marquees)')),
      ], onChanged: (v) => setState(() => role = v ?? 'customer'), decoration: const InputDecoration(prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textMuted))),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
        onPressed: busy ? null : _signup,
        child: busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
    ]))));
}
