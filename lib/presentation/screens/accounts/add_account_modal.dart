import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/account_model.dart';
import '../../providers/account_provider.dart';

class AddAccountModal extends StatefulWidget {
  final AccountModel? account;
  const AddAccountModal({super.key, this.account});

  @override
  State<AddAccountModal> createState() => _AddAccountModalState();
}

class _AddAccountModalState extends State<AddAccountModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _type = 'Cash';

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _nameController.text = widget.account!.name;
      _balanceController.text = widget.account!.balance.toString();
      _type = widget.account!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Use existing ID for edit, or new for add
      final account = AccountModel(
        id: widget.account?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        balance: double.tryParse(_balanceController.text) ?? 0.0,
        type: _type,
      );
      final provider = Provider.of<AccountProvider>(context, listen: false);
      if (widget.account == null) {
        provider.addAccount(account);
      } else {
        provider.updateAccount(account); // <-- Must be implemented in your provider
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.account == null ? "Add Account" : "Edit Account",
                  style: Theme.of(context).textTheme.headlineMedium
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Account Name"),
                  validator: (v) => v == null || v.isEmpty ? "Enter account name" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _balanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Initial Balance"),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Enter balance";
                    final val = double.tryParse(v);
                    if (val == null) return "Enter a valid number";
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _type,
                  items: ['Cash', 'Bank', 'Card', 'Mobile Money', 'Other']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v!),
                  decoration: const InputDecoration(labelText: "Type"),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.account == null ? "Save" : "Update"),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}