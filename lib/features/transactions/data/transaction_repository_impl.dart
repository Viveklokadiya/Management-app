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
  Future<void> deleteTransaction({
    required String siteId,
    required String transactionId,
    required String userId,
    required String userName,
  }) =>
      _dataSource.delete(
        siteId: siteId,
        transactionId: transactionId,
        userId: userId,
        userName: userName,
      );

  @override
  Future<TransactionModel?> getTransactionById({
    required String siteId,
    required String transactionId,
  }) =>
      _dataSource.getById(siteId: siteId, transactionId: transactionId);
}
