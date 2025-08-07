import 'package:flutter/material.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/datasources/transaction_local_datasource.dart';
import '../providers/account_provider.dart';
import '../providers/budget_provider.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionLocalDataSource _dataSource = TransactionLocalDataSource();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  late AccountProvider accountProvider;
  void setAccountProvider(AccountProvider provider) {
    accountProvider = provider;
  }

  late BudgetProvider budgetProvider;
  void setBudgetProvider(BudgetProvider provider) {
    budgetProvider = provider;
  }

  TransactionProvider() {
    loadTransactions();
  }

  /// Loads all transactions from the local data source
  Future<void> loadTransactions() async {
    _setLoading(true);
    try {
      _transactions = await _dataSource.getAllTransactions();
      _error = null;
    } catch (e) {
      _error = 'Failed to load transactions: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a transaction, updates account and budget, and persists it
  Future<void> addTransaction(TransactionModel txn) async {
    _setLoading(true);
    try {
      // Update account balance
      final account = accountProvider.accounts.firstWhere((a) => a.id == txn.accountId);
      if (txn.isExpense) {
        account.balance -= txn.amount;
      } else {
        account.balance += txn.amount;
      }
      await account.save();

      // Persist transaction with updated balance
      final txnWithBalance = txn.copyWith(balanceAfter: account.balance);
      await _dataSource.addOrUpdateTransaction(txnWithBalance);

      // Update budget if expense
      if (txn.isExpense) {
        final month = DateTime(txn.date.year, txn.date.month);
        final budget = budgetProvider.getBudgetByCategoryAndMonth(txn.category, month);
        if (budget != null) {
          await budgetProvider.updateSpent(
            txn.category,
            budget.spent + txn.amount,
          );
        }
      }

      // Ensure transaction is added to the in-memory list
      _transactions.add(txnWithBalance);

      _error = null;
      accountProvider.notifyListeners();
      notifyListeners();
      // Reload transactions from storage to guarantee consistency
      await loadTransactions();
    } catch (e) {
      _error = 'Failed to add transaction: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Updates a transaction and all related balances/budgets
  Future<void> updateTransaction(TransactionModel txn) async {
    _setLoading(true);
    try {
      final oldTxn = await getTransactionById(txn.id);
      if (oldTxn != null) {
        final oldAccount = accountProvider.accounts.firstWhere((a) => a.id == oldTxn.accountId);
        if (oldTxn.isExpense) {
          oldAccount.balance += oldTxn.amount;
        } else {
          oldAccount.balance -= oldTxn.amount;
        }
        await oldAccount.save();

        if (oldTxn.isExpense) {
          final oldMonth = DateTime(oldTxn.date.year, oldTxn.date.month);
          final oldBudget = budgetProvider.getBudgetByCategoryAndMonth(oldTxn.category, oldMonth);
          if (oldBudget != null) {
            await budgetProvider.updateSpent(
              oldTxn.category,
              (oldBudget.spent - oldTxn.amount).clamp(0, double.infinity),
            );
          }
        }

        final newAccount = accountProvider.accounts.firstWhere((a) => a.id == txn.accountId);
        if (txn.accountId != oldTxn.accountId) {
          if (txn.isExpense) {
            newAccount.balance -= txn.amount;
          } else {
            newAccount.balance += txn.amount;
          }
          await newAccount.save();
          final txnWithBalance = txn.copyWith(balanceAfter: newAccount.balance);
          await _dataSource.addOrUpdateTransaction(txnWithBalance);
        } else {
          if (txn.isExpense) {
            oldAccount.balance -= txn.amount;
          } else {
            oldAccount.balance += txn.amount;
          }
          await oldAccount.save();
          final txnWithBalance = txn.copyWith(balanceAfter: oldAccount.balance);
          await _dataSource.addOrUpdateTransaction(txnWithBalance);
        }

        if (txn.isExpense) {
          final newMonth = DateTime(txn.date.year, txn.date.month);
          final newBudget = budgetProvider.getBudgetByCategoryAndMonth(txn.category, newMonth);
          if (newBudget != null) {
            await budgetProvider.updateSpent(
              txn.category,
              newBudget.spent + txn.amount,
            );
          }
        }
      }
      _error = null;
      accountProvider.notifyListeners();
      notifyListeners();
      // Reload transactions to ensure UI and data are synced
      await loadTransactions();
    } catch (e) {
      _error = 'Failed to update transaction: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a transaction and updates account & budget
  Future<void> deleteTransaction(String id) async {
    _setLoading(true);
    try {
      final txn = await getTransactionById(id);
      if (txn != null) {
        final account = accountProvider.accounts.firstWhere((a) => a.id == txn.accountId);
        if (txn.isExpense) {
          account.balance += txn.amount;
        } else {
          account.balance -= txn.amount;
        }
        await account.save();

        if (txn.isExpense) {
          final month = DateTime(txn.date.year, txn.date.month);
          final budget = budgetProvider.getBudgetByCategoryAndMonth(txn.category, month);
          if (budget != null) {
            await budgetProvider.updateSpent(
              txn.category,
              (budget.spent - txn.amount).clamp(0, double.infinity),
            );
          }
        }
      }
      await _dataSource.deleteTransaction(id);
      _error = null;
      accountProvider.notifyListeners();
      notifyListeners();
      // Reload transactions to update UI and state
      await loadTransactions();
    } catch (e) {
      _error = 'Failed to delete transaction: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      return await _dataSource.getTransactionById(id);
    } catch (e) {
      _error = 'Failed to get transaction: $e';
      notifyListeners();
      return null;
    }
  }

  /// Transfer money between two accounts with corresponding transactions.
  Future<void> transferBetweenAccounts({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? note,
  }) async {
    _setLoading(true);
    try {
      if (fromAccountId == toAccountId) {
        throw Exception('Cannot transfer to the same account.');
      }
      final fromAccount = accountProvider.accounts.firstWhere((a) => a.id == fromAccountId);
      final toAccount = accountProvider.accounts.firstWhere((a) => a.id == toAccountId);

      if (fromAccount.balance < amount) {
        throw Exception('Insufficient balance in source account.');
      }

      // Deduct from source
      fromAccount.balance -= amount;
      await fromAccount.save();

      // Add to destination
      toAccount.balance += amount;
      await toAccount.save();

      // Create transactions
      final now = DateTime.now();
      final fromTxn = TransactionModel(
        id: 'txn_from_${now.microsecondsSinceEpoch}',
        amount: amount,
        category: 'Transfer Out',
        note: note ?? 'Transfer to ${toAccount.name}',
        date: now,
        isExpense: true,
        accountId: fromAccountId,
        balanceAfter: fromAccount.balance,
      );
      final toTxn = TransactionModel(
        id: 'txn_to_${now.microsecondsSinceEpoch}',
        amount: amount,
        category: 'Transfer In',
        note: note ?? 'Transfer from ${fromAccount.name}',
        date: now,
        isExpense: false,
        accountId: toAccountId,
        balanceAfter: toAccount.balance,
      );

      await _dataSource.addOrUpdateTransaction(fromTxn);
      await _dataSource.addOrUpdateTransaction(toTxn);

      // Add to in-memory list
      _transactions.add(fromTxn);
      _transactions.add(toTxn);

      _error = null;
      accountProvider.notifyListeners();
      notifyListeners();
      // Reload transactions to sync with storage and UI
      await loadTransactions();
    } catch (e) {
      _error = 'Failed to transfer: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state and notify listeners
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}