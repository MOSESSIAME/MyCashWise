import '../../data/models/transaction_model.dart';

class AnalyticsUtils {
  /// Get total expenses in a list of transactions (optionally for a date range)
  static double totalExpenses(List<TransactionModel> txns, {DateTime? start, DateTime? end}) {
    return txns.where((txn) =>
      txn.isExpense &&
      (start == null || !txn.date.isBefore(start)) &&
      (end == null || !txn.date.isAfter(end))
    ).fold(0.0, (sum, txn) => sum + txn.amount);
  }

  /// Get total income in a list of transactions (optionally for a date range)
  static double totalIncome(List<TransactionModel> txns, {DateTime? start, DateTime? end}) {
    return txns.where((txn) =>
      !txn.isExpense &&
      (start == null || !txn.date.isBefore(start)) &&
      (end == null || !txn.date.isAfter(end))
    ).fold(0.0, (sum, txn) => sum + txn.amount);
  }

  /// Group expenses by category (returns map: category -> total)
  static Map<String, double> expensesByCategory(List<TransactionModel> txns) {
    final Map<String, double> result = {};
    for (final txn in txns) {
      if (txn.isExpense) {
        result[txn.category] = (result[txn.category] ?? 0) + txn.amount;
      }
    }
    return result;
  }

  /// Group income by category
  static Map<String, double> incomeByCategory(List<TransactionModel> txns) {
    final Map<String, double> result = {};
    for (final txn in txns) {
      if (!txn.isExpense) {
        result[txn.category] = (result[txn.category] ?? 0) + txn.amount;
      }
    }
    return result;
  }

  /// Get monthly totals (returns map: 'YYYY-MM' -> total expense/income)
  static Map<String, double> monthlyTotals(List<TransactionModel> txns, {bool expense = true}) {
    final Map<String, double> result = {};
    for (final txn in txns) {
      if (txn.isExpense == expense) {
        final key = "${txn.date.year}-${txn.date.month.toString().padLeft(2, '0')}";
        result[key] = (result[key] ?? 0) + txn.amount;
      }
    }
    return result;
  }
}