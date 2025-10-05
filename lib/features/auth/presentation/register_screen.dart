import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await ref.read(authStateProvider.notifier).register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _confirmController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<Map<String, dynamic>?>>(authStateProvider,
        (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
        setState(() => _isLoading = false);
      }
      if (next.hasValue && next.value != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful. Please login.")),
        );
        context.pop();
      }
    });

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    Widget form = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isLandscape) ...[
            Image.asset("assets/logo.png", height: 80),
            const SizedBox(height: 16),
          ],
          const Text(
            "Sign up for an Account",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Enter your details to create an account",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 30),

          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Full Name",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Name is required";
                    if (v.length < 2) return "Min 2 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Email is required";
                    if (!v.contains("@")) return "Enter a valid email";
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Password is required";
                    if (v.length < 6) return "At least 6 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: "Confirm Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Please confirm password";
                    if (v != _passwordController.text) {
                      return "Passwords don’t match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _register,
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(
                          text: "Log In",
                          style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLandscape
          ? Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Center(child: Image.asset("assets/logo.png", height: 120)),
                ),
                Expanded(
                  flex: 6,
                  child: form,
                ),
              ],
            )
          : Center(child: form),
    );
  }
}
