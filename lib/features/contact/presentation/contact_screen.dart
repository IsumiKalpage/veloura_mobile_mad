import 'dart:ui';
import 'package:flutter/material.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final messageCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = const Color(0xFFA4161A);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 1,
        title: SizedBox(
          height: 40,
          child: Image.asset("assets/logo.png", fit: BoxFit.contain),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Logo Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark
                    ? Colors.grey[850]!.withOpacity(0.6)
                    : Colors.white.withOpacity(0.3),
              ),
              child: Image.asset("assets/logo.png", height: 80),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              "Get in Touch",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              "We’d love to hear from you! Whether you have a question, feedback, or need assistance — feel free to reach out.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),

            // Contact info with glass effect
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey[850]!.withOpacity(0.5)
                        : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: const [
                      _ContactInfoTile(
                        icon: Icons.email_outlined,
                        title: "Email",
                        detail: "support@veloura.com",
                      ),
                      SizedBox(height: 12),
                      _ContactInfoTile(
                        icon: Icons.phone_outlined,
                        title: "Phone",
                        detail: "+94 71 234 5678",
                      ),
                      SizedBox(height: 12),
                      _ContactInfoTile(
                        icon: Icons.location_on_outlined,
                        title: "Address",
                        detail: "123 Veloura Street, Colombo, Sri Lanka",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Contact Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black),
                    decoration: _inputDecoration("Full Name", isDark),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter your name" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailCtrl,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black),
                    decoration: _inputDecoration("Email Address", isDark),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Enter your email";
                      if (!v.contains("@")) return "Enter a valid email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: messageCtrl,
                    maxLines: 4,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black),
                    decoration: _inputDecoration("Your Message", isDark),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter a message" : null,
                  ),
                  const SizedBox(height: 24),

                  // Send button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text("Message sent successfully 💌"),
                            backgroundColor: primary,
                          ),
                        );
                        nameCtrl.clear();
                        emailCtrl.clear();
                        messageCtrl.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      "Send Message",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          TextStyle(color: isDark ? Colors.white70 : Colors.black87),
      filled: true,
      fillColor: isDark ? Colors.grey[850] : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFA4161A)),
      ),
    );
  }
}

class _ContactInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _ContactInfoTile({
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor:
              const Color(0xFFA4161A).withOpacity(isDark ? 0.25 : 0.15),
          child: Icon(icon, color: const Color(0xFFA4161A)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
