import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class CartItem {
  final Map<String, dynamic> product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

class CartNotifier extends StateNotifier<Map<String, List<CartItem>>> {
  CartNotifier() : super({});

  List<CartItem> getUserCart(String email) {
    return state[email] ?? [];
  }

  void addToCart(String email, Map<String, dynamic> product, int qty) {
    final userCart = List<CartItem>.from(state[email] ?? []);
    final index =
        userCart.indexWhere((item) => item.product["id"] == product["id"]);

    if (index >= 0) {
      userCart[index].quantity += qty;
    } else {
      userCart.add(CartItem(product: product, quantity: qty));
    }

    state = {...state, email: userCart};
  }

  void removeFromCart(String email, Map<String, dynamic> product) {
    final userCart =
        (state[email] ?? []).where((item) => item.product["id"] != product["id"]).toList();
    state = {...state, email: userCart};
  }

  void updateQuantity(String email, Map<String, dynamic> product, int qty) {
    final userCart = List<CartItem>.from(state[email] ?? []);
    final index =
        userCart.indexWhere((item) => item.product["id"] == product["id"]);
    if (index >= 0) {
      userCart[index].quantity = qty;
    }
    state = {...state, email: userCart};
  }

  double getFinalPrice(Map<String, dynamic> product) {
    final double price = _parseDouble(product["price"]);
    final double discount = _parseDouble(product["discount"]);

    if (discount > 0) {
      if (discount < 100) {
        return price - (price * discount / 100);
      } else {
        return price - discount;
      }
    }
    return price;
  }

  double totalPrice(String email) {
    return (state[email] ?? []).fold(0.0, (sum, item) {
      final double finalPrice = getFinalPrice(item.product);
      return sum + (finalPrice * item.quantity);
    });
  }

  int totalItems(String email) {
    return (state[email] ?? []).fold(0, (sum, item) => sum + item.quantity);
  }

  void clearUserCart(String email) {
    state = {...state, email: []};
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, List<CartItem>>>(
        (ref) => CartNotifier());

final userCartProvider = Provider<List<CartItem>>((ref) {
  final authState = ref.watch(authStateProvider).value;
  final email = authState?["user"]?["email"];
  final allCarts = ref.watch(cartProvider);

  if (email == null) return [];
  return allCarts[email] ?? [];
});
