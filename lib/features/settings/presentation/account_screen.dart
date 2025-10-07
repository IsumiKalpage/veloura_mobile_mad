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
import '../../../../core/theme/theme_provider.dart';
import '../../products/presentation/favorites_screen.dart';

final profileImageProvider = StateProvider<String?>((ref) => null);
final batteryLevelProvider = StateProvider<int?>((ref) => null);

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
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
            leading: Icon(Icons.home_outlined,
                color: Theme.of(context).iconTheme.color),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.storefront_outlined,
                color: Theme.of(context).iconTheme.color),
            title: const Text("Products"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart_outlined,
                color: Theme.of(context).iconTheme.color),
            title: const Text("Cart"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.person_outline,
                color: Theme.of(context).iconTheme.color),
            title: const Text("Account"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.inventory_2_outlined,
                color: Theme.of(context).iconTheme.color),
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
            leading: const Icon(Icons.favorite_border),
            title: const Text("Favorites"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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

    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
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
            icon: Icon(Icons.person_outline,
                color: Theme.of(context).iconTheme.color),
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
                color: Theme.of(context).cardColor,
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
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      backgroundImage: profileImagePath != null
                          ? FileImage(File(profileImagePath))
                          : null,
                      child: profileImagePath == null
                          ? Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user["email"] ?? "",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionHeader(context, "Update your info"),
            _buildCard(context, [
              _buildTile(context, Icons.person, "Account Information",
                  Colors.blue, () {}),
              _buildTile(context, Icons.credit_card, "Billing", Colors.green,
                  () {}),
            ]),

            const SizedBox(height: 20),

            _buildSectionHeader(context, "Preferences"),
            _buildCard(context, [
              _buildTile(context, Icons.notifications, "Notifications",
                  Colors.orange, () {}),
              _buildTile(
                context,
                isDark ? Icons.light_mode : Icons.dark_mode,
                isDark ? "Change to Light Mode" : "Change to Dark Mode",
                isDark ? Colors.yellow : Colors.purple,
                () {
                  final notifier = ref.read(themeModeProvider.notifier);
                  notifier.state =
                      isDark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
            ]),

            const SizedBox(height: 20),

            _buildSectionHeader(context, "More Information"),
            _buildCard(context, [
              _buildTile(context, Icons.info, "About Us", Colors.teal, () {}),
              _buildTile(context, Icons.privacy_tip, "Privacy",
                  Colors.deepPurple, () {}),
              _buildTile(context, Icons.contact_mail, "Contact Us",
                  Colors.indigo, () {}),
              _buildTile(context, Icons.location_on, "Show My Location",
                  Colors.red, () => _showMyLocation(context)),
              _buildTile(context, Icons.battery_full, "Toggle Battery Status",
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
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
            ]),

            const SizedBox(height: 20),

            _buildSectionHeader(context, "Account Actions"),
            _buildCard(context, [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.red.shade100,
                  child: const Icon(Icons.logout, color: Colors.red),
                ),
                title: const Text(
                  "Logout",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            "Logged Out",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          content: const Text(
                            "You have been successfully logged out.",
                            style: TextStyle(fontSize: 15),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.go('/welcome');
                              },
                              child: Text(
                                "OK",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.primary,
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.8),
              ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
              Divider(
                height: 1,
                thickness: 0.5,
                indent: 70,
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
          ]
        ],
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 16, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
      onTap: onTap,
    );
  }
}
