import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class TransactionLocalDataSource {
  final Box<TransactionModel> _transactionBox = Hive.box<TransactionModel>('transactions');

  List<TransactionModel> getAllTransactions() {
    return _transactionBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(TransactionModel txn) async {
    await _transactionBox.put(txn.id, txn);
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
  }
}