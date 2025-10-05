import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/products_provider.dart';
import '../presentation/product_detail_screen.dart';
import '../../orders/presentation/order_history_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String selectedCategory = "all";
  String? brand;
  double? minPrice;
  double? maxPrice;
  int? rating;

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
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text("Contact Us"),
            onTap: () => Navigator.pop(context),
          ),          
        ],
      ),
    );
  }

  void _openFilterSheet() {
    final brandController = TextEditingController(text: brand ?? "");
    final minController = TextEditingController(text: minPrice?.toString() ?? "");
    final maxController = TextEditingController(text: maxPrice?.toString() ?? "");
    int? tempRating = rating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Filters",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  TextField(
                    controller: brandController,
                    decoration: const InputDecoration(
                      labelText: "Brand",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Min Price",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Max Price",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<int>(
                    value: tempRating ?? 0,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Minimum Rating",
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int>(value: 0, child: Text("Any")),
                      ...List.generate(
                        5,
                        (i) => DropdownMenuItem<int>(
                          value: i + 1,
                          child: Text("${i + 1} stars"),
                        ),
                      ),
                    ],
                    onChanged: (val) =>
                        setModalState(() => tempRating = (val == 0 ? null : val)),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            brand = null;
                            minPrice = null;
                            maxPrice = null;
                            rating = null;
                          });
                          ref.read(productsProvider.notifier).applyFilter(
                                const ProductFilter(),
                              );
                          Navigator.pop(context);
                        },
                        child: const Text("Clear"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            brand = brandController.text.isNotEmpty
                                ? brandController.text
                                : null;
                            minPrice = minController.text.isNotEmpty
                                ? double.tryParse(minController.text)
                                : null;
                            maxPrice = maxController.text.isNotEmpty
                                ? double.tryParse(maxController.text)
                                : null;
                            rating = tempRating;
                          });
                          ref.read(productsProvider.notifier).applyFilter(
                                ProductFilter(
                                  category: selectedCategory,
                                  brand: brand,
                                  minPrice: minPrice,
                                  maxPrice: maxPrice,
                                  rating: rating,
                                ),
                              );
                          Navigator.pop(context);
                        },
                        child: const Text("Apply"),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

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
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _categoryChip("All", "all"),
                _categoryChip("Skincare", "skincare"),
                _categoryChip("Haircare", "haircare"),
                _categoryChip("Cosmetics", "cosmetics"),
              ],
            ),
          ),

          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text("No products found"));
                }

                final screenWidth = MediaQuery.of(context).size.width;
                final crossAxisCount = screenWidth > 1000
                    ? 4
                    : screenWidth > 700
                        ? 3
                        : 2;

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      ref.read(productsProvider.notifier).loadMore();
                    }
                    return false;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _productCard(product);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, String value) {
    final isSelected = selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFFA4161A),
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
        onSelected: (_) {
          setState(() {
            selectedCategory = value;
          });
          ref.read(productsProvider.notifier).applyFilter(
                ProductFilter(
                  category: value,
                  brand: brand,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                  rating: rating,
                ),
              );
        },
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> product) {
    final imageUrl = product["image_url"] ??
        product["image"] ??
        product["image_path"] ??
        "https://via.placeholder.com/200";

    final double price = _parseDouble(product["price"]);
    final double discount = _parseDouble(product["discount"]);
    final double rating = _parseDouble(product["rating"]);

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
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                  if (percentOff > 0)
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["name"] ?? "No name",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (percentOff > 0) ...[
                    Text(
                      "Rs.${price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
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
                        color: Color(0xFFA4161A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < rating.round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    final str = value.toString().trim();
    if (str.isEmpty || str.toLowerCase() == "null") return 0.0;
    return double.tryParse(str) ?? 0.0;
  }
}
