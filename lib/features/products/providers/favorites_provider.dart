import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Map<String, dynamic>>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FavoritesNotifier() : super([]);

  String? _currentUserEmail;

  Future<void> loadFavorites(String? email) async {
    if (email == null || email.isEmpty) {
      state = [];
      return;
    }

    _currentUserEmail = email;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('favorites_$email');
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      state = List<Map<String, dynamic>>.from(decoded);
    } else {
      state = [];
    }
  }

  Future<void> _saveFavorites() async {
    if (_currentUserEmail == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorites_$_currentUserEmail', jsonEncode(state));
  }

  void toggleFavorite(Map<String, dynamic> product) async {
    final exists = state.any((p) => p['id'] == product['id']);
    if (exists) {
      state = state.where((p) => p['id'] != product['id']).toList();
    } else {
      state = [...state, product];
    }
    await _saveFavorites();
  }

  bool isFavorite(String productId) {
    return state.any((p) => p['id'].toString() == productId);
  }

  void clearFavorites() {
    state = [];
  }
}
