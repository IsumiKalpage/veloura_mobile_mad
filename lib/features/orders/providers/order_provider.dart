import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

final orderProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, email) async {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null || authState["token"] == null) return [];

  final token = authState["token"];
  return ref.read(orderRepositoryProvider).fetchOrders(token);
});

final placeOrderProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, orderData) async {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null || authState["token"] == null) {
    throw Exception("Not authenticated");
  }

  final token = authState["token"];
  await ref.read(orderRepositoryProvider).createOrder(token, orderData);
});
