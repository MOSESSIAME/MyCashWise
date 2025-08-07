import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../budgets/budgets_screen.dart';
import '../transactions/transactions_screen.dart';
import '../accounts/accounts_screen.dart';

// --- Uniform selected color for nav bar ---
const Color kSelectedNavColor = Color(0xFF185A9D);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    _DashboardScreen(),
    TransactionsScreen(),
    BudgetsScreen(),
    AccountsScreen(),
    PlaceholderScreen(title: 'More'),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<_NavTabInfo> _navTabs = const [
    _NavTabInfo(
        icon: Icons.home_rounded,
        label: "Home",
        emoji: "🏠",
        color: kSelectedNavColor),
    _NavTabInfo(
        icon: Icons.list_alt_rounded,
        label: "Transactions",
        emoji: "💸",
        color: kSelectedNavColor),
    _NavTabInfo(
        icon: Icons.stacked_line_chart_rounded,
        label: "Budgets",
        emoji: "📊",
        color: kSelectedNavColor),
    _NavTabInfo(
        icon: Icons.account_balance_wallet_rounded,
        label: "Accounts",
        emoji: "👛",
        color: kSelectedNavColor),
    _NavTabInfo(
        icon: Icons.more_horiz_rounded,
        label: "More",
        emoji: "✨",
        color: kSelectedNavColor),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyCashWise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: kSelectedNavColor,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _ModernBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        tabs: _navTabs,
      ),
      backgroundColor: Colors.white,
    );
  }
}

// DASHBOARD SCREEN
class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen();

  Future<String?> _fetchUsername() async {
    var box = await Hive.openBox('auth');
    return box.get('username') as String?;
  }

  String _greetingByTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Morning";
    } else if (hour < 17) {
      return "Afternoon";
    } else {
      return "Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<String?>(
      future: _fetchUsername(),
      builder: (context, snapshot) {
        final username = snapshot.data;
        return Consumer2<TransactionProvider, AccountProvider>(
          builder: (context, txnProvider, accountProvider, _) {
            final transactions = List.from(txnProvider.transactions)
              ..sort((a, b) => b.date.compareTo(a.date)); // descending by date
            final accounts = accountProvider.accounts;
            double monthIncome = 0;
            double monthExpenses = 0;
            final now = DateTime.now();

            // Calculate totals, exclude transfers
            for (final txn in transactions) {
              if (txn.date.month == now.month && txn.date.year == now.year) {
                if (txn.category != 'Transfer In' && txn.category != 'Transfer Out') {
                  if (txn.isExpense) {
                    monthExpenses += txn.amount;
                  } else {
                    monthIncome += txn.amount;
                  }
                }
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting header
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 2, right: 2, bottom: 10),
                    child: Row(
                      children: [
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Flexible(
                            child: Text(
                              "${_greetingByTime()}${username != null && username.isNotEmpty ? ', $username' : ''} 👋",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: kSelectedNavColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Dashboard title
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 10),
                    child: Text(
                      "Home",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: 0.2,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCardModern(
                          title: "Income",
                          subtitle: "(This month)",
                          value: monthIncome,
                          icon: Icons.arrow_downward_rounded,
                          color: Color(0xFF1F8E49),
                          bgColor: Color(0xFFD3F9E6),
                          currency: "ZMW",
                          isExpense: false,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SummaryCardModern(
                          title: "Expenses",
                          subtitle: "(This month)",
                          value: monthExpenses,
                          icon: Icons.arrow_upward_rounded,
                          color: Color(0xFFD32F2F),
                          bgColor: Color(0xFFFFE3E0),
                          currency: "ZMW",
                          isExpense: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Text(
                    "Recent Transactions",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...transactions.take(2).map((txn) {
                    final account = accounts.where((a) => a.id == txn.accountId).isNotEmpty
                        ? accounts.firstWhere((a) => a.id == txn.accountId)
                        : null;
                    final accountName = account?.name ?? 'Account';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: txn.isExpense ? Colors.red[100] : Colors.green[100],
                            child: Icon(
                              _getCategoryIcon(txn.category),
                              color: txn.isExpense ? Colors.red : Colors.green,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            txn.note.isNotEmpty ? txn.note : txn.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          subtitle: Text(
                            "${_formatDate(txn.date)} · $accountName",
                            style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            (txn.isExpense ? "-" : "") +
                                "ZMW${txn.amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: txn.isExpense ? Color(0xFFD32F2F) : Color(0xFF1F8E49),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (transactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 1,
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          title: Text("No transactions yet.", style: theme.textTheme.bodyMedium),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Today";
    }
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return "Yesterday";
    }
    return "${date.day}/${date.month}/${date.year}";
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Drink':
        return Icons.fastfood_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Other':
        return Icons.attach_money_rounded;
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

/// MODERN SUMMARY CARD - left-aligned, bigger box, smaller figure font, minimal left padding
class SummaryCardModern extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String currency;
  final bool isExpense;

  const SummaryCardModern({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.currency,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140, // Larger height for more space
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.07),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 18, bottom: 18, right: 8), // minimal left padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon far left
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 6), // minimal space between icon and text
            // All text left-aligned, fills the rest
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    currency + value.toStringAsFixed(2),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13, // smaller font as requested
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Modern Bottom Navigation Bar ---
class _ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavTabInfo> tabs;

  const _ModernBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    // Uniform color for selection: always blue!
    return Material(
      elevation: 12,
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                tabs.length,
                (i) {
                  final selected = i == currentIndex;
                  final tab = tabs[i];
                  final selectedTabColor = kSelectedNavColor; // always blue

                  return GestureDetector(
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: selected ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? selectedTabColor.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tab.emoji,
                            style: TextStyle(
                              fontSize: selected ? 22 : 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tab.label,
                            style: TextStyle(
                              color: selected ? selectedTabColor : Colors.grey,
                              fontWeight: selected ? FontWeight.bold : FontWeight.w400,
                              fontSize: selected ? 11.5 : 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Navigation Tab Info
class _NavTabInfo {
  final IconData icon;
  final String label;
  final String emoji;
  final Color color;
  const _NavTabInfo(
      {required this.icon,
      required this.label,
      required this.emoji,
      required this.color});
}

/// Placeholder for other tabs
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({required this.title, super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title Screen Coming Soon!',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}