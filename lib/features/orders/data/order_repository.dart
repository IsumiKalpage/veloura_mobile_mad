import 'package:dio/dio.dart';

class OrderRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:8000/api", 
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<Map<String, dynamic>>> fetchOrders(String token) async {
    final response = await _dio.get(
      "/orders",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        followRedirects: false,
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception(
        "Failed to load orders: ${response.statusCode} → ${response.data}",
      );
    }
  }

  Future<Map<String, dynamic>> createOrder(
      String token, Map<String, dynamic> order) async {
    try {
      final response = await _dio.post(
        "/orders",
        data: order,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          "Failed to create order: "
          "${response.statusCode} → ${response.data}",
        );
      }
    } on DioException catch (e) {
      throw Exception("Dio error: ${e.response?.data ?? e.message}");
    }
  }
}
