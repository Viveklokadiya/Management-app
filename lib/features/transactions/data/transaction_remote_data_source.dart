import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/audit_log_model.dart';
import '../domain/models/transaction_model.dart';

class TransactionRemoteDataSource {
  final FirebaseFirestore _db;
  TransactionRemoteDataSource(this._db);

  // Subcollection path: sites/{siteId}/transactions/{txnId}
  CollectionReference<Map<String, dynamic>> _txnCol(String siteId) =>
      _db.collection('sites').doc(siteId).collection('transactions');

  // Root flat mirror: transactions/{txnId}  — used for watchByUser (no index needed)
  CollectionReference<Map<String, dynamic>> get _rootTxnCol =>
      _db.collection('transactions');

  Stream<List<TransactionModel>> watchBySite(String siteId) => _txnCol(siteId)
      .snapshots()
      .map((snap) {
        final list = snap.docs.map(TransactionModel.fromFirestore).toList();
        list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        return list;
      });

  /// Query the flat root `transactions` collection by userId — no collectionGroup,
  /// no composite index required.
  Stream<List<TransactionModel>> watchByUser(String userId) => _rootTxnCol
      .where('createdByUserId', isEqualTo: userId)
      .snapshots()
      .map((snap) {
        final list = snap.docs.map(TransactionModel.fromFirestore).toList();
        list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        return list;
      });

  Future<String> create(TransactionModel txn) async {
    // Write to subcollection
    final ref = await _txnCol(txn.siteId).add(txn.toMap());
    // Mirror to root collection with same ID
    await _rootTxnCol.doc(ref.id).set(txn.toMap());
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
    final ref = _txnCol(txn.siteId).doc(txn.id);
    final before = await ref.get();
    final beforeData = before.data() ?? {};
    final updated = {...txn.toMap(), 'updatedAt': FieldValue.serverTimestamp()};
    await ref.update(updated);
    // Mirror to root collection
    await _rootTxnCol.doc(txn.id).update(updated);
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
    required String siteId,
    required String transactionId,
    required String userId,
    required String userName,
  }) async {
    final ref = _txnCol(siteId).doc(transactionId);
    final snap = await ref.get();
    final beforeData = snap.data() ?? {};
    await ref.delete();
    // Remove from root mirror too (ignore if missing)
    await _rootTxnCol.doc(transactionId).delete().catchError((_) {});
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

  Future<TransactionModel?> getById({
    required String siteId,
    required String transactionId,
  }) async {
    final doc = await _txnCol(siteId).doc(transactionId).get();
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
