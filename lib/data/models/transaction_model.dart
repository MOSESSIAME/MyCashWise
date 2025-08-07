import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

/// Represents a financial transaction (expense or income) in CashWise.
@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String note;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final bool isExpense;

  @HiveField(6)
  final String accountId; // Which account this transaction is linked to

  @HiveField(7)
  final double? balanceAfter; // <-- Add this field to store balance after transaction

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.isExpense,
    required this.accountId,
    this.balanceAfter, // <-- Add this in constructor
  });

  /// For easy updates
  TransactionModel copyWith({
    String? id,
    double? amount,
    String? category,
    String? note,
    DateTime? date,
    bool? isExpense,
    String? accountId,
    double? balanceAfter, // <-- Add this in copyWith
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      isExpense: isExpense ?? this.isExpense,
      accountId: accountId ?? this.accountId,
      balanceAfter: balanceAfter ?? this.balanceAfter,
    );
  }
}