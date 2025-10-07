import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../auth/providers/auth_provider.dart';
import '../../products/presentation/product_detail_screen.dart';
import '../../products/providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider).value;
    final email = authState?["user"]?["email"] ?? "";

    ref.read(favoritesProvider.notifier).loadFavorites(email);
    final favorites = ref.watch(favoritesProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: const Text(
          "My Favorites",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: favorites.isEmpty
          ? Center(
              child: Text(
                "No favorite products yet 💔",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favorites.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final product = favorites[index];
                return _favoriteCard(context, ref, product, isDark);
              },
            ),
    );
  }

  Widget _favoriteCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> product,
    bool isDark,
  ) {
    final imageUrl = product["image_url"] ??
        product["image"] ??
        product["image_path"] ??
        "https://via.placeholder.com/200";

    final double price = _parseDouble(product["price"]);
    final double discount = _parseDouble(product["discount"]);
    final double rating = _parseDouble(product["rating"]);
    final int stock = int.tryParse(product["stock"].toString()) ?? 0;

    String stockLabel;
    Color stockColor;

    if (stock == 0) {
      stockLabel = "Out of Stock";
      stockColor = Colors.grey;
    } else if (stock <= 5) {
      stockLabel = "Low Stock";
      stockColor = Colors.amber;
    } else {
      stockLabel = "In Stock";
      stockColor = Colors.green;
    }

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
        color: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isDark ? 0 : 3,
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(product);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Removed from Favorites 💔"),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      },
                      child: const Icon(Icons.favorite, color: Colors.red, size: 26),
                    ),
                  ),
                  if (percentOff > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (percentOff > 0) ...[
                    Text(
                      "Rs.${price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.grey,
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
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: stockColor),
                      const SizedBox(width: 6),
                      Text(
                        stockLabel,
                        style: TextStyle(
                          color: stockColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

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
