import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final _profileFutureProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final sb = ref.read(supabaseProvider);
  final user = sb.auth.currentUser;
  if (user == null) return null;
  try {
    final row = await sb.from('profiles').select().eq('id', user.id).single();
    return row;
  } catch (_) {
    return null;
  }
});

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(_profileFutureProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: asyncProfile.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (p) {
            if (p == null) return const Center(child: Text('Not logged in'));
            
            final fullName = p['full_name'] as String? ?? 'User';
            final email = p['email'] as String? ?? '';
            final avatarUrl = p['avatar_url'] as String?;
            final isAdmin = p['is_admin'] == true;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const SizedBox(width: 30),
                  Expanded(child: Center(child: RichText(text: TextSpan(style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary), children: const [TextSpan(text: 'Marquee'), TextSpan(text: 'Finder', style: TextStyle(color: AppColors.gold))])))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.person_outline, size: 12, color: AppColors.primary), SizedBox(width: 6), Text('Customer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary))])),
                ]),
                const SizedBox(height: 14),
                Text('Profile', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 4), const Text('Manage your account', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                const SizedBox(height: 14),
                Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFEEF6F0), Color(0xFFD5E9DF)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)), child: Column(children: [
                  CircleAvatar(radius: 40, backgroundColor: AppColors.primary, backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null, child: avatarUrl == null ? Text(initials(fullName), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)) : null),
                  const SizedBox(height: 12),
                  Text(fullName, style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 4), Text(email, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), child: const Text('Customer', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700))),
                ])),
                const SizedBox(height: 14),
                Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Column(children: [
                  _tile(Icons.edit, 'Edit Profile', () => _editProfile(context, ref, p)),
                  _divider(),
                  _tile(Icons.store, 'Switch to Owner Mode', () async { try { await ref.read(authRepositoryProvider).switchMode('owner'); ref.invalidate(currentUserProvider); if (context.mounted) context.go('/owner/dashboard'); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.red)); } }),
                  if (isAdmin) ...[
                    _divider(),
                    _tile(Icons.shield, 'Switch to Admin Mode', () async { try { await ref.read(authRepositoryProvider).switchMode('admin'); ref.invalidate(currentUserProvider); if (context.mounted) context.go('/admin/dashboard'); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.red)); } }),
                  ],
                  _divider(),
                  _tile(Icons.logout, 'Logout', () async { await ref.read(authRepositoryProvider).signOut(); if (context.mounted) context.go('/login'); }, color: AppColors.red),
                ])),
              ]),
            );
          },
        ),
      ),
    );
  }
  Widget _divider() => const Divider(height: 1, color: AppColors.border);
  Widget _tile(IconData ic, String label, VoidCallback onTap, {Color? color}) => ListTile(leading: Icon(ic, color: color ?? AppColors.primary, size: 17), title: Text(label, style: TextStyle(color: color ?? AppColors.text, fontWeight: FontWeight.w500, fontSize: 13.5)), trailing: const Icon(Icons.chevron_right, size: 12, color: AppColors.textMuted), onTap: onTap);
  
  void _editProfile(BuildContext context, WidgetRef ref, Map<String, dynamic> p) {
    final nameCtrl = TextEditingController(text: p['full_name']);
    final phoneCtrl = TextEditingController(text: p['phone']);
    final addrCtrl = TextEditingController(text: p['address']);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')), const SizedBox(height: 10), TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')), const SizedBox(height: 10), TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Address')), const SizedBox(height: 10), const Text('Profile picture can only be changed by Admin.', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted))])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () async { await ref.read(supabaseProvider).from('profiles').update({'full_name': nameCtrl.text.trim(), 'phone': phoneCtrl.text.trim(), 'address': addrCtrl.text.trim()}).eq('id', p['id']); ref.invalidate(_profileFutureProvider); if (ctx.mounted) Navigator.pop(ctx); }, child: const Text('Save'))],
    ));
  }
}
