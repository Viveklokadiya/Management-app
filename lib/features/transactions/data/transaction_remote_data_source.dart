import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/audit_log_model.dart';
import '../domain/models/transaction_model.dart';

class TransactionRemoteDataSource {
  final FirebaseFirestore _db;
  TransactionRemoteDataSource(this._db);

  // Single root collection — no dual-write, no subcollection
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('transactions');

  /// Real-time stream of all transactions for a specific site (by siteId field)
  Stream<List<TransactionModel>> watchBySite(String siteId) => _col
      .where('siteId', isEqualTo: siteId)
      .snapshots()
      .map((snap) {
        final list = snap.docs.map(TransactionModel.fromFirestore).toList();
        list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        return list;
      });

  /// Real-time stream of all transactions created by a specific user
  Stream<List<TransactionModel>> watchByUser(String userId) => _col
      .where('createdByUserId', isEqualTo: userId)
      .snapshots()
      .map((snap) {
        final list = snap.docs.map(TransactionModel.fromFirestore).toList();
        list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        return list;
      });

  /// Real-time stream of ALL transactions (admin view)
  Stream<List<TransactionModel>> watchAll() => _col
      .snapshots()
      .map((snap) {
        final list = snap.docs.map(TransactionModel.fromFirestore).toList();
        list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        return list;
      });

  Future<String> create(TransactionModel txn) async {
    final ref = await _col.add(txn.toMap());
    await _writeAuditLog(
      entityType: 'transaction',
      entityId: ref.id,
      action: AuditAction.create,
      performedByUserId: txn.createdByUserId,
      performedByName: txn.createdByName,
      before: {},
      after: txn.toMap(),
    );
    return ref.id;
  }

  Future<void> update(TransactionModel txn) async {
    final ref = _col.doc(txn.id);
    final before = await ref.get();
    final beforeData = before.data() ?? {};
    final updated = {...txn.toMap(), 'updatedAt': FieldValue.serverTimestamp()};
    await ref.update(updated);
    await _writeAuditLog(
      entityType: 'transaction',
      entityId: txn.id,
      action: AuditAction.update,
      performedByUserId: txn.createdByUserId,
      performedByName: txn.createdByName,
      before: beforeData,
      after: txn.toMap(),
    );
  }

  Future<void> delete({
    required String transactionId,
    required String userId,
    required String userName,
  }) async {
    final ref = _col.doc(transactionId);
    final snap = await ref.get();
    final beforeData = snap.data() ?? {};
    await ref.delete();
    await _writeAuditLog(
      entityType: 'transaction',
      entityId: transactionId,
      action: AuditAction.delete,
      performedByUserId: userId,
      performedByName: userName,
      before: beforeData,
      after: {},
    );
  }

  Future<TransactionModel?> getById(String transactionId) async {
    final doc = await _col.doc(transactionId).get();
    return doc.exists ? TransactionModel.fromFirestore(doc) : null;
  }

  Future<void> _writeAuditLog({
    required String entityType,
    required String entityId,
    required AuditAction action,
    required String performedByUserId,
    required String performedByName,
    required Map<String, dynamic> before,
    required Map<String, dynamic> after,
  }) {
    return _db.collection('audit_logs').add(
      AuditLogModel(
        id: '',
        entityType: entityType,
        entityId: entityId,
        action: action,
        performedByUserId: performedByUserId,
        performedByName: performedByName,
        before: before,
        after: after,
        createdAt: DateTime.now(),
      ).toMap(),
    );
  }
}
