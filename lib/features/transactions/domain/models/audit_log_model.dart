import 'package:cloud_firestore/cloud_firestore.dart';

enum AuditAction { create, update, delete }

class AuditLogModel {
  final String id;
  final String entityType; // 'transaction' | 'site' | 'user'
  final String entityId;
  final AuditAction action;
  final String performedByUserId;
  final String performedByName;
  final Map<String, dynamic> before; // snapshot before change (empty for create)
  final Map<String, dynamic> after;  // snapshot after change (empty for delete)
  final DateTime createdAt;

  const AuditLogModel({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.performedByUserId,
    required this.performedByName,
    required this.before,
    required this.after,
    required this.createdAt,
  });

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AuditLogModel(
      id: doc.id,
      entityType: data['entityType'] as String? ?? '',
      entityId: data['entityId'] as String? ?? '',
      action: _parseAction(data['action'] as String?),
      performedByUserId: data['performedByUserId'] as String? ?? '',
      performedByName: data['performedByName'] as String? ?? '',
      before: Map<String, dynamic>.from(data['before'] as Map? ?? {}),
      after: Map<String, dynamic>.from(data['after'] as Map? ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'entityType': entityType,
        'entityId': entityId,
        'action': action.name,
        'performedByUserId': performedByUserId,
        'performedByName': performedByName,
        'before': before,
        'after': after,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static AuditAction _parseAction(String? val) => switch (val) {
        'update' => AuditAction.update,
        'delete' => AuditAction.delete,
        _ => AuditAction.create,
      };
}
