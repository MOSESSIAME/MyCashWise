import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/analytics_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Analytics')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Expenses: \$${analytics.totalExpenses.toStringAsFixed(2)}'),
                Text('Total Income: \$${analytics.totalIncome.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                Text('Expenses by Category:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...analytics.expensesByCategory.entries.map((e) => Text('${e.key}: \$${e.value.toStringAsFixed(2)}')),
                const SizedBox(height: 16),
                Text('Income by Category:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...analytics.incomeByCategory.entries.map((e) => Text('${e.key}: \$${e.value.toStringAsFixed(2)}')),
              ],
            ),
          ),
        );
      },
    );
  }
}