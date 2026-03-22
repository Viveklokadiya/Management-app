import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../services/location_service.dart';
import '../theme/app_text_styles.dart';

/// Persistent amber banner shown when location permission is denied.
/// Displayed at the top of shells. Dismissible per session.
class LocationPermissionBanner extends ConsumerStatefulWidget {
  const LocationPermissionBanner({super.key});

  @override
  ConsumerState<LocationPermissionBanner> createState() =>
      _LocationPermissionBannerState();
}

class _LocationPermissionBannerState
    extends ConsumerState<LocationPermissionBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final status = ref.watch(locationStatusNotifierProvider);
    if (status == null ||
        status == LocationStatus.granted) {
      return const SizedBox.shrink();
    }

    final (icon, message) = switch (status) {
      LocationStatus.deniedForever => (
          Icons.location_off,
          'Location permanently denied. Enable in Settings to allow site tracking.',
        ),
      LocationStatus.disabled => (
          Icons.location_disabled,
          'Location services are off. Enable GPS for site tracking.',
        ),
      _ => (
          Icons.location_off_outlined,
          'Location permission denied. Tap to retry — location helps track site visits.',
        ),
    };

    return Material(
      color: const Color(0xFFFFF3CD),
      child: InkWell(
        onTap: status == LocationStatus.deniedForever
            ? () => Geolocator.openAppSettings()
            : null,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 8,
            bottom: 10,
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF92400E), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF92400E),
                  ),
                ),
              ),
              // Dismiss button
              IconButton(
                icon: const Icon(Icons.close,
                    color: Color(0xFF92400E), size: 18),
                onPressed: () => setState(() => _dismissed = true),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mixin for shell State classes that need to trigger location capture on init
/// and then continue updating every [_updateInterval] while the app is open.
mixin LocationCaptureMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  static const _updateInterval = Duration(minutes: 2);
  Timer? _locationTimer;

  /// Call this from [initState] (inside a postFrameCallback so auth is ready).
  Future<void> captureLocation(String userId) async {
    // First capture immediately
    await _doCapture(userId);

    // Then schedule periodic updates (cancel any existing timer first)
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(_updateInterval, (_) async {
      // Re-read userId each tick in case the user changes (edge case)
      final currentUserId =
          ref.read(authStateProvider).value?.id ?? userId;
      await _doCapture(currentUserId);
    });
  }

  Future<void> _doCapture(String userId) async {
    final service = ref.read(locationServiceProvider);
    final notifier = ref.read(locationStatusNotifierProvider.notifier);
    final status = await service.captureAndStore(userId);
    notifier.setStatus(status);
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}
