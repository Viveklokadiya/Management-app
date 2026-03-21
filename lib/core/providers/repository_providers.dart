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

// ─── Admin: All Users as Partners ─────────────────────────────────────────────

/// Stream of ALL users regardless of role — because admins/superAdmins
/// are also partners with additional privileges.
final allPartnersStreamProvider = StreamProvider<List<AppUser>>((ref) {
  final db = ref.read(firestoreProvider);
  return db
      .collection('users')
      .snapshots()
      .map((q) {
        final list = q.docs.map(AppUser.fromFirestore).toList();
        list.sort((a, b) => a.name.compareTo(b.name));
        return list;
      });
});

/// Stream of ALL transactions across all sites (admin view).
/// Uses the single root `transactions` collection.
final allTransactionsStreamProvider =
    StreamProvider<List<TransactionModel>>((ref) {
  return ref.read(transactionRepositoryProvider).getAllTransactions();
});

// ─── Super Admin: All Users ───────────────────────────────────────────────────

/// Stream of ALL users (any role) for super admin user management.
final allUsersStreamProvider = StreamProvider<List<AppUser>>((ref) {
  final db = ref.read(firestoreProvider);
  return db.collection('users').snapshots().map((q) {
    final list = q.docs.map(AppUser.fromFirestore).toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  });
});
