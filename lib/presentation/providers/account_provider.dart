import 'package:flutter/material.dart';
import '../../../data/models/account_model.dart';
import '../../../data/datasources/account_local_datasource.dart';

/// Provider to manage all account operations and state.
class AccountProvider with ChangeNotifier {
  final AccountLocalDataSource _dataSource = AccountLocalDataSource();

  List<AccountModel> _accounts = [];
  bool _isLoading = false;
  String? _error;

  AccountProvider() {
    loadAccounts();
  }

  List<AccountModel> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all accounts from the local data source.
  Future<void> loadAccounts() async {
    _setLoading(true);
    try {
      _accounts = _dataSource.getAllAccounts();
      _error = null;
    } catch (e) {
      _error = 'Failed to load accounts: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Add or update an account.
  Future<void> addAccount(AccountModel account) async {
    _setLoading(true);
    try {
      await _dataSource.addOrUpdateAccount(account);
      await loadAccounts();
      _error = null;
    } catch (e) {
      _error = 'Failed to add account: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing account.
  Future<void> updateAccount(AccountModel account) async {
    _setLoading(true);
    try {
      await _dataSource.addOrUpdateAccount(account);
      await loadAccounts();
      _error = null;
    } catch (e) {
      _error = 'Failed to update account: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Delete an account by id.
  Future<void> deleteAccount(String id) async {
    _setLoading(true);
    try {
      await _dataSource.deleteAccount(id);
      await loadAccounts();
      _error = null;
    } catch (e) {
      _error = 'Failed to delete account: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Get an account by id.
  AccountModel? getAccountById(String id) {
    try {
      return _dataSource.getAccountById(id);
    } catch (e) {
      _error = 'Failed to get account: $e';
      notifyListeners();
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}