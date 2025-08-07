import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class TransactionLocalDataSource {
  static const String boxName = 'transactions';

  // Get all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    final box = await Hive.openBox<TransactionModel>(boxName);
    return box.values.toList();
  }

  // Add or update a transaction by its id
  Future<void> addOrUpdateTransaction(TransactionModel txn) async {
    final box = await Hive.openBox<TransactionModel>(boxName);
    await box.put(txn.id, txn);
  }

  // Delete a transaction by its id
  Future<void> deleteTransaction(String id) async {
    final box = await Hive.openBox<TransactionModel>(boxName);
    await box.delete(id);
  }

  // Get a transaction by id
  Future<TransactionModel?> getTransactionById(String id) async {
    final box = await Hive.openBox<TransactionModel>(boxName);
    return box.get(id);
  }
}