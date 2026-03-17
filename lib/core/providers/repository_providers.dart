import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/transactions/data/transaction_remote_data_source.dart';
import '../../features/transactions/data/transaction_repository_impl.dart';
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
