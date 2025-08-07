import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/budget_provider.dart';

import 'add_budget_modal.dart';

class BudgetsScreen extends StatefulWidget {
  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BudgetProvider>(context, listen: false).loadBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (provider.error != null) {
          return Scaffold(body: Center(child: Text(provider.error!)));
        }
        final budgets = provider.budgets;
        return Scaffold(
          appBar: AppBar(title: const Text("Budgets")),
          body: budgets.isEmpty
              ? const Center(child: Text("No budgets set."))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: budgets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final b = budgets[i];
                    final percent = b.limit == 0 ? 0 : (b.spent / b.limit).clamp(0, 1);
                    final isOverspent = b.spent > b.limit;
                    final monthStr = "${_monthName(b.month.month)} ${b.month.year}";
                    return Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  b.category,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Chip(
                                  label: Text(monthStr),
                                  backgroundColor: Colors.grey.shade200,
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (_) => AddBudgetModal(budget: b),
                                      );
                                    }
                                    // Optionally add a delete option here.
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: percent.toDouble(),
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  percent >= 1 ? Colors.red : Colors.green),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  "\K${b.spent.toStringAsFixed(2)} spent",
                                  style: TextStyle(
                                    color: percent >= 1 ? Colors.red : Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "of \K${b.limit.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${(percent * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    color: percent >= 1 ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (isOverspent) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: const [
                                  Icon(Icons.warning, color: Colors.red, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    "Overspent!",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text("Add Budget"),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const AddBudgetModal(),
              );
            },
          ),
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}