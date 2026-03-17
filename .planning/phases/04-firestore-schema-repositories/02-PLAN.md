---
description: "Repository interfaces, implementations, remote data sources, and Riverpod providers for transactions, sites, and users"
dependencies: ["01-PLAN.md"]
gap_closure: false
wave: 2
---

# Phase 4: Firestore Schema & Repositories — Plan 2 (Repositories & Providers)

## 1. Transaction Repository Interface
<task>
<read_first>
- lib/features/transactions/domain/models/transaction_model.dart
</read_first>
<action>
Create `lib/features/transactions/domain/repositories/transaction_repository.dart`.

```dart
import '../models/transaction_model.dart';

abstract class TransactionRepository {
  /// Stream of transactions for a specific site (real-time)
  Stream<List<TransactionModel>> getTransactionsForSite(String siteId);

  /// Stream of transactions created by a specific user across all their sites
  Stream<List<TransactionModel>> getTransactionsByUser(String userId);

  /// Create a new transaction, returns the created document ID
  Future<String> createTransaction(TransactionModel transaction);

  /// Update an existing transaction (admin only)
  Future<void> updateTransaction(TransactionModel transaction);

  /// Delete a transaction (admin only)
  Future<void> deleteTransaction({required String siteId, required String transactionId});

  /// Get a single transaction by ID
  Future<TransactionModel?> getTransactionById({required String siteId, required String transactionId});
}
```
</action>
<acceptance_criteria>
- `lib/features/transactions/domain/repositories/transaction_repository.dart` exists
- `abstract class TransactionRepository` defined
- `getTransactionsForSite` returns `Stream<List<TransactionModel>>`
- `createTransaction` returns `Future<String>` (the new doc ID)
</acceptance_criteria>
</task>

## 2. Transaction Remote Data Source
<task>
<read_first>
- lib/features/transactions/domain/models/transaction_model.dart
- lib/features/transactions/domain/models/audit_log_model.dart
</read_first>
<action>
Create `lib/features/transactions/data/transaction_remote_data_source.dart`.

Firestore path: `sites/{siteId}/transactions` (subcollection).

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/transaction_model.dart';
import '../domain/models/audit_log_model.dart';

class TransactionRemoteDataSource {
  final FirebaseFirestore _db;
  TransactionRemoteDataSource(this._db);

  CollectionReference<Map<String, dynamic>> _txnCol(String siteId) =>
      _db.collection('sites').doc(siteId).collection('transactions');

