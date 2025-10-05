import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<Map<String, dynamic>?>>(
  (ref) => AuthNotifier(ref),
);

class AuthNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._ref) : super(const AsyncValue.data(null)) {
    _loadUser(); 
  }

  Future<void> _loadUser() async {
    final token = await _storage.read(key: "token");
    final userJson = await _storage.read(key: "user");

    if (token != null && userJson != null) {
      final user = jsonDecode(userJson) as Map<String, dynamic>;
      state = AsyncValue.data({
        "token": token,
        "user": user,
      });
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final data =
          await _ref.read(authRepositoryProvider).login(email, password);

      final token = data["token"];
      final user = data["user"];

      if (token != null && user != null) {
        await _storage.write(key: "token", value: token);
        await _storage.write(key: "user", value: jsonEncode(user));
      }

      state = AsyncValue.data({
        "token": token,
        "user": user,
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    state = const AsyncValue.loading();
    try {
      final data = await _ref
          .read(authRepositoryProvider)
          .register(name, email, password, confirmPassword);

      final token = data["token"];
      final user = data["user"];

      if (token != null && user != null) {
        await _storage.write(key: "token", value: token);
        await _storage.write(key: "user", value: jsonEncode(user));
      }

      state = AsyncValue.data({
        "token": token,
        "user": user,
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll(); 
    state = const AsyncValue.data(null);
  }
}
