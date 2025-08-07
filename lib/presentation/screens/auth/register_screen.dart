import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
// import '../home/home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  String? _error;
  bool _loading = false;

  Future<void> _register() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final username = _usernameController.text.trim();
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    await Future.delayed(const Duration(milliseconds: 600)); // For effect

    if (username.isEmpty || pin.isEmpty || confirmPin.isEmpty) {
      setState(() {
        _error = "Please fill all fields";
        _loading = false;
      });
      return;
    }
    if (pin.length < 4) {
      setState(() {
        _error = "PIN should be at least 4 digits";
        _loading = false;
      });
      return;
    }
    if (pin != confirmPin) {
      setState(() {
        _error = "PINs do not match";
        _loading = false;
      });
      return;
    }

    var box = await Hive.openBox('auth');
    await box.put('username', username);
    await box.put('pin', pin);

    setState(() {
      _loading = false;
    });

    // Show success dialog and then go to login screen
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Account Created!'),
          content: const Text('Your account was created successfully.\nPlease login to continue.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_alt_1_rounded,
                    color: theme.primaryColor, size: 56),
                const SizedBox(height: 14),
                Text(
                  "Create Account",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  "Register for CashWise",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 38),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _pinController,
                  decoration: InputDecoration(
                    labelText: "PIN",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18)),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePin
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.grey),
                      onPressed: () =>
                          setState(() => _obscurePin = !_obscurePin),
                    ),
                  ),
                  obscureText: _obscurePin,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _confirmPinController,
                  decoration: InputDecoration(
                    labelText: "Confirm PIN",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18)),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscureConfirmPin
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.grey),
                      onPressed: () =>
                          setState(() => _obscureConfirmPin = !_obscureConfirmPin),
                    ),
                  ),
                  obscureText: _obscureConfirmPin,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _register(),
                ),
                const SizedBox(height: 8),
                _error != null
                    ? Text(_error!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14))
                    : const SizedBox.shrink(),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_rounded),
                    label: Text(
                      _loading ? "Registering..." : "Register",
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _loading ? null : _register,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text("Login"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}