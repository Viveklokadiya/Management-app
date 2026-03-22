import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { superAdmin, admin, partner }

class AppUser {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final bool isActive;
  final String? photoBase64; // compressed jpeg stored in Firestore
  final double? lastLatitude;
  final double? lastLongitude;
  final DateTime? lastLocationAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    required this.isActive,
    this.photoBase64,
    this.lastLatitude,
    this.lastLongitude,
    this.lastLocationAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = {};
    if (doc.data() != null) {
      data = doc.data() as Map<String, dynamic>;
    }

    UserRole parsedRole = UserRole.partner;
    final roleStr = data['role'] as String?;
    if (roleStr == 'superAdmin' || roleStr == 'super_admin') {
      parsedRole = UserRole.superAdmin;
    } else if (roleStr == 'admin') {
      parsedRole = UserRole.admin;
    }

    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'],
      role: parsedRole,
      isActive: data['isActive'] ?? false,
      photoBase64: data['photoBase64'] as String?,
      lastLatitude: (data['lastLatitude'] as num?)?.toDouble(),
      lastLongitude: (data['lastLongitude'] as num?)?.toDouble(),
      lastLocationAt: (data['lastLocationAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'isActive': isActive,
      // photoBase64 is updated separately via updatePhotoBase64()
      'lastLatitude': lastLatitude,
      'lastLongitude': lastLongitude,
      'lastLocationAt': lastLocationAt != null
          ? Timestamp.fromDate(lastLocationAt!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    bool? isActive,
    String? photoBase64,
    double? lastLatitude,
    double? lastLongitude,
    DateTime? lastLocationAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      photoBase64: photoBase64 ?? this.photoBase64,
      lastLatitude: lastLatitude ?? this.lastLatitude,
      lastLongitude: lastLongitude ?? this.lastLongitude,
      lastLocationAt: lastLocationAt ?? this.lastLocationAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
