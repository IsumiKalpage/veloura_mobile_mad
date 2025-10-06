import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = (order["items"] is List)
        ? order["items"] as List
        : (order["items"] as Map).values.toList();

    final subtotal = double.tryParse(order["subtotal"].toString()) ?? 0.0;
    final shipping = double.tryParse(order["shipping"].toString()) ?? 0.0;
    final tax = double.tryParse(order["tax"].toString()) ?? 0.0;
    final total = double.tryParse(order["total"].toString()) ?? 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF3A3A3A), const Color(0xFF2C2C2C)]
                  : [
                      const Color.fromARGB(255, 233, 175, 177),
                      const Color.fromARGB(255, 234, 204, 207)
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            isDark,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order #${order["_id"] ?? ""}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 6),
                Text(
                  "Status: ${order["status"] ?? "unknown"}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: (order["status"] == "pending")
                        ? Colors.orange
                        : (order["status"] == "shipped")
                            ? Colors.blue
                            : Colors.green,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Placed on: ${order["created_at"] ?? ""}",
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text("Items",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 12),

          ...items.map((item) {
            final price = double.tryParse(item["price"].toString()) ?? 0.0;
            final qty = int.tryParse(item["quantity"].toString()) ?? 1;
            final lineTotal = price * qty;

            return Card(
              color: isDark ? Colors.grey[900] : Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: isDark ? 0 : 2,
              child: ListTile(
                title: Text(
                  item["name"] ?? "Unknown product",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  "Qty: $qty • Rs.${price.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87),
                ),
                trailing: Text(
                  "Rs.${lineTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA4161A),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          Text("Payment Summary",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 12),
          _buildCard(
            isDark,
            Column(
              children: [
                _summaryRow("Subtotal", subtotal, isDark: isDark),
                _summaryRow("Shipping", shipping, isDark: isDark),
                _summaryRow("Tax", tax, isDark: isDark),
                const Divider(),
                _summaryRow("Total", total, isTotal: true, isDark: isDark),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text("Shipping Address",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 12),
          _buildCard(
            isDark,
            Text(
              "${order["shipping_address"] ?? "N/A"}\n"
              "${order["shipping_city"] ?? ""}, ${order["shipping_district"] ?? ""}\n"
              "Postal: ${order["shipping_postal"] ?? ""}",
              style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),

          const SizedBox(height: 20),

          Text("Billing Address",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 12),
          _buildCard(
            isDark,
            Text(
              "${order["billing_address"] ?? "N/A"}\n"
              "${order["billing_city"] ?? ""}, ${order["billing_district"] ?? ""}\n"
              "Postal: ${order["billing_postal"] ?? ""}",
              style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(bool isDark, Widget child) {
    return Card(
      color: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isDark ? 0 : 3,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget _summaryRow(String label, double value,
      {bool isTotal = false, bool isDark = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 16 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87)),
          Text(
            "Rs.${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color:
                  isTotal ? const Color(0xFFA4161A) : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
