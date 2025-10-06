import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cart/providers/cart_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int quantity = 1;
  bool isWishlisted = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final imageUrl = product["image_url"] ??
        product["image"] ??
        product["image_path"] ??
        "https://via.placeholder.com/300";

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

    final double savings = price - finalPrice;

    final authState = ref.watch(authStateProvider).value;
    final email = authState?["user"]?["email"] ?? "";

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final theme = Theme.of(context);
    // ignore: unused_local_variable
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: isLandscape
          ? Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error,
                                color: Colors.red, size: 80),
                      ),
                      if (percentOff > 0)
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "-$percentOff%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: Icon(
                                    isWishlisted
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    setState(
                                        () => isWishlisted = !isWishlisted);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: _buildDetails(
                      context,
                      product,
                      price,
                      finalPrice,
                      savings,
                      percentOff,
                      rating,
                      email),
                ),
              ],
            )
          : Stack(
              children: [
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 340,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: Colors.red, size: 80),
                    ),
                    if (percentOff > 0)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "-$percentOff%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon:
                                const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              setState(() => isWishlisted = !isWishlisted);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.65,
                  minChildSize: 0.65,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) {
                    return _buildDetails(
                        context,
                        product,
                        price,
                        finalPrice,
                        savings,
                        percentOff,
                        rating,
                        email,
                        scrollController: scrollController);
                  },
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
          label: const Text(
            "Add to Cart",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA4161A),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            if (email.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("You must be logged in to add items.")),
              );
              return;
            }

            ref.read(cartProvider.notifier).addToCart(email, product, quantity);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Added $quantity item(s) to cart")),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    Map<String, dynamic> product,
    double price,
    double finalPrice,
    double savings,
    int percentOff,
    double rating,
    String email, {
    ScrollController? scrollController,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product["name"] ?? "No name",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (percentOff > 0) ...[
              Text(
                "Rs.${price.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Text(
                "Rs.${finalPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFA4161A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "You saved Rs.${savings.toStringAsFixed(2)} 🎉",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ] else
              Text(
                "Rs.${price.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA4161A),
                ),
              ),
            const SizedBox(height: 12),

            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < rating.round()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Text(
                  "Quantity:",
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.dividerColor.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                      ),
                      Text(
                        "$quantity",
                        style: TextStyle(
                            fontSize: 16, color: textColor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() => quantity++);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              "Description",
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              product["description"] ??
                  "No description available for this product.",
              style: theme.textTheme.bodyMedium
                  ?.copyWith(height: 1.5, color: textColor),
            ),
            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.local_shipping,
                      color: Colors.orange),
                  title: Text("Delivery Charge LKR 350",
                      style: TextStyle(color: textColor)),
                ),
                ListTile(
                  leading:
                      const Icon(Icons.verified, color: Colors.green),
                  title: Text("Guaranteed 100% Authentic Products",
                      style: TextStyle(color: textColor)),
                ),
                ListTile(
                  leading: const Icon(Icons.public, color: Colors.blue),
                  title: Text("Imported from South Korea",
                      style: TextStyle(color: textColor)),
                ),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.amber),
                  title: Text("Secure payments",
                      style: TextStyle(color: textColor)),
                ),
              ],
            ),
            const SizedBox(height: 100),
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
