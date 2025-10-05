import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:battery_plus/battery_plus.dart';

import '../../auth/providers/auth_provider.dart';
import '../../orders/presentation/order_history_screen.dart';


final profileImageProvider = StateProvider<String?>((ref) => null);


final batteryLevelProvider = StateProvider<int?>((ref) => null);

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFA4161A)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/logo.png", height: 50),
                const SizedBox(height: 8),
                const Text(
                  "Welcome to Veloura",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.storefront_outlined),
            title: const Text("Products"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text("Cart"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Account"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text("Orders"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Contact Us"),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
      BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      ref.read(profileImageProvider.notifier).state = pickedFile.path;
    }

    Navigator.pop(context); 
  }

  void _showImageSourceActionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () => _pickImage(context, ref, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () => _pickImage(context, ref, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMyLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Location services are disabled.")),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Location permission denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("❌ Location permissions are permanently denied.")),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final lat = position.latitude;
    final lon = position.longitude;

    final Uri googleMapsUrl =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lon");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("📍 Your Location: $lat, $lon")),
      );
    }
  }

  Future<void> _toggleBatteryStatus(WidgetRef ref) async {
    final current = ref.read(batteryLevelProvider);
    if (current != null) {
      ref.read(batteryLevelProvider.notifier).state = null;
    } else {
      final battery = Battery();
      final level = await battery.batteryLevel;
      ref.read(batteryLevelProvider.notifier).state = level;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (authState.value == null || authState.value?["user"] == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    final user = authState.value!["user"];
    final fullName = (user["first_name"] != null && user["last_name"] != null)
        ? "${user["first_name"]} ${user["last_name"]}"
        : user["name"] ?? "Guest";

    final profileImagePath = ref.watch(profileImageProvider);
    final batteryLevel = ref.watch(batteryLevelProvider);

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: SizedBox(
          height: 40,
          child: Image.asset("assets/logo.png", fit: BoxFit.contain),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile tapped")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showImageSourceActionSheet(context, ref),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey,
                      backgroundImage: profileImagePath != null
                          ? FileImage(File(profileImagePath))
                          : null,
                      child: profileImagePath == null
                          ? const Icon(Icons.camera_alt,
                              size: 30, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user["email"] ?? "",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===== Sections =====
            _buildSectionHeader("Update your info"),
            _buildCard([
              _buildTile(Icons.person, "Account Information", Colors.blue, () {}),
              _buildTile(Icons.credit_card, "Billing", Colors.green, () {}),
            ]),

            const SizedBox(height: 20),

            _buildSectionHeader("Preferences"),
            _buildCard([
              _buildTile(
                  Icons.notifications, "Notifications", Colors.orange, () {}),
              _buildTile(Icons.dark_mode, "Change to Dark Mode", Colors.purple,
                  () {}),
            ]),

            const SizedBox(height: 20),

            _buildSectionHeader("More Information"),
            _buildCard([
              _buildTile(Icons.info, "About Us", Colors.teal, () {}),
              _buildTile(Icons.privacy_tip, "Privacy", Colors.deepPurple, () {}),
              _buildTile(Icons.contact_mail, "Contact Us", Colors.indigo, () {}),
              _buildTile(Icons.location_on, "Show My Location", Colors.red,
                  () => _showMyLocation(context)),
              _buildTile(Icons.battery_full, "Toggle Battery Status",
                  Colors.green, () => _toggleBatteryStatus(ref)),
              if (batteryLevel != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.battery_charging_full,
                          color: Colors.green),
                      const SizedBox(width: 10),
                      Text(
                        "Battery Level: $batteryLevel%",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
            ]),

            const SizedBox(height: 20),

            _buildSectionHeader("Account Actions"),
            _buildCard([
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.red.shade100,
                  child: const Icon(Icons.logout, color: Colors.red),
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            "Logged Out",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFA4161A),
                            ),
                          ),
                          content: const Text(
                            "You have been successfully logged out.",
                            style: TextStyle(fontSize: 15),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // close dialog
                                context.go('/welcome');
                              },
                              child: const Text(
                                "OK",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA4161A),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ]),


            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, thickness: 0.5, indent: 70),
          ]
        ],
      ),
    );
  }

  Widget _buildTile(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
      onTap: onTap,
    );
  }
}
