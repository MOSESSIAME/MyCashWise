import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';

class TransferModal extends StatefulWidget {
  const TransferModal({super.key});

  @override
  State<TransferModal> createState() => _TransferModalState();
}

class _TransferModalState extends State<TransferModal> {
  String? fromId;
  String? toId;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final accounts = context.read<AccountProvider>().accounts;
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Transfer Funds', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: fromId,
                decoration: const InputDecoration(labelText: 'From Account'),
                items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                onChanged: (v) => setState(() => fromId = v),
                validator: (v) => v == null ? 'Select source account' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: toId,
                decoration: const InputDecoration(labelText: 'To Account'),
                items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                onChanged: (v) => setState(() => toId = v),
                validator: (v) {
                  if (v == null) return 'Select destination account';
                  if (v == fromId) return 'Cannot transfer to same account';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (v) {
                  final d = double.tryParse(v ?? '');
                  if (d == null || d <= 0) return 'Enter valid amount';
                  if (fromId != null) {
                    final fromAccount = accounts.firstWhere((a) => a.id == fromId);
                    if (d > fromAccount.balance) return 'Insufficient funds';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Transfer'),
                onPressed: () async {
                  if (_formKey.currentState?.validate() != true) return;
                  final txnProvider = context.read<TransactionProvider>();
                  try {
                    await txnProvider.transferBetweenAccounts(
                      fromAccountId: fromId!,
                      toAccountId: toId!,
                      amount: double.parse(_amountController.text),
                      note: _noteController.text.isEmpty ? null : _noteController.text,
                    );
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Transfer failed: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}