import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
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

class ProductsNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  ProductsNotifier(this._dio, this.filter) : super(const AsyncValue.loading());

  final Dio _dio;
  ProductFilter filter;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _products = [];

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

      if (refresh) {
        _products.clear();
      }
      _products.addAll(newProducts);

      final currentPage = data["current_page"] ?? 1;
      final lastPage = data["last_page"] ?? 1;

      _hasMore = currentPage < lastPage;
      if (_hasMore) _currentPage++;

      state = AsyncValue.data(List.from(_products));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
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
