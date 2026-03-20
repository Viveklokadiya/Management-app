import '../models/transaction_model.dart';

abstract class TransactionRepository {
  /// Real-time stream of transactions for a specific site
  Stream<List<TransactionModel>> getTransactionsForSite(String siteId);

  /// Real-time stream of transactions created by a specific user (across all sites)
  Stream<List<TransactionModel>> getTransactionsByUser(String userId);

  /// Real-time stream of ALL transactions (admin view)
  Stream<List<TransactionModel>> getAllTransactions();

  /// Create a new transaction — returns the new document ID
  Future<String> createTransaction(TransactionModel transaction);

  /// Update an existing transaction (admin only)
  Future<void> updateTransaction(TransactionModel transaction);

  /// Delete a transaction (admin only)
  Future<void> deleteTransaction({
    required String transactionId,
    required String userId,
    required String userName,
  });

  /// Fetch a single transaction by ID
  Future<TransactionModel?> getTransactionById(String transactionId);
}
