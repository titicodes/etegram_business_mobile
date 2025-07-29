import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../constants/app_url.dart';
import '../../constants/reuseable.dart';
import '../../core/model/product_model.dart';
import '../../core/model/product_history_model.dart';
import '../../locator.dart';
import '../../utils/snack_message.dart';
import '../local/user_service.dart';
import 'base_api.dart';
import 'package:mime_type/mime_type.dart';

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

  Future<Map<String, dynamic>> checkProductExistence(
      String code, String storeId) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'exists': false};

      final response = await connect().get(
        'products/check-code/$code/$storeId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        print(
            'Check Product Existence: Code=$code, Store=$storeId, data=$data');
        return {
          'success': true,
          'exists': data['exists'] ?? false,
          'product': data['product'] != null
              ? Product.fromJson(data['product'])
              : null,
        };
      }
      return {'success': false, 'exists': false};
    } catch (e) {
      print('Error checking product existence: $e');
      showCustomToast('Failed to check product existence.');
      return {'success': false, 'exists': false};
    }
  }

  Future<Product?> getProductById(String code, String storeId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await connect().get(
        'products/code/$code?storeId=$storeId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Fetched Product: ${response.data}');
        return Product.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching product by code: $e');
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
      if (response.statusCode == 200) {
        return Product.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Corrected function: Sends product data and image in one multipart/form-data request.
  Future<AddProductResponse?> scanAndAddProduct({
    required Product data,
    required String scannedCode,
    required String storeId,
    required String ownerId,
    File? imageFile,
    String? imageUrl,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        showCustomToast('Authentication token missing. Please log in again.');
        return null;
      }

      // Basic input validation (more robust validation should also be on the backend)
      if (data.name == null || data.name!.isEmpty) {
        throw Exception('Product name cannot be empty.');
      }
      if (data.price == null || data.price! <= 0) {
        throw Exception('Price must be greater than 0.');
      }
      if (data.costPrice == null || data.costPrice! < 0) {
        throw Exception('Cost price cannot be negative.');
      }
      if (data.quantity == null || data.quantity! < 1) {
        throw Exception('Quantity must be at least 1.');
      }
      if (data.minQuantity == null || data.minQuantity! < 1) {
        throw Exception('Minimum quantity must be at least 1.');
      }
      if (data.storeId == null || data.storeId!.isEmpty) {
        throw Exception('Store ID in product data cannot be empty.');
      }
      if (storeId.isEmpty) {
        // This is the storeId for the URL path
        throw Exception('Store ID for API URL cannot be empty.');
      }
      // Consider if ownerId is truly needed as a body field if it's derived from token.
      if (ownerId.isEmpty) {
        throw Exception('Owner ID cannot be empty.');
      }

      // Build the FormData payload for multipart/form-data
      final FormData formData = FormData.fromMap({
        'name': data.name,
        'code': scannedCode,
        'category': data.category ?? 'Uncategorized',
        'price': data.price,
        'costPrice': data.costPrice,
        'quantity': data.quantity,
        'minQuantity': data.minQuantity,
        'storeId': data.storeId,
        if (data.expiryDate != null) 'expiryDate': data.expiryDate,
        if (data.description != null) 'description': data.description,
        if (data.size != null) 'size': data.size,
        if (data.brands != null) 'brands': data.brands,
      });

      // Add image file if provided
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        //String? mime = mimeType(fileName);
        final mime = lookupMimeType(fileName);
        formData.files.add(MapEntry(
          'image', // <-- Make this consistent with 'image' for product update/add
          await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: mime != null
                ? MediaType.parse(mime)
                : null, // Dynamically set content type
          ),
        ));
      } else if (imageUrl != null && imageUrl.isNotEmpty) {
        formData.fields.add(MapEntry('imageUrl', imageUrl));
      }

      print('Request URL: products/scan/$storeId');
      print('Request Method: POST (Multipart)');
      print('--- FormData Payload ---');
      for (var field in formData.fields) {
        print('Field: ${field.key} = ${field.value}');
      }
      for (var file in formData.files) {
        print('File: ${file.key} = ${file.value.filename}');
      }
      print('--------------------------');

      final response = await connect().post(
        'products/scan/$storeId',
        data: formData, // Send FormData
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type':
                'multipart/form-data', // IMPORTANT: Set content type
          },
        ),
      );

      print('ScanAndAdd Response: ${response.data}');
      if (response.statusCode == 201) {
        return AddProductResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('DioError adding product: ${e.response?.data}');
      print('Error Status: ${e.response?.statusCode}');

      final dynamic backendMessage = e.response?.data['message'];
      String? displayMessage = 'Failed to add product.';

      if (backendMessage is String) {
        displayMessage = backendMessage;
      } else if (backendMessage is List) {
        displayMessage = backendMessage.join('\n');
      } else if (e.response?.data['error'] != null) {
        displayMessage = e.response?.data['error'].toString();
      }
      showCustomToast(displayMessage ?? 'An unknown error occurred.',
          success: false);
      return AddProductResponse(
        success: false,
        message: displayMessage,
      );
    } catch (e) {
      print('Error adding product: $e');
      showCustomToast('An unexpected error occurred: $e');
      return null;
    }
  }

