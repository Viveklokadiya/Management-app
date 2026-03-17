import 'package:cloud_firestore/cloud_firestore.dart';

class SiteModel {
  final String id;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final bool isActive;
  final String createdByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SiteModel({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.state,
    required this.isActive,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SiteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SiteModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdByUserId: data['createdByUserId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'city': city,
        'state': state,
        'isActive': isActive,
        'createdByUserId': createdByUserId,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  SiteModel copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? state,
    bool? isActive,
    String? createdByUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      SiteModel(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        city: city ?? this.city,
        state: state ?? this.state,
        isActive: isActive ?? this.isActive,
        createdByUserId: createdByUserId ?? this.createdByUserId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
