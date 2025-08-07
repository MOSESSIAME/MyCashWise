import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import 'add_account_modal.dart';
import 'transfer_modal.dart'; // <-- Transfer modal for the transfer feature

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, provider, _) {
        final accounts = provider.accounts;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Accounts"),
            actions: [
              IconButton(
                icon: const Icon(Icons.compare_arrows),
                tooltip: 'Transfer',
                onPressed: () {
                  // Show the transfer modal for transferring between accounts
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const TransferModal(),
                  );
                },
              ),
            ],
          ),
          body: accounts.isEmpty
              ? const Center(child: Text("No accounts added yet."))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: accounts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final a = accounts[i];
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(_getAccountIcon(a.type), color: Colors.blue),
                        ),
                        title: Text(
                          a.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.type, style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              "Balance: ZMW${a.balance.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => AddAccountModal(account: a),
                              );
                            } else if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Account'),
                                  content: Text(
                                      'Are you sure you want to delete "${a.name}"? This cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                provider.deleteAccount(a.id);
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text("Add Account"),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const AddAccountModal(),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'Cash':
        return Icons.money;
      case 'Bank':
        return Icons.account_balance;
      case 'Other':
        return Icons.credit_card;
      case 'Mobile Money':
        return Icons.phone_iphone;
      default:
        return Icons.account_balance_wallet;
    }
  }
}