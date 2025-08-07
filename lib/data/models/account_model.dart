import 'package:hive/hive.dart';

part 'account_model.g.dart';

/// Represents a financial account in CashWise (e.g. bank, mobile money, cash)
@HiveType(typeId: 2)
class AccountModel extends HiveObject {
  @HiveField(0)
  String id;      // Unique identifier (UUID or similar)
  @HiveField(1)
  String name;    // e.g. "Airtel Money", "Bank 1"
  @HiveField(2)
  double balance; // Current balance
  @HiveField(3)
  String type;    // e.g. "Cash", "Bank", "Card", "Mobile Money"

  AccountModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
  });

  AccountModel copyWith({
    String? id,
    String? name,
    double? balance,
    String? type,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
    );
  }

  /// Optional: for easier serialization/deserialization
  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] as String,
      name: map['name'] as String,
      balance: map['balance'] as double,
      type: map['type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'type': type,
    };
  }
}