import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../constants/app_url.dart';
import '../../constants/reuseable.dart';
import '../../core/model/product_model.dart';
import '../../core/model/product_history_model.dart';
import '../../locator.dart';
import '../../utils/snack_message.dart';
import '../local/user_service.dart';
import 'base_api.dart';

class ProductApiService {
  final CustomerService customerService = locator<CustomerService>();

  Future<String?> _getToken() async {
    final box = GetStorage();
    String? token = box.read(DbTable.tokenTableName);
    if (token == null) {
      showCustomToast('No authentication token found.');
      return null;
    }
    return token;
  }

  Future<bool> checkProductExistence(String code, String storeId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await connect().get(
        'products/check-code/$code/$storeId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final exists = response.data['data']['exists'] ?? false;
        print(
            'Check Product Existence: Code=$code, Store=$storeId, Exists=$exists');
        return exists;
      }
      return false;
    } catch (e) {
      print('Error checking product existence: $e');
      showCustomToast('Failed to check product existence.');
      return false;
    }
  }

  Future<Product?> getProductById(String id, String storeId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await connect().get(
        'products/$id/$storeId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Fetched Product: ${response.data}');
        return Product.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching product by ID: $e');
      showCustomToast('Failed to fetch product details.');
      return null;
    }
  }
  Future<Product?> getProductByCode(String code, String storeId) async {
    try {
      Response response = await connect().get(
        '/products/code/$code',
        queryParameters: {'storeId': storeId},
      );
      return Product.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
  Future<AddProductResponse?> scanAndAddProduct({
    required Product data,
    required String scannedCode,
    required String storeId,
    required String ownerId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final payload = {
        'name': data.name ?? '',
        'code': scannedCode,
        'category': data.category ?? 'Uncategorized',
        'price': data.price ?? 0,
        'costPrice': data.costPrice ?? 0,
        'quantity': data.quantity ?? 1,
        'size': data.size,
        'expiryDate': data.expiryDate,
        'brands': data.brands,
        'storeId': storeId,
        // 'minQuantity': data.minQuantity ?? 0,
        'description': data.description,
      };

      final response = await connect().post(
        'products/add',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('ScanAndAdd Response: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddProductResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('DioError Adding Product: ${e.response?.data}');
      showCustomToast(e.response?.data['message'] ?? 'Failed to add product.');
      return null;
    } catch (e) {
      print('Error adding product: $e');
      showCustomToast('Error adding product.');
      return null;
    }
  }

  Future<Product?> updateProduct(
      String id, Product data, String storeId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final payload = data.toJson()
        ..remove('_id')
        ..remove('createdAt')
        ..remove('updatedAt');
      final response = await connect().patch(
        'products/$id/$storeId',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Update Product Response: ${response.data}');
        return Product.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Error updating product: $e');
      showCustomToast('Failed to update product.');
      return null;
    }
  }

  Future<bool> deleteProduct(String id, String storeId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await connect().delete(
        'products/$id',
        data: {'storeId': storeId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Delete Product Response: ${response.data}');
        return response.data['data']['deleted'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error deleting product: $e');
      showCustomToast('Failed to delete product.');
      return false;
    }
  }

  Future<Product?> supplyProduct(
      String id, int additionalQuantity, String storeId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final payload = {
        'id': id,
        'additionalQuantity': additionalQuantity,
        'storeId': storeId,
      };

      final response = await connect().post(
        'products/supply',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Supply Product Response: ${response.data}');
        return Product.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Error supplying product: $e');
      showCustomToast('Failed to supply product.');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getFilteredProducts({
    required String storeId,
    String? search,
    String? category, // Renamed from categoryId for clarity, as it can be name or ID now
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final Map<String, dynamic> query = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }

      // ONLY include 'category' if it's not null and not empty
      if (category != null && category.isNotEmpty) {
        query['category'] = category;
      }

      print('Request URL: products/filter/$storeId');
      print('Request Query Parameters: $query'); // Log query params for debugging

      final response = await connect().get(
        'products/filter/$storeId',
        queryParameters: query,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Filtered Products Response: ${response.data}');
        return response.data['data'];
      }
      return null;
    } on DioException catch (e) {
      print('Dio Error: ${e.message}');
      print('Error Status: ${e.response?.statusCode}');
      print('Error Data: ${e.response?.data}');
      showCustomToast(e.response?.data['message'] ?? 'Failed to fetch products.');
      return null;
    } catch (e) {
      print('Error fetching filtered products: $e');
      showCustomToast('Failed to fetch products.');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getExpiringProducts({
    required String storeId,
    int days = 30,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final query = {
        'days': days.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await connect().get(
        'products/expiring/$storeId',
        queryParameters: query,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Expiring Products Response: ${response.data}');
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching expiring products: $e');
      showCustomToast('Failed to fetch expiring products.');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLowStockProducts({
    required String storeId,
    int threshold = 5,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final query = {
        'threshold': threshold.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await connect().get(
        'products/low-stock/$storeId',
        queryParameters: query,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Low Stock Products Response: ${response.data}');
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching low stock products: $e');
      showCustomToast('Failed to fetch low stock products.');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getInventorySummary(String storeId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await connect().get(
        '${AppUrls.baseUrl}products/summary/$storeId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Inventory Summary Response: ${response.data}');
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching inventory summary: $e');
      showCustomToast('Failed to fetch inventory summary.');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTotalStock(String storeId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await connect().get(
        'products/total-stock/$storeId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Total Stock Response: ${response.data}');
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching total stock: $e');
      showCustomToast('Failed to fetch total stock.');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProductHistory({
    required String productId,
    required String storeId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final query = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await connect().get(
        'products/$productId/history/$storeId',
        queryParameters: query,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Product History Response: ${response.data}');
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching product history: $e');
      showCustomToast('Failed to fetch product history.');
      return null;
    }
  }


  Future<Map<String, dynamic>> getTotalStockWithProducts(String storeId) async {
    final response = await connect().get('products/total-stock/$storeId');
    print('getTotalStockWithProducts response: ${response.data}');
    return response.data['data'] as Map<String, dynamic>;
  }
}
