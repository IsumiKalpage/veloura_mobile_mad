import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../core/api/dio_client.dart';

class ProductFilter {
  final String category;
  final String? brand;
  final double? minPrice;
  final double? maxPrice;
  final int? rating;

  const ProductFilter({
    this.category = "all",
    this.brand,
    this.minPrice,
    this.maxPrice,
    this.rating,
  });

  Map<String, dynamic> toQueryParams(int page) {
    final params = <String, dynamic>{"page": page};
    if (category != "all") params["category"] = category;
    if (brand != null && brand!.isNotEmpty) params["brand"] = brand;
    if (minPrice != null) params["min_price"] = minPrice;
    if (maxPrice != null) params["max_price"] = maxPrice;
    if (rating != null) params["rating"] = rating;
    return params;
  }
}

class ProductsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  ProductsNotifier(this._dio, this.filter)
      : super(const AsyncValue.loading());

  final Dio _dio;
  ProductFilter filter;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isOffline = false; 

  bool get isOffline => _isOffline;

  final List<Map<String, dynamic>> _products = [];

  Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/products_cache.json');
  }

  Future<void> _saveToLocalFile(List<Map<String, dynamic>> data) async {
    try {
      final file = await _localFile();
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> _loadLocalFallback() async {
    try {
      final file = await _localFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        return List<Map<String, dynamic>>.from(jsonDecode(raw));
      } else {
        final raw =
            await rootBundle.loadString('assets/products_fallback.json');
        final List list = jsonDecode(raw) as List;
        return List<Map<String, dynamic>>.from(
          list.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }
    } catch (_) {
      return [];
    }
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _products.clear();
      state = const AsyncValue.loading();
    }

    try {
      final response = await _dio.get(
        "/products",
        queryParameters: filter.toQueryParams(_currentPage),
      );

      final data = response.data;
      final List<Map<String, dynamic>> newProducts =
          List<Map<String, dynamic>>.from(data["data"] ?? []);

      if (refresh) _products.clear();
      _products.addAll(newProducts);

      final currentPage = data["current_page"] ?? 1;
      final lastPage = data["last_page"] ?? 1;
      _hasMore = currentPage < lastPage;
      if (_hasMore) _currentPage++;

      _isOffline = false; 

      state = AsyncValue.data(List.from(_products));


      await _saveToLocalFile(_products);
    } catch (e, st) {
      final cachedProducts = await _loadLocalFallback();
      if (cachedProducts.isNotEmpty) {
        _isOffline = true; 
        state = AsyncValue.data(List.from(cachedProducts));
      } else {
        _isOffline = false;
        state = AsyncValue.error("Failed to load products: $e", st);
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadMore() async {
    if (_hasMore && !_isLoading) {
      await loadProducts();
    }
  }

  Future<void> applyFilter(ProductFilter newFilter) async {
    filter = newFilter;
    await loadProducts(refresh: true);
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final dio = DioClient().dio;
  final notifier = ProductsNotifier(dio, const ProductFilter());
  notifier.loadProducts();
  return notifier;
});
