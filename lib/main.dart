import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/models/transaction_model.dart';
import 'data/models/budget_model.dart';
import 'data/models/account_model.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/budget_provider.dart';
import 'presentation/providers/account_provider.dart';
import 'presentation/screens/landing/landing_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register Hive adapters for each model with unique typeIds
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(AccountModelAdapter());

  // Open all necessary Hive boxes
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<BudgetModel>('budgets');
  await Hive.openBox<AccountModel>('accounts');
  await Hive.openBox('auth'); // Ensure 'auth' box is opened for the landing page

  runApp(const CashWiseApp());
}

class CashWiseApp extends StatelessWidget {
  const CashWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        // TransactionProvider needs AccountProvider and BudgetProvider reference for updates
        ChangeNotifierProxyProvider2<AccountProvider, BudgetProvider, TransactionProvider>(
          create: (_) => TransactionProvider(),
          update: (_, accountProvider, budgetProvider, txnProvider) {
            txnProvider!.setAccountProvider(accountProvider);
            txnProvider.setBudgetProvider(budgetProvider);
            return txnProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'MyCashWise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LandingPage(),
      ),
    );
  }
}