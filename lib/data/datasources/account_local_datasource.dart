import 'package:hive/hive.dart';
import '../models/account_model.dart';

class AccountLocalDataSource {
  final Box<AccountModel> _accountBox = Hive.box<AccountModel>('accounts');

  // Get all accounts
  List<AccountModel> getAllAccounts() {
    return _accountBox.values.toList();
  }

  // Add or update an account by id
  Future<void> addOrUpdateAccount(AccountModel account) async {
    await _accountBox.put(account.id, account);
  }

  // Delete an account by id
  Future<void> deleteAccount(String id) async {
    await _accountBox.delete(id);
  }

  // Get an account by id
  AccountModel? getAccountById(String id) {
    return _accountBox.get(id);
  }
}