import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../core/utils/analytics_utils.dart';
import 'transaction_provider.dart';

class AnalyticsProvider with ChangeNotifier {
  final TransactionProvider transactionProvider;

  AnalyticsProvider(this.transactionProvider);

  List<TransactionModel> get _txns => transactionProvider.transactions;

  double get totalExpenses => AnalyticsUtils.totalExpenses(_txns);
  double get totalIncome => AnalyticsUtils.totalIncome(_txns);

  Map<String, double> get expensesByCategory => AnalyticsUtils.expensesByCategory(_txns);
  Map<String, double> get incomeByCategory => AnalyticsUtils.incomeByCategory(_txns);

  Map<String, double> monthlyExpenses() => AnalyticsUtils.monthlyTotals(_txns, expense: true);
  Map<String, double> monthlyIncome() => AnalyticsUtils.monthlyTotals(_txns, expense: false);
}