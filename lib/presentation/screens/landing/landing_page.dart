import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'package:hive/hive.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  Future<bool> _hasAccount() async {
    var box = await Hive.openBox('auth');
    return box.get('username') != null && box.get('pin') != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: FutureBuilder<bool>(
        future: _hasAccount(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  // Lottie animation or network image
                  SizedBox(
                    height: 150,
                    child: Lottie.network(
                      'https://assets2.lottiefiles.com/packages/lf20_yr6zz3wv.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    "Welcome to MyCashWise",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF185A9D),
                      fontWeight: FontWeight.w700,
                      fontSize: 25,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Empower your financial journey! Track your Kwachas, manage your budgets, and reach your goals — all in one beautiful app.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      fontSize: 15.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 38),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF185A9D),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      onPressed: () {
                        if (snapshot.data == true) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Get Started"),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_rounded, color: Colors.grey[500], size: 18),
                        const SizedBox(width: 7),
                        Text(
                          "Copyright © 2025 Moses Siame",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}