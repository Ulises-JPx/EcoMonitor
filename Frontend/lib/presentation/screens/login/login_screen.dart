import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/presentation/state/auth_provider.dart';
import 'package:frontend/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Call AuthProvider
      Future.delayed(const Duration(seconds: 1), () {
        Provider.of<AuthProvider>(context, listen: false).login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        setState(() => _isLoading = false);

        // Navigate to Home
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.agriculture, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                const Text(
                  AppStrings.loginTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                const SizedBox(height: 32),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.emailLabel,
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!value.contains("@")) {
                      return "Invalid email format";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: AppStrings.passwordLabel,
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Login Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text(AppStrings.loginButton),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}