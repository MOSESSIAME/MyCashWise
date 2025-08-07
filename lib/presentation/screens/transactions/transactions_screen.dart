import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import 'add_transaction_modal.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, AccountProvider>(
      builder: (context, txnProvider, accountProvider, _) {
        // --- Ensure latest transactions are on top ---
        final allTransactions = List.from(txnProvider.transactions)
          ..sort((a, b) => b.date.compareTo(a.date)); // Sort descending by date
        final accounts = accountProvider.accounts;

        // --- Filter transactions based on search query ---
        final transactions = _searchQuery.isEmpty
            ? allTransactions
            : allTransactions.where((txn) {
                final query = _searchQuery.toLowerCase();
                return txn.category.toLowerCase().contains(query) ||
                    txn.note.toLowerCase().contains(query) ||
                    txn.amount.toString().contains(query) ||
                    _formatDate(txn.date).toLowerCase().contains(query);
              }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Transactions"),
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF185A9D),
            elevation: 0,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // --- " Transactions" header ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  "All Transactions",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                ),
              ),
              // --- SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search by date, category, note",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                  onChanged: (q) => setState(() => _searchQuery = q),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: transactions.isEmpty
                    ? const Center(
                        child: Text(
                          "No transactions found.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final txn = transactions[i];
                          final account = accounts.where((a) => a.id == txn.accountId).isNotEmpty
                              ? accounts.firstWhere((a) => a.id == txn.accountId)
                              : null;
                          final accountName = account?.name ?? 'Account';

                          return Card(
                            elevation: 1,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              leading: CircleAvatar(
                                backgroundColor: txn.isExpense
                                    ? Colors.red[100]
                                    : Colors.green[100],
                                radius: 18,
                                child: Icon(
                                  _getCategoryIcon(txn.category),
                                  color: txn.isExpense ? Colors.red : Colors.green,
                                  size: 14,
                                ),
                              ),
                              title: Text(
                                txn.note.isNotEmpty ? txn.note : txn.category,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${_formatDate(txn.date)} · $accountName",
                                    style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.5),
                                    child: Text(
                                      "Bal: ZMW${txn.balanceAfter?.toStringAsFixed(2) ?? "--"}",
                                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    (txn.isExpense ? "-ZMW" : "ZMW") + txn.amount.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: txn.isExpense ? Colors.red : Colors.green,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade600, size: 18),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          builder: (context) => AddTransactionModal(transaction: txn),
                                        );
                                      } else if (value == 'delete') {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Delete Transaction'),
                                            content: const Text('Are you sure you want to delete this transaction?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          Provider.of<TransactionProvider>(context, listen: false).deleteTransaction(txn.id);
                                        }
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xFF185A9D),
            child: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const AddTransactionModal(),
              );
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          backgroundColor: const Color(0xFFF7F9FB),
        );
      },
    );
  }

  /// Format the date for display (search and subtitle)
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Today";
    }
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return "Yesterday";
    }
    return "${date.day}/${date.month}/${date.year}";
  }

  /// Get the icon for each transaction category, including transfers
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Drink':
        return Icons.fastfood_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Income':
        return Icons.trending_up_rounded;
      case 'Transfer In':
        return Icons.compare_arrows_rounded;
      case 'Transfer Out':
        return Icons.compare_arrows_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}