  Stream<List<TransactionModel>> watchBySite(String siteId) =>
      _txnCol(siteId)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TransactionModel.fromFirestore).toList());

  Stream<List<TransactionModel>> watchByUser(String userId) =>
      _db.collectionGroup('transactions')
        .where('createdByUserId', isEqualTo: userId)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TransactionModel.fromFirestore).toList());

  Future<String> create(TransactionModel txn) async {
    final ref = await _txnCol(txn.siteId).add(txn.toMap());
    // Write audit log
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
    await ref.update({...txn.toMap(), 'updatedAt': FieldValue.serverTimestamp()});
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

  Future<void> delete({required String siteId, required String transactionId, required String userId, required String userName}) async {
    final ref = _txnCol(siteId).doc(transactionId);
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

  Future<TransactionModel?> getById({required String siteId, required String transactionId}) async {
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
```
</action>
<acceptance_criteria>
- `lib/features/transactions/data/transaction_remote_data_source.dart` exists
- Transactions stored at `sites/{siteId}/transactions` subcollection
- `create()` also writes to `audit_logs` collection
- `watchBySite` and `watchByUser` return Streams (not Futures)
</acceptance_criteria>
</task>

## 3. Transaction Repository Implementation
<task>
<read_first>
- lib/features/transactions/domain/repositories/transaction_repository.dart
- lib/features/transactions/data/transaction_remote_data_source.dart
</read_first>
<action>
Create `lib/features/transactions/data/transaction_repository_impl.dart`.

```dart
import '../domain/models/transaction_model.dart';
import '../domain/repositories/transaction_repository.dart';
import 'transaction_remote_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _dataSource;
  TransactionRepositoryImpl(this._dataSource);

  @override
  Stream<List<TransactionModel>> getTransactionsForSite(String siteId) =>
      _dataSource.watchBySite(siteId);

  @override
  Stream<List<TransactionModel>> getTransactionsByUser(String userId) =>
      _dataSource.watchByUser(userId);

  @override
  Future<String> createTransaction(TransactionModel transaction) =>
      _dataSource.create(transaction);

  @override
  Future<void> updateTransaction(TransactionModel transaction) =>
      _dataSource.update(transaction);

  @override
  Future<void> deleteTransaction({required String siteId, required String transactionId}) =>
      _dataSource.delete(siteId: siteId, transactionId: transactionId, userId: '', userName: '');

  @override
  Future<TransactionModel?> getTransactionById({required String siteId, required String transactionId}) =>
      _dataSource.getById(siteId: siteId, transactionId: transactionId);
}
```
</action>
<acceptance_criteria>
- `lib/features/transactions/data/transaction_repository_impl.dart` exists
- Implements all methods from `TransactionRepository`
- Delegates to `TransactionRemoteDataSource`
</acceptance_criteria>
</task>

## 4. Site Repository Interface & Implementation
<task>
<read_first>
- lib/features/sites/domain/models/site_model.dart
- lib/features/sites/domain/models/site_user_model.dart
</read_first>
<action>
Create `lib/features/sites/domain/repositories/site_repository.dart`:

```dart
import '../models/site_model.dart';
import '../models/site_user_model.dart';

abstract class SiteRepository {
  /// Get all active sites (for admin/superAdmin)
  Stream<List<SiteModel>> getAllSites();

  /// Get sites assigned to a specific partner (via site_users join)
  Future<List<SiteModel>> getAssignedSites(String userId);

  /// Create a new site, returns doc ID
  Future<String> createSite(SiteModel site);

  /// Update site details
  Future<void> updateSite(SiteModel site);

  /// Assign a partner user to a site
  Future<void> assignUserToSite(SiteUserModel siteUser);

  /// Remove a partner user from a site
  Future<void> removeUserFromSite({required String siteId, required String userId});

  /// Get all users assigned to a site
  Future<List<SiteUserModel>> getUsersForSite(String siteId);
}
```

Create `lib/features/sites/data/site_remote_data_source.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/site_model.dart';
import '../domain/models/site_user_model.dart';

class SiteRemoteDataSource {
  final FirebaseFirestore _db;
  SiteRemoteDataSource(this._db);

  Stream<List<SiteModel>> watchAllSites() =>
      _db.collection('sites')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map(SiteModel.fromFirestore).toList());

  Future<List<SiteModel>> getSitesForUser(String userId) async {
    // Query site_users to get siteIds assigned to this user
    final siteUserDocs = await _db.collection('site_users')
        .where('userId', isEqualTo: userId)
        .get();
    final siteIds = siteUserDocs.docs.map((d) => d['siteId'] as String).toList();
    if (siteIds.isEmpty) return [];

    // Fetch those sites (up to 30 — Firestore whereIn limit)
    final siteDocs = await _db.collection('sites')
        .where(FieldPath.documentId, whereIn: siteIds.take(30).toList())
        .where('isActive', isEqualTo: true)
        .get();
    return siteDocs.docs.map(SiteModel.fromFirestore).toList();
  }

  Future<String> createSite(SiteModel site) async {
    final ref = await _db.collection('sites').add(site.toMap());
    return ref.id;
  }

  Future<void> updateSite(SiteModel site) =>
      _db.collection('sites').doc(site.id).update(site.toMap());

  Future<void> assignUser(SiteUserModel siteUser) =>
      _db.collection('site_users').add(siteUser.toMap());

  Future<void> removeUser({required String siteId, required String userId}) async {
    final snap = await _db.collection('site_users')
        .where('siteId', isEqualTo: siteId)
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<SiteUserModel>> getUsersForSite(String siteId) async {
    final snap = await _db.collection('site_users')
        .where('siteId', isEqualTo: siteId)
        .get();
    return snap.docs.map(SiteUserModel.fromFirestore).toList();
  }
}
```

Create `lib/features/sites/data/site_repository_impl.dart`:

```dart
import '../domain/models/site_model.dart';
import '../domain/models/site_user_model.dart';
import '../domain/repositories/site_repository.dart';
import 'site_remote_data_source.dart';

class SiteRepositoryImpl implements SiteRepository {
  final SiteRemoteDataSource _ds;
  SiteRepositoryImpl(this._ds);

  @override Stream<List<SiteModel>> getAllSites() => _ds.watchAllSites();
  @override Future<List<SiteModel>> getAssignedSites(String userId) => _ds.getSitesForUser(userId);
  @override Future<String> createSite(SiteModel site) => _ds.createSite(site);
  @override Future<void> updateSite(SiteModel site) => _ds.updateSite(site);
  @override Future<void> assignUserToSite(SiteUserModel siteUser) => _ds.assignUser(siteUser);
  @override Future<void> removeUserFromSite({required String siteId, required String userId}) => _ds.removeUser(siteId: siteId, userId: userId);
  @override Future<List<SiteUserModel>> getUsersForSite(String siteId) => _ds.getUsersForSite(siteId);
}
```
</action>
<acceptance_criteria>
- `lib/features/sites/domain/repositories/site_repository.dart` exists with abstract class
- `lib/features/sites/data/site_remote_data_source.dart` exists
- `lib/features/sites/data/site_repository_impl.dart` exists and implements all interface methods
- `getAssignedSites` queries `site_users` collection by `userId` then fetches matching `sites` docs
- `whereIn` limited to 30 (Firestore constraint respected)
</acceptance_criteria>
</task>

## 5. Riverpod Repository Providers
<task>
<read_first>
- lib/features/auth/presentation/providers/auth_provider.dart
- lib/features/transactions/data/transaction_repository_impl.dart
- lib/features/transactions/data/transaction_remote_data_source.dart
- lib/features/sites/data/site_repository_impl.dart
- lib/features/sites/data/site_remote_data_source.dart
</read_first>
<action>
Create `lib/core/providers/repository_providers.dart`.

Use `riverpod_annotation` to define providers for all repositories. Keep it simple (no code-gen for repos to avoid circular complexity — use plain `Provider`):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/transactions/data/transaction_remote_data_source.dart';
import '../../features/transactions/data/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/sites/data/site_remote_data_source.dart';
import '../../features/sites/data/site_repository_impl.dart';
import '../../features/sites/domain/repositories/site_repository.dart';

// Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Transaction
final transactionDataSourceProvider = Provider<TransactionRemoteDataSource>((ref) =>
    TransactionRemoteDataSource(ref.read(firestoreProvider)));

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) =>
    TransactionRepositoryImpl(ref.read(transactionDataSourceProvider)));

// Site
final siteDataSourceProvider = Provider<SiteRemoteDataSource>((ref) =>
    SiteRemoteDataSource(ref.read(firestoreProvider)));

final siteRepositoryProvider = Provider<SiteRepository>((ref) =>
    SiteRepositoryImpl(ref.read(siteDataSourceProvider)));
```
</action>
<acceptance_criteria>
- `lib/core/providers/repository_providers.dart` exists
- `firestoreProvider` provides `FirebaseFirestore.instance`
- `transactionRepositoryProvider` provides `TransactionRepository`
- `siteRepositoryProvider` provides `SiteRepository`
- All providers use Riverpod `Provider<T>` (not riverpod_annotation for repos)
</acceptance_criteria>
</task>
