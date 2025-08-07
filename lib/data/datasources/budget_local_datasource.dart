import 'package:hive/hive.dart';
import '../models/budget_model.dart';

class BudgetLocalDataSource {
  static const String _boxName = 'budgets';

  Future<List<BudgetModel>> getBudgets() async {
    final box = await Hive.openBox<BudgetModel>(_boxName);
    return box.values.toList().cast<BudgetModel>();
  }

  Future<void> addBudget(BudgetModel budget) async {
    final box = await Hive.openBox<BudgetModel>(_boxName);
    await box.put(budget.id, budget);
  }

  /// Update the spent value for the first budget found with the given category and matching month.
  Future<void> updateBudgetSpent(String category, double amount, {DateTime? month}) async {
    final box = await Hive.openBox<BudgetModel>(_boxName);
    final DateTime targetMonth = month ?? DateTime.now();
    final budgets = box.values
        .where((b) =>
            b.category == category &&
            b.month.year == targetMonth.year &&
            b.month.month == targetMonth.month)
        .toList()
        .cast<BudgetModel>();
    if (budgets.isNotEmpty) {
      final budget = budgets.first;
      budget.spent = amount;
      await budget.save();
    }
  }

  /// Update all fields of a budget (for editing).
  Future<void> updateBudget(BudgetModel budget) async {
    final box = await Hive.openBox<BudgetModel>(_boxName);
    await box.put(budget.id, budget);
  }
}