// In ProductApiService.dart

  Future<Product?> updateProduct(String id, Product data, String storeId,
      {File? imageFile, String? imageUrl}) async {
    try {
      String priceString =
          data.price != null ? data.price!.toStringAsFixed(2) : '0.00';
      String costPriceString =
          data.costPrice != null ? data.costPrice!.toStringAsFixed(2) : '0.00';
      String quantityString =
          data.quantity != null ? data.quantity!.toString() : '0';

      Map<String, dynamic> fields = {
        'name': data.name,
        'code': data.code,
        'category': data.category,
        'price': priceString,
        'costPrice': costPriceString,
        'quantity': quantityString,
        'minQuantity': data.minQuantity?.toString() ?? '1',
        'expiryDate': data.expiryDate,
        'description': data.description,
        'size': data.size,
        'brands': data.brands,
      };

      if (imageFile == null) {
        if (imageUrl != null && imageUrl.isNotEmpty) {
          fields['imageUrl'] = imageUrl;
        } else if (imageUrl == null) {
          // You might send a specific signal to clear the image, e.g., 'CLEAR_IMAGE'
          // fields['imageUrl'] = '__CLEAR_IMAGE__';
        }
      }

      FormData formData = FormData.fromMap(fields);

      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        // String? mime = mimeType(fileName); // Use mimeType package to lookup
        final mime = lookupMimeType(fileName);
        formData.files.add(MapEntry(
          "image", // Keep this consistent
          await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName, // Use the actual file name from the path
            contentType: mime != null
                ? MediaType.parse(mime)
                : null, // Dynamically set content type
          ),
        ));
      }

      print('ProductApiService - Update URL: products/$id/$storeId');
      print(
          'ProductApiService - Update FormData (text fields): ${formData.fields}');
      if (formData.files.isNotEmpty) {
        print('ProductApiService - Update FormData Files:');
        for (var fileEntry in formData.files) {
          print(
              '  Key: ${fileEntry.key}, Filename: ${fileEntry.value.filename}, ContentType: ${fileEntry.value.contentType}');
        }
      }

      final response = await connect().patch(
        'products/$id/$storeId',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      print('Dio Error updating product in ProductApiService: ${e.message}');
      print('Response status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      return null; // Let the ViewModel handle the toast
    } catch (e) {
      print('Unexpected error updating product in ProductApiService: $e');
      return null; // Let the ViewModel handle the toast
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
    String? category,
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

      if (category != null && category.isNotEmpty) {
        query['category'] = category;
      }

      print('Request URL: products/filter/$storeId');
      print('Request Query Parameters: $query');

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
      showCustomToast(
          e.response?.data['message'] ?? 'Failed to fetch products.');
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

  Future<Map<String, dynamic>?> getProductHistory({
    required String productId,
    required String storeId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No authentication token found');
        showCustomToast('Authentication token missing.');
        return null;
      }
      final query = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      print('Sending request to products/$productId/history/$storeId with query: $query');
      final response = await connect().get(
        'products/$productId/history/$storeId',
        queryParameters: query,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('API response status: ${response.statusCode}');
      print('API response data: ${response.data}');
      if (response.statusCode == 200) {
        if (response.data['success'] == true && response.data['data'] != null) {
          return response.data['data'];
        }
        print('Invalid response structure: success=${response.data['success']}, data=${response.data['data']}');
        return null;
      }
      print('Non-200 status code: ${response.statusCode}');
      return null;
    } catch (e, stackTrace) {
      print('Error fetching product history: $e\nStack trace: $stackTrace');
      showCustomToast('Failed to fetch product history: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getTotalStockWithProducts(String storeId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found.');

      final response = await connect().get(
        'products/total-stock/$storeId', // This endpoint returns {totalQuantity, totalValue}
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Total Stock (Total-Stock endpoint) Response: ${response.data}');
        return response.data['data'];
      }
      throw Exception('Failed to fetch total stock.');
    } on DioException catch (e) {
      print('DioError fetching total stock: ${e.response?.data}');
      showCustomToast(
          e.response?.data['message'] ?? 'Failed to fetch total stock.');
      rethrow; // Re-throw so the calling ViewModel/Repo can catch it
    } catch (e) {
      print('Error fetching total stock: $e');
      showCustomToast('Failed to fetch total stock.');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> moveProduct({
    required String productCode,
    required int quantity,
    required String storeId,
    required String endpoint,
    String? deliveryAgentId,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final payload = {
        'productCode': productCode,
        'quantity': quantity,
        if (deliveryAgentId != null) 'deliveryAgentId': deliveryAgentId,
        if (notes != null) 'notes': notes,
      };

      print('Sending product movement request: $payload to $endpoint');
      final response = await connect().post(
        endpoint,
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Move Product Response: ${response.data}');
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      print('DioError moving product: ${e.response?.data}');
      showCustomToast(e.response?.data['message'] ?? 'Failed to move product.');
      return null;
    } catch (e) {
      print('Error moving product: $e');
      showCustomToast('Error moving product.');
      return null;
    }
  }

  Future<Product?> uploadProductImage(
      String productId, String storeId, String filePath) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      String fileName = filePath.split('/').last;
      // String? mime = mimeType(fileName);
      final mime = lookupMimeType(fileName);

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName, // Use original filename or a derived one
          contentType:
              mime != null ? MediaType.parse(mime) : null, // Set dynamically
        ),
      });

      final response = await connect().post(
        'products/$storeId/$productId/image',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Product Image Upload Response: ${response.data}');
        return Product.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('DioError uploading product image: ${e.response?.data}');
      showCustomToast(
          e.response?.data['message'] ?? 'Failed to upload product image.');
      return null;
    } catch (e) {
      print('Error uploading product image: $e');
      showCustomToast('Error uploading product image.');
      return null;
    }
  }
}
