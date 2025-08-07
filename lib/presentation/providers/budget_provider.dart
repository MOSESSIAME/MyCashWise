import 'package:flutter/material.dart';
import '../../data/models/budget_model.dart';
import '../../data/datasources/budget_local_datasource.dart';

/// Provider to manage budgets and notify listeners on change.
class BudgetProvider with ChangeNotifier {
  final BudgetLocalDataSource _datasource = BudgetLocalDataSource();

  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  String? _error;

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads all budgets from the local data source.
  Future<void> loadBudgets() async {
    _setLoading(true);
    try {
      _budgets = await _datasource.getBudgets();
      _error = null;
    } catch (e) {
      _error = 'Failed to load budgets: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a new budget and reloads budgets.
  Future<void> addBudget(BudgetModel budget) async {
    _setLoading(true);
    try {
      await _datasource.addBudget(budget);
      await loadBudgets();
      _error = null;
    } catch (e) {
      _error = 'Failed to add budget: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing budget and reloads budgets.
  Future<void> updateBudget(BudgetModel budget) async {
    _setLoading(true);
    try {
      await _datasource.updateBudget(budget);
      await loadBudgets();
      _error = null;
    } catch (e) {
      _error = 'Failed to update budget: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Updates the spent amount for a specific category and month, then reloads budgets.
  Future<void> updateSpent(String category, double amount, {DateTime? month}) async {
    _setLoading(true);
    try {
      // Pass month if available for accuracy, fallback to current month if not provided
      await _datasource.updateBudgetSpent(category, amount, month: month);
      await loadBudgets();
      _error = null;
    } catch (e) {
      _error = 'Failed to update budget spent: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Gets the budget for a specific category and month.
  BudgetModel? getBudgetByCategoryAndMonth(String category, DateTime month) {
    try {
      final matches = _budgets.where(
        (b) =>
            b.category == category &&
            b.month.year == month.year &&
            b.month.month == month.month,
      );
      return matches.isNotEmpty ? matches.first : null;
    } catch (_) {
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}