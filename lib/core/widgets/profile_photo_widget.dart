import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/auth/domain/models/app_user.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─── Photo picker helper ───────────────────────────────────────────────────────

class PhotoPickerService {
  static final _picker = ImagePicker();

  /// Pick photo from [source], compress to 200×200 JPEG quality 65,
  /// and return as a Base64 string. Returns null if cancelled or error.
  static Future<String?> pickAndEncode(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (xFile == null) return null;

      final bytes = await xFile.readAsBytes();

      // Compress to ≤200×200px, quality 65 → typically 8–20 KB
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 200,
        minHeight: 200,
        quality: 65,
        format: CompressFormat.jpeg,
      );

      return base64Encode(compressed);
    } catch (_) {
      return null;
    }
  }
}

// ─── Profile photo widget ──────────────────────────────────────────────────────

/// Displays the user's profile photo or their initials if no photo exists.
/// Shows a camera-badge overlay on the bottom-right when [onTap] is provided.
class ProfilePhotoWidget extends StatelessWidget {
  const ProfilePhotoWidget({
    super.key,
    required this.user,
    this.radius = 44,
    this.onTap,
    this.foregroundColor = Colors.white,
    this.backgroundColor,
    this.isLoading = false,
  });

  final AppUser user;
  final double radius;
  final VoidCallback? onTap;
  final Color foregroundColor;
  final Color? backgroundColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.white.withValues(alpha: 0.2);
    final photo = _decodePhoto(user.photoBase64);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: bgColor,
            backgroundImage: photo != null ? MemoryImage(photo) : null,
            child: isLoading
                ? SizedBox(
                    width: radius,
                    height: radius,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foregroundColor,
                    ),
                  )
                : photo == null
                    ? Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : '?',
                        style: AppTextStyles.amountLarge
                            .copyWith(color: foregroundColor),
                      )
                    : null,
          ),
          if (onTap != null && !isLoading)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: radius * 0.55,
                height: radius * 0.55,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: radius * 0.28,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Uint8List? _decodePhoto(String? base64) {
    if (base64 == null || base64.isEmpty) return null;
    try {
      return base64Decode(base64);
    } catch (_) {
      return null;
    }
  }
}

// ─── Source picker bottom sheet ────────────────────────────────────────────────

Future<void> showPhotoSourceSheet({
  required BuildContext context,
  required Future<void> Function(ImageSource) onSourceSelected,
}) async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Change Profile Photo',
                style: AppTextStyles.headlineSmall),
            const SizedBox(height: 20),
            Row(
              children: [
                _SourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(ctx);
                    onSourceSelected(ImageSource.camera);
                  },
                ),
                const SizedBox(width: 16),
                _SourceOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(ctx);
                    onSourceSelected(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 32),
              const SizedBox(height: 8),
              Text(label,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
