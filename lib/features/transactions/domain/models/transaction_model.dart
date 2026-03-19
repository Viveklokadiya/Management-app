import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

enum PaymentMethod { cash, upi, bank, other }

class TransactionModel {
  final String id;
  final String siteId;
  final String createdByUserId;
  final String createdByName;
  final TransactionType type;
  final int amountPaise; // stored as paise (rupees × 100)
  final PaymentMethod paymentMethod;
  final String? projectName;
  final String? clientName;
  final String? remarks;
  final double? latitude;
  final double? longitude;
  final DateTime transactionDate;
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
    this.projectName,
    this.clientName,
    this.remarks,
    this.latitude,
    this.longitude,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convenience getter — amount in rupees (double)
  double get amountRupees => amountPaise / 100.0;

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TransactionModel(
      id: doc.id,
      siteId: data['siteId'] as String? ?? '',
      createdByUserId: data['createdByUserId'] as String? ?? '',
      createdByName: data['createdByName'] as String? ?? '',
      type: data['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amountPaise: (data['amountPaise'] as num?)?.toInt() ?? 0,
      paymentMethod: _parsePaymentMethod(data['paymentMethod'] as String?),
      projectName: data['projectName'] as String?,
      clientName: data['clientName'] as String?,
      remarks: data['remarks'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      transactionDate:
          (data['transactionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'siteId': siteId,
        'createdByUserId': createdByUserId,
        'createdByName': createdByName,
        'type': type.name,
        'amountPaise': amountPaise,
        'paymentMethod': paymentMethod.name,
        'projectName': projectName,
        'clientName': clientName,
        'remarks': remarks,
        'latitude': latitude,
        'longitude': longitude,
        'transactionDate': Timestamp.fromDate(transactionDate),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

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
    String? projectName,
    String? clientName,
    String? remarks,
    double? latitude,
    double? longitude,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      TransactionModel(
        id: id ?? this.id,
        siteId: siteId ?? this.siteId,
        createdByUserId: createdByUserId ?? this.createdByUserId,
        createdByName: createdByName ?? this.createdByName,
        type: type ?? this.type,
        amountPaise: amountPaise ?? this.amountPaise,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        projectName: projectName ?? this.projectName,
        clientName: clientName ?? this.clientName,
        remarks: remarks ?? this.remarks,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        transactionDate: transactionDate ?? this.transactionDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
