import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/order_provider.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider).value;
    final email = authState?["user"]?["email"] ?? "";

    final ordersAsync = ref.watch(orderProvider(email));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 233, 175, 177),
                Color.fromARGB(255, 234, 204, 207)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                "No orders found.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final createdAt = order["created_at"] ?? "";
              final status = order["status"] ?? "unknown";
              final total = order["total"]?.toString() ?? "0.00";

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order: order),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order #${order["_id"] ?? ""}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Placed on: $createdAt",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: status == "pending"
                                ? Colors.orange
                                : status == "shipped"
                                    ? Colors.blue
                                    : Colors.green,
                          ),
                        ),

                        const Divider(height: 20),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Total: Rs. $total",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFA4161A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text("Error: $err"),
        ),
      ),
    );
  }
}
