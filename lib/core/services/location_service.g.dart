// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$locationServiceHash() => r'b5f07cb67e7fdc18ad2f353eba8a3c0e34650555';

/// See also [locationService].
@ProviderFor(locationService)
final locationServiceProvider = AutoDisposeProvider<LocationService>.internal(
  locationService,
  name: r'locationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationServiceRef = AutoDisposeProviderRef<LocationService>;
String _$locationStatusNotifierHash() =>
    r'5ec69551d27dd6534fd4f402a6eb88d182ad6834';

/// Tracks the location capture result for the current session.
/// Riverpod state so shells and widgets can react to it.
///
/// Copied from [LocationStatusNotifier].
@ProviderFor(LocationStatusNotifier)
final locationStatusNotifierProvider = AutoDisposeNotifierProvider<
    LocationStatusNotifier, LocationStatus?>.internal(
  LocationStatusNotifier.new,
  name: r'locationStatusNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationStatusNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocationStatusNotifier = AutoDisposeNotifier<LocationStatus?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
