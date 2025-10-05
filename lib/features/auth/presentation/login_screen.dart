import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await ref
        .read(authStateProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text.trim());
  }

  void _goToRegister() {
    context.push('/register');
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
        context.go('/home');
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
            "Login to your Account",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Enter your email and password to log in",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 30),

          Form(
            key: _formKey,
            child: Column(
              children: [
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: AppTheme.primaryColor,
                          onChanged: (val) {
                            setState(() => _rememberMe = val ?? false);
                          },
                        ),
                        const Text("Remember me"),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
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
                        onPressed: _login,
                        child: const Text(
                          "Log In",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Or login with"),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(Icons.g_mobiledata, Colors.red),
                    const SizedBox(width: 20),
                    _socialButton(Icons.facebook, Colors.blue),
                  ],
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _goToRegister,
                  child: const Text.rich(
                    TextSpan(
                      text: "Don’t have an account? ",
                      style: TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(
                          text: "Sign Up",
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

  Widget _socialButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: color, size: 30),
      ),
    );
  }
}
