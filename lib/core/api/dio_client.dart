import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio dio;
  final _storage = const FlutterSecureStorage();

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://10.0.2.2:8000/api", 
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Accept": "application/json"},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: "token");
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print("Dio error: ${e.response?.statusCode} ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }
}

final dioClientProvider = Provider<Dio>((ref) {
  return DioClient().dio;
});
