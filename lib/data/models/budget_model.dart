import 'package:hive/hive.dart';

part 'budget_model.g.dart';

/// Represents a monthly budget for a specific category.
@HiveType(typeId: 1)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String category;
  @HiveField(2)
  final double limit; // Monthly budget limit
  @HiveField(3)
  double spent; // Mutable: Amount spent so far this month
  @HiveField(4)
  final DateTime month; // The month this budget applies to

  BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.spent,
    required this.month,
  });

  BudgetModel copyWith({
    String? id,
    String? category,
    double? limit,
    double? spent,
    DateTime? month,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      month: month ?? this.month,
    );
  }
}