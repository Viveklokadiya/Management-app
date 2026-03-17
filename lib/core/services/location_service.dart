import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

/// Status of location permission + availability.
enum LocationStatus { granted, denied, deniedForever, disabled }

class LocationService {
  final FirebaseFirestore _db;
  LocationService(this._db);

  /// Request permission and capture location, then write to user doc.
  /// Returns [LocationStatus] so callers can react (e.g., show a banner).
  Future<LocationStatus> captureAndStore(String userId) async {
    // 1. Check service enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationStatus.disabled;

    // 2. Check / request permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return LocationStatus.denied;
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationStatus.deniedForever;
    }

    // 3. Get position
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Write to user doc (user doc only — per decision)
      await _db.collection('users').doc(userId).update({
        'lastLatitude': pos.latitude,
        'lastLongitude': pos.longitude,
        'lastLocationAt': FieldValue.serverTimestamp(),
      });

      return LocationStatus.granted;
    } catch (_) {
      return LocationStatus.granted; // permission was granted; silent position error
    }
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

@riverpod
LocationService locationService(LocationServiceRef ref) {
  return LocationService(FirebaseFirestore.instance);
}

/// Tracks the location capture result for the current session.
/// Riverpod state so shells and widgets can react to it.
@riverpod
class LocationStatusNotifier extends _$LocationStatusNotifier {
  @override
  LocationStatus? build() => null; // null = not yet checked

  void setStatus(LocationStatus status) => state = status;
}
