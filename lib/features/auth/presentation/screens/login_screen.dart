import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/error_parser.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override ConsumerState<LoginScreen> createState() => _LoginState();
}
class _LoginState extends ConsumerState<LoginScreen> {
  final email = TextEditingController(); final pass = TextEditingController(); bool busy = false;
  Future<void> _login() async {
    if (email.text.trim().isEmpty || pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email and password required'), backgroundColor: AppColors.red));
      return;
    }
    setState(() => busy = true);
    try {
      await ref.read(supabaseProvider).auth.signInWithPassword(email: email.text.trim(), password: pass.text);
      if (mounted) context.go('/customer/home');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorParser.getMessage(e)), backgroundColor: AppColors.red));
    } finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 40),
      Center(child: RichText(text: TextSpan(style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary), children: const [TextSpan(text: 'Marquee'), TextSpan(text: 'Finder', style: TextStyle(color: AppColors.gold))]))),
      const SizedBox(height: 60),
      Text('Welcome Back!', textAlign: TextAlign.center, style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
      const SizedBox(height: 4), const Text('Login to continue', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
      const SizedBox(height: 30),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email Address', prefixIcon: Icon(Icons.email_outlined))),
      const SizedBox(height: 14),
      TextField(controller: pass, obscureText: true, decoration: const InputDecoration(hintText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: busy ? null : _login, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))), child: busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Login', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
      const SizedBox(height: 20),
      TextButton(onPressed: () => context.go('/signup'), child: const Text('No account? Register', style: TextStyle(fontSize: 13, color: AppColors.textMuted))),
    ]))));
  }
}

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override ConsumerState<SignupScreen> createState() => _SignupState();
}
class _SignupState extends ConsumerState<SignupScreen> {
  final name = TextEditingController(); final email = TextEditingController(); final phone = TextEditingController(); final pass = TextEditingController(); String role = 'customer'; bool busy = false;
  Future<void> _signup() async {
    if (name.text.trim().isEmpty || email.text.trim().isEmpty || pass.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.red)); return; }
    if (pass.text.length < 6) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: AppColors.red)); return; }
    setState(() => busy = true);
    try {
      final res = await ref.read(supabaseProvider).auth.signUp(email: email.text.trim(), password: pass.text, data: {'full_name': name.text.trim(), 'phone': phone.text.trim(), 'role': role, 'active_mode': role});
      if (res.session != null) {
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created successfully!'), backgroundColor: AppColors.green)); if (role == 'owner') { context.go('/owner/dashboard'); } else { context.go('/customer/home'); } }
      } else {
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please check your email to confirm your account.'), backgroundColor: AppColors.amber)); context.go('/login'); }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorParser.getMessage(e)), backgroundColor: AppColors.red));
    } finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [InkWell(onTap: () => context.go('/login'), child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.arrow_back, color: AppColors.primary, size: 20)))]),
      const SizedBox(height: 10),
      Center(child: RichText(text: TextSpan(style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary), children: const [TextSpan(text: 'Marquee'), TextSpan(text: 'Finder', style: TextStyle(color: AppColors.gold))]))),
      const SizedBox(height: 40),
      Text('Create Account', textAlign: TextAlign.center, style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
      const SizedBox(height: 4), const Text('Join MarqueeFinder', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
      const SizedBox(height: 30),
      TextField(controller: name, decoration: const InputDecoration(hintText: 'Full Name', prefixIcon: Icon(Icons.person_outline))),
      const SizedBox(height: 14),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
      const SizedBox(height: 14),
      TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone', prefixIcon: Icon(Icons.phone_outlined))),
      const SizedBox(height: 14),
      TextField(controller: pass, obscureText: true, decoration: const InputDecoration(hintText: 'Password (min 6)', prefixIcon: Icon(Icons.lock_outline))),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(value: role, items: const [DropdownMenuItem(value: 'customer', child: Text('Customer (Book events)')), DropdownMenuItem(value: 'owner', child: Text('Owner (List marquees)'))], onChanged: (v) => setState(() => role = v ?? 'customer'), decoration: const InputDecoration(labelText: 'I want to join as:', border: OutlineInputBorder())),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: busy ? null : _signup, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))), child: busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
      const SizedBox(height: 20),
      TextButton(onPressed: () => context.go('/login'), child: const Text('Already have an account? Login', style: TextStyle(fontSize: 13, color: AppColors.textMuted))),
    ]))));
  }
}
