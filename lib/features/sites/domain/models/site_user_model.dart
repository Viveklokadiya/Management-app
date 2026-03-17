import 'package:cloud_firestore/cloud_firestore.dart';

class SiteUserModel {
  final String id;
  final String siteId;
  final String userId;
  final String userName;    // denormalized for display
  final String userEmail;   // denormalized for display
  final DateTime assignedAt;
  final String assignedByUserId;

  const SiteUserModel({
    required this.id,
    required this.siteId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.assignedAt,
    required this.assignedByUserId,
  });

  factory SiteUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SiteUserModel(
      id: doc.id,
      siteId: data['siteId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userEmail: data['userEmail'] as String? ?? '',
      assignedAt:
          (data['assignedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedByUserId: data['assignedByUserId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'siteId': siteId,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'assignedAt': Timestamp.fromDate(assignedAt),
        'assignedByUserId': assignedByUserId,
      };
}
