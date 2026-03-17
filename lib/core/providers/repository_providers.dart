import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/models/app_user.dart';
import '../../features/transactions/data/transaction_remote_data_source.dart';
import '../../features/transactions/data/transaction_repository_impl.dart';
import '../../features/transactions/domain/models/transaction_model.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/sites/data/site_remote_data_source.dart';
import '../../features/sites/data/site_repository_impl.dart';
import '../../features/sites/domain/repositories/site_repository.dart';

// ─── Firestore ────────────────────────────────────────────────────────────────

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

// ─── Transaction ──────────────────────────────────────────────────────────────

final transactionDataSourceProvider = Provider<TransactionRemoteDataSource>(
  (ref) => TransactionRemoteDataSource(ref.read(firestoreProvider)),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(ref.read(transactionDataSourceProvider)),
);

// ─── Site ─────────────────────────────────────────────────────────────────────

final siteDataSourceProvider = Provider<SiteRemoteDataSource>(
  (ref) => SiteRemoteDataSource(ref.read(firestoreProvider)),
);

final siteRepositoryProvider = Provider<SiteRepository>(
  (ref) => SiteRepositoryImpl(ref.read(siteDataSourceProvider)),
);

// ─── Admin: All Users (partners) ──────────────────────────────────────────────

/// Stream of all partner users for admin management screens.
final allPartnersStreamProvider = StreamProvider<List<AppUser>>((ref) {
  final db = ref.read(firestoreProvider);
  return db
      .collection('users')
      .where('role', isEqualTo: 'partner')
      .orderBy('name')
      .snapshots()
      .map((q) => q.docs.map(AppUser.fromFirestore).toList());
});

/// Stream of ALL transactions across all sites (admin view).
/// Since transactions are in site sub-collections, we use a collectionGroup query.
final allTransactionsStreamProvider =
    StreamProvider<List<TransactionModel>>((ref) {
  final db = ref.read(firestoreProvider);
  return db
      .collectionGroup('transactions')
      .orderBy('transactionDate', descending: true)
      .snapshots()
      .map((q) => q.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList());
});
