import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class AdminLandingScreen extends ConsumerStatefulWidget {
  const AdminLandingScreen({super.key});
  @override
  ConsumerState<AdminLandingScreen> createState() => _State();
}

class _State extends ConsumerState<AdminLandingScreen> {
  bool busy = false;

  Future<void> _changeImage(int pos, Map<String, dynamic>? existing) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Upload Image?'),
      content: Text('Are you sure you want to replace Image $pos?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Upload')),
      ],
    ));
    if (confirm != true) return;

    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => busy = true);
    try {
      final bytes = await file.readAsBytes();
      final path = 'landing/img-$pos-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final sb = ref.read(supabaseProvider);
      
      await sb.storage.from('marquee-images').uploadBinary(path, bytes);
      final url = sb.storage.from('marquee-images').getPublicUrl(path);
      
      if (existing != null) {
        await sb.from('landing_images').update({'image_url': url}).eq('position', pos);
      } else {
        await sb.from('landing_images').insert({'position': pos, 'image_url': url});
      }
      
      ref.invalidate(adminLandingImagesProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image updated successfully!'), backgroundColor: AppColors.green));
    } catch (e) {
      debugPrint('DB Error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload image. Check your connection.'), backgroundColor: AppColors.red));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminLandingImagesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? 280.0 : screenWidth * 0.85; // Responsive width

    return Stack(children: [
      async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => const Center(child: Text('Could not load images. Please try again later.')),
        data: (images) {
          final byPos = {for (var im in images) im['position'] as int: im};
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center, // CENTERS the items
                spacing: 16, 
                runSpacing: 16, 
                children: [1, 2, 3].map((pos) {
                  final img = byPos[pos];
                  return SizedBox(
                    width: cardWidth,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                      child: Column(children: [
                        Container(
                          padding: const EdgeInsets.all(10), 
                          decoration: const BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.vertical(top: Radius.circular(14))), 
                          child: Row(children: [
                            const Icon(Icons.image, size: 16, color: AppColors.primary), 
                            const SizedBox(width: 8), 
                            Text('Image $pos', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary))
                          ])
                        ),
                        Container(
                          height: 140, 
                          width: double.infinity, 
                          decoration: BoxDecoration(
                            color: AppColors.soft, 
                            image: img != null && img['image_url'] != null ? DecorationImage(image: NetworkImage(img['image_url']), fit: BoxFit.cover) : null
                          ), 
                          child: img == null || img['image_url'] == null ? const Center(child: Icon(Icons.image, color: AppColors.border, size: 40)) : null
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12), 
                          child: SizedBox(
                            width: double.infinity, 
                            child: ElevatedButton.icon(
                              onPressed: () => _changeImage(pos, img),
                              icon: const Icon(Icons.edit, size: 14), 
                              label: const Text('Change Image'), 
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                            )
                          )
                        ),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      if (busy) Positioned.fill(child: Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: AppColors.primary)))),
    ]);
  }
}
