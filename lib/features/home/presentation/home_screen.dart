import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/presentation/products_screen.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../settings/presentation/account_screen.dart';
import '../../cart/providers/cart_provider.dart';
import '../../products/providers/products_provider.dart';
import '../../products/presentation/product_detail_screen.dart';
import '../../orders/presentation/order_history_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _DashboardScreen(),
    ProductsScreen(),
    CartScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Drawer _buildDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : const Color(0xFFA4161A),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/logo.png", height: 50),
                const SizedBox(height: 8),
                Text(
                  "Welcome to Veloura",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          _drawerTile(Icons.home_outlined, "Home", () => setState(() => _selectedIndex = 0), isDark),
          _drawerTile(Icons.storefront_outlined, "Products", () => setState(() => _selectedIndex = 1), isDark),
          _drawerTile(Icons.shopping_cart_outlined, "Cart", () => setState(() => _selectedIndex = 2), isDark),
          _drawerTile(Icons.person_outline, "Account", () => setState(() => _selectedIndex = 3), isDark),
          ListTile(
            leading: Icon(Icons.inventory_2_outlined,
                color: isDark ? Colors.white70 : Colors.black87),
            title: Text("Orders",
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  ListTile _drawerTile(IconData icon, String text, VoidCallback onTap, bool isDark) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
      title: Text(text,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          )),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartItems = ref.watch(userCartProvider);
    final totalItems = cartItems.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              elevation: 1,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu,
                      color: isDark ? Colors.white70 : Colors.black87),
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
                      color: isDark ? Colors.white70 : Colors.black87),
                  onPressed: () {
                    setState(() => _selectedIndex = 3);
                  },
                ),
              ],
            )
          : null,
      drawer: _selectedIndex == 0 ? _buildDrawer(context) : null,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFA4161A),
        unselectedItemColor: isDark ? Colors.white70 : Colors.black54,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            label: "Products",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (totalItems > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        "$totalItems",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: "Cart",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Account",
          ),
        ],
      ),
    );
  }
}

class _DashboardScreen extends ConsumerWidget {
  const _DashboardScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFFA4161A)),
      ),
      error: (e, _) => Center(
          child: Text("Error loading products: $e",
              style: TextStyle(color: isDark ? Colors.white : Colors.black))),
      data: (all) {
        final sorted = List<Map<String, dynamic>>.from(all);
        sorted.sort((a, b) {
          final da = DateTime.tryParse(a['created_at']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final db = DateTime.tryParse(b['created_at']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return db.compareTo(da);
        });

        final latest6 = sorted.take(6).toList();

        final discountedSorted = sorted.where((p) {
          final discount = _parseDouble(p['discount']);
          return discount > 0;
        }).toList();

        discountedSorted.sort((a, b) {
          final da = _parseDouble(a['discount']);
          final db = _parseDouble(b['discount']);
          return db.compareTo(da);
        });

        final discounted6 = discountedSorted.take(6).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/b2.png",
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                "Latest Products",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFFA4161A),
                ),
              ),
              const SizedBox(height: 12),
              _productGrid(context, latest6,
                  showDiscountTag: true, showRating: true),

              const SizedBox(height: 28),

              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/b1.png",
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 28),

              Text(
                "Discounted Products",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFFA4161A),
                ),
              ),
              const SizedBox(height: 12),
              _productGrid(context, discounted6, showDiscountTag: true),
            ],
          ),
        );
      },
    );
  }

  Widget _productGrid(
    BuildContext context,
    List<Map<String, dynamic>> products, {
    bool showDiscountTag = false,
    bool showRating = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (products.isEmpty) {
      return Text("No products available.",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1000
        ? 4
        : screenWidth > 700
            ? 3
            : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 280,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        final double price = _parseDouble(p['price']);
        final double discount = _parseDouble(p['discount']);
        final double rating = _parseDouble(p['rating']);

        int percentOff = 0;
        double finalPrice = price;

        if (discount > 0) {
          if (discount < 100) {
            percentOff = discount.round();
            finalPrice = price - (price * discount / 100);
          } else {
            percentOff = ((discount / price) * 100).round();
            finalPrice = price - discount;
          }
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: p),
              ),
            );
          },
          child: Card(
            color: isDark ? Colors.grey[900] : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: isDark ? 0 : 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: Image.network(
                          _fullImageUrl(_pickBestImage(p)),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                      if (showDiscountTag && percentOff > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "-$percentOff%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['name'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black),
                      ),
                      const SizedBox(height: 4),
                      if (percentOff > 0) ...[
                        Text(
                          "Rs.${price.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          "Rs.${finalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA4161A),
                          ),
                        ),
                      ] else
                        Text(
                          "Rs.${price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA4161A),
                          ),
                        ),
                      if (showRating) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    final str = value.toString().trim();
    if (str.isEmpty || str.toLowerCase() == "null") return 0.0;
    return double.tryParse(str) ?? 0.0;
  }

  static dynamic _pickBestImage(Map<String, dynamic> p) {
    final img =
        p['image'] ?? p['image_url'] ?? p['thumbnail'] ?? p['image_path'];
    if (img != null) return img;

    final imgs = p['images'];
    if (imgs is List && imgs.isNotEmpty) return imgs.first;

    return null;
  }

  static String _fullImageUrl(dynamic imagePath) {
    if (imagePath == null || imagePath.toString().isEmpty) {
      return "https://via.placeholder.com/300x200?text=No+Image";
    }
    final path = imagePath.toString();
    if (path.startsWith("http")) return path;
    return "http://10.0.2.2:8000/$path";
  }
}
