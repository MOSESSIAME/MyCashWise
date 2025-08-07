import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';

class AddTransactionModal extends StatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionModal({super.key, this.transaction});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _category = 'Food & Drink';
  bool _isExpense = true;
  String? _selectedAccountId;

  // Full list of categories including transfer types
  final List<String> _allCategories = [
    'Food & Drink', 'Transport', 'Shopping', 'Salary', 'Bills', 'Income', 'Transfer In', 'Transfer Out'
  ];

  @override
  void initState() {
    super.initState();
    // If editing, prefill fields
    if (widget.transaction != null) {
      final txn = widget.transaction!;
      _amountController.text = txn.amount.toString();
      _noteController.text = txn.note;
      _category = txn.category;
      _isExpense = txn.isExpense;
      _selectedAccountId = txn.accountId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Ensures dropdown always contains the current category (even if filtered), and no duplicates
  List<String> _dropdownCategories(String? currentCategory) {
    final set = {..._allCategories};
    if (currentCategory != null && !set.contains(currentCategory)) {
      set.add(currentCategory);
    }
    return set.toList();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true || _selectedAccountId == null) return;

    final txn = TransactionModel(
      id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.parse(_amountController.text),
      category: _category,
      note: _noteController.text,
      date: widget.transaction?.date ?? DateTime.now(),
      isExpense: _isExpense,
      accountId: _selectedAccountId!,
    );

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    if (widget.transaction == null) {
      provider.addTransaction(txn);
    } else {
      provider.updateTransaction(txn);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = Provider.of<AccountProvider>(context).accounts;
    final hasAccounts = accounts.isNotEmpty;

    // Pre-select first account if available and not yet selected
    if (hasAccounts && _selectedAccountId == null) {
      _selectedAccountId = accounts.first.id;
    }

    final selectedAccount = accounts.where((a) => a.id == _selectedAccountId).isNotEmpty
        ? accounts.firstWhere((a) => a.id == _selectedAccountId)
        : null;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.transaction == null ? "Add Transaction" : "Edit Transaction",
                  style: Theme.of(context).textTheme.headlineMedium
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Amount"),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Enter amount";
                    final val = double.tryParse(v);
                    if (val == null || val <= 0) return "Enter a valid amount";
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _category,
                  items: _dropdownCategories(widget.transaction?.category)
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                const SizedBox(height: 10),
                if (!hasAccounts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      "No accounts available. Please add an account first.",
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                if (hasAccounts)
                  DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    items: accounts
                        .map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Row(
                                children: [
                                  Icon(_getAccountIcon(a.type), size: 18),
                                  const SizedBox(width: 6),
                                  Text(a.name),
                                  const SizedBox(width: 8),
                                  Text(
                                    "ZMW${a.balance.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedAccountId = v),
                    decoration: const InputDecoration(labelText: "Account"),
                    validator: (v) => v == null ? "Select account" : null,
                  ),
                if (_selectedAccountId != null && selectedAccount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8),
                    child: Row(
                      children: [
                        Icon(_getAccountIcon(selectedAccount.type), size: 16, color: Colors.blueGrey),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            "${selectedAccount.name} — Balance: ZMW${selectedAccount.balance.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                SwitchListTile(
                  title: Text(_isExpense ? 'Expense' : 'Income'),
                  value: _isExpense,
                  onChanged: (v) => setState(() => _isExpense = v),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: "Note (optional)"),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: hasAccounts ? _submit : null,
                  child: Text(widget.transaction == null ? "Save" : "Update"),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'Cash':
        return Icons.money;
      case 'Bank':
        return Icons.account_balance;
      case 'Card':
        return Icons.credit_card;
      case 'Mobile Money':
        return Icons.phone_iphone;
      default:
        return Icons.account_balance_wallet;
    }
  }
}