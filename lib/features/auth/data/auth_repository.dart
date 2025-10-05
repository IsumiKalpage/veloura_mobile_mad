import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print("🔵 Sending login request: $email");
      final response = await _dio.post(
        "/login",
        data: {
          "email": email,
          "password": password,
        },
      );
      print("🟢 Login response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      print("🔴 Login error: ${e.response?.data}");
      final msg = e.response?.data?["message"] ?? e.message ?? "Login failed";
      throw Exception("Login failed: $msg");
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String confirmPassword) async {
    try {
      final response = await _dio.post(
        "/register",
        data: {
          "name": name,
          "email": email,
          "password": password,
          "password_confirmation": confirmPassword,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Registration failed");
    }
  }
}
