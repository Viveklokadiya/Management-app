---
description: "Domain models: TransactionModel, AuditLogModel, SiteModel, SiteUserModel with Firestore serialization"
dependencies: []
gap_closure: false
wave: 1
---

# Phase 4: Firestore Schema & Repositories — Plan 1 (Domain Models)

## 1. TransactionModel
<task>
<read_first>
- lib/features/auth/domain/models/app_user.dart
- .planning/ROADMAP.md (Phase 4 Collections section)
</read_first>
<action>
Create `lib/features/transactions/domain/models/transaction_model.dart`.

Firestore collection: `transactions` (subcollection under `sites/{siteId}/transactions`)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

enum PaymentMethod { cash, upi, bank, other }

class TransactionModel {
  final String id;
  final String siteId;
  final String createdByUserId;       // partner user id
  final String createdByName;         // partner name (denormalized)
  final TransactionType type;         // income | expense
  final int amountPaise;              // stored as paise (multiply rupees × 100)
  final PaymentMethod paymentMethod;
  final String? remarks;
  final double? latitude;
  final double? longitude;
  final DateTime transactionDate;     // date entered by user (may differ from createdAt)
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.siteId,
    required this.createdByUserId,
    required this.createdByName,
    required this.type,
    required this.amountPaise,
    required this.paymentMethod,
    this.remarks,
    this.latitude,
    this.longitude,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TransactionModel(
      id: doc.id,
      siteId: data['siteId'] ?? '',
      createdByUserId: data['createdByUserId'] ?? '',
      createdByName: data['createdByName'] ?? '',
      type: data['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      amountPaise: (data['amountPaise'] as num?)?.toInt() ?? 0,
      paymentMethod: _parsePaymentMethod(data['paymentMethod']),
      remarks: data['remarks'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      transactionDate: (data['transactionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'siteId': siteId,
    'createdByUserId': createdByUserId,
    'createdByName': createdByName,
    'type': type.name,
    'amountPaise': amountPaise,
    'paymentMethod': paymentMethod.name,
    'remarks': remarks,
    'latitude': latitude,
    'longitude': longitude,
    'transactionDate': Timestamp.fromDate(transactionDate),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  // Convenience: get amount in rupees (double)
  double get amountRupees => amountPaise / 100.0;

  static PaymentMethod _parsePaymentMethod(String? val) => switch (val) {
    'upi' => PaymentMethod.upi,
    'bank' => PaymentMethod.bank,
    'other' => PaymentMethod.other,
    _ => PaymentMethod.cash,
  };

  TransactionModel copyWith({
    String? id,
    String? siteId,
    String? createdByUserId,
    String? createdByName,
    TransactionType? type,
    int? amountPaise,
    PaymentMethod? paymentMethod,
    String? remarks,
    double? latitude,
    double? longitude,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TransactionModel(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    createdByUserId: createdByUserId ?? this.createdByUserId,
    createdByName: createdByName ?? this.createdByName,
    type: type ?? this.type,
    amountPaise: amountPaise ?? this.amountPaise,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    remarks: remarks ?? this.remarks,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    transactionDate: transactionDate ?? this.transactionDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
```
</action>
<acceptance_criteria>
- `lib/features/transactions/domain/models/transaction_model.dart` exists
- Contains enums `TransactionType` (income, expense) and `PaymentMethod` (cash, upi, bank, other)
- `fromFirestore` parses all fields including Timestamps
- `toMap()` round-trips: `TransactionModel.fromFirestore(doc).toMap()` produces same keys
- `amountPaise` field used (not double) — no floating point currency
- `amountRupees` getter returns `amountPaise / 100.0`
</acceptance_criteria>
</task>

## 2. AuditLogModel
<task>
<read_first>
- lib/features/transactions/domain/models/transaction_model.dart
</read_first>
<action>
Create `lib/features/transactions/domain/models/audit_log_model.dart`.

Firestore collection: `audit_logs` (top-level, write-only)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuditAction { create, update, delete }

class AuditLogModel {
  final String id;
  final String entityType;      // 'transaction' | 'site' | 'user'
  final String entityId;
  final AuditAction action;
  final String performedByUserId;
  final String performedByName;
  final Map<String, dynamic> before;   // snapshot before change (empty for create)
  final Map<String, dynamic> after;    // snapshot after change (empty for delete)
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
      entityType: data['entityType'] ?? '',
      entityId: data['entityId'] ?? '',
      action: _parseAction(data['action']),
      performedByUserId: data['performedByUserId'] ?? '',
      performedByName: data['performedByName'] ?? '',
      before: Map<String, dynamic>.from(data['before'] ?? {}),
      after: Map<String, dynamic>.from(data['after'] ?? {}),
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
```
</action>
<acceptance_criteria>
- `lib/features/transactions/domain/models/audit_log_model.dart` exists
- `AuditAction` enum has create, update, delete
- `before` and `after` are `Map<String, dynamic>` fields
- `fromFirestore` and `toMap` present
</acceptance_criteria>
</task>

## 3. SiteModel
<task>
<read_first>
- lib/features/auth/domain/models/app_user.dart
</read_first>
<action>
Create `lib/features/sites/domain/models/site_model.dart`.

Firestore collection: `sites`

```dart
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
      name: data['name'] ?? '',
      address: data['address'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      isActive: data['isActive'] ?? true,
      createdByUserId: data['createdByUserId'] ?? '',
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
  }) => SiteModel(
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
```
</action>
<acceptance_criteria>
- `lib/features/sites/domain/models/site_model.dart` exists
- `isActive` defaults to `true` in `fromFirestore`
- `fromFirestore` and `toMap` are symmetric for all fields
- `copyWith` present
</acceptance_criteria>
</task>

## 4. SiteUserModel
<task>
<read_first>
- lib/features/sites/domain/models/site_model.dart
</read_first>
<action>
Create `lib/features/sites/domain/models/site_user_model.dart`.

Firestore collection: `site_users` — join table between sites and users (partner assignments)

```dart
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
      siteId: data['siteId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      assignedAt: (data['assignedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedByUserId: data['assignedByUserId'] ?? '',
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
```
</action>
<acceptance_criteria>
- `lib/features/sites/domain/models/site_user_model.dart` exists
- Contains `siteId` and `userId` fields (the join keys)
- Denormalized `userName` and `userEmail` present for display
- `fromFirestore` and `toMap` are symmetric
</acceptance_criteria>
</task>
