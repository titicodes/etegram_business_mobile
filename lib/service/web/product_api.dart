

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http_parser/http_parser.dart';
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

  // Future<AddProductResponse?> scanAndAddProduct({
  //   required Product data,
  //   required String scannedCode,
  //   required String storeId, // This is for the URL path
  //   required String
  //       ownerId, // This should also be part of the 'data' Product object
  //   File? imageFile,
  // }) async {
  //   try {
  //     final token = await _getToken(); // Assume _getToken() is defined
  //     if (token == null) {
  //       // showCustomToast("Authentication token missing. Please log in again.");
  //       return null;
  //     }
  //
  //     if (data.name == null || data.name!.isEmpty) {
  //       throw Exception('Product name cannot be empty.');
  //     }
  //     // Backend error: "price must not be less than 0" (implies 0 is allowed, > 0 is stricter)
  //     // Adjust based on exact backend rule. If 0 is allowed, use `data.price! < 0`
  //     if (data.price == null || data.price! <= 0) {
  //       // Assuming price must be positive
  //       throw Exception('Price must be greater than 0.');
  //     }
  //     if (data.costPrice == null || data.costPrice! < 0) {
  //       // Cost price can be 0 or positive
  //       throw Exception('Cost price cannot be negative.');
  //     }
  //     // Backend error: "quantity must not be less than 0" (implies 0 is allowed, but product must have at least 1)
  //     if (data.quantity == null || data.quantity! < 1) {
  //       // Quantity must be at least 1 for a new product
  //       throw Exception('Quantity must be at least 1.');
  //     }
  //     // The main fix: Ensure data.store is not empty
  //     if (data.storeId == null || data.storeId!.isEmpty) {
  //       throw Exception(
  //           'Store ID in product data cannot be empty. Please ensure a store is selected.');
  //     }
  //     // You also pass storeId as a parameter, ensure it matches data.store or verify its usage if different
  //     if (storeId.isEmpty) {
  //       // This is the storeId for the URL
  //       throw Exception('Store ID for API URL cannot be empty.');
  //     }
  //     if (ownerId.isEmpty) {
  //       // Owner ID for security/authorization if not already token-based
  //       throw Exception('Owner ID cannot be empty.');
  //     }
  //
  //     // Build the FormData payload
  //     final payload = FormData.fromMap(data.toCreateJson());
  //
  //     payload.fields.add(MapEntry('code', scannedCode));
  //
  //     if (imageFile != null) {
  //       payload.files.add(MapEntry(
  //         'file', // This key should match what your backend expects for the image file
  //         await MultipartFile.fromFile(
  //           imageFile.path,
  //           filename:
  //               'product_image_${scannedCode}_${DateTime.now().millisecondsSinceEpoch}.jpg',
  //           contentType: MediaType('image', 'jpeg'),
  //         ),
  //       ));
  //     }
  //
  //     print('Request URL: products/scan/$storeId');
  //     print('--- Request FormData Fields ---');
  //     for (var field in payload.fields) {
  //       print('${field.key}: ${field.value}');
  //     }
  //     print('--- Request FormData Files ---');
  //     for (var file in payload.files) {
  //       print(
  //           '${file.key}: ${file.value.filename} (${file.value.contentType})');
  //     }
  //     print('-------------------------------');
  //
  //     final response = await connect().post(
  //       'products/scan/$storeId',
  //       data: payload,
  //       options: Options(headers: {'Authorization': 'Bearer $token'}),
  //     );
  //
  //     print('ScanAndAdd Response: ${response.data}');
  //     if (response.statusCode == 201) {
  //       return AddProductResponse.fromJson(response.data);
  //     }
  //     return null;
  //   } on DioException catch (e) {
  //     print('DioError adding product: ${e.response?.data}');
  //     print('Error Status: ${e.response?.statusCode}');
  //
  //     final dynamic backendMessage = e.response?.data['message'];
  //     String? displayMessage = 'Failed to add product.';
  //
  //     if (backendMessage is String) {
  //       displayMessage = backendMessage;
  //     } else if (backendMessage is List) {
  //       displayMessage = (backendMessage)
  //           .join('\n'); // Join multiple error messages with newline
  //     } else if (e.response?.data['error'] != null) {
  //       displayMessage = e.response?.data['error'].toString();
  //     }
  //     // showCustomToast(displayMessage, success: false);
  //     return AddProductResponse(
  //       success: false,
  //       message: displayMessage,
  //     );
  //   } catch (e) {
  //     print('Error adding product: $e');
  //     // showCustomToast('An unexpected error occurred: $e');
  //     return null;
  //   }
  // }

  Future<AddProductResponse?> scanAndAddProduct({
    required Product data,
    required String scannedCode,
    required String storeId,
    File? imageFile,
    required String ownerId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        showCustomToast('Authentication token missing. Please log in again.');
        return null;
      }

      // Validate inputs
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
        throw Exception('Store ID cannot be empty.');
      }

      // Build JSON payload (preferred for consistency)
      final payload = {
        'name': data.name,
        'code': scannedCode,
        'category': data.category ?? 'Uncategorized',
        'price': data.price, // Send as number
        'costPrice': data.costPrice,
        'quantity': data.quantity,
        'minQuantity': data.minQuantity,
        'storeId': data.storeId,
        if (data.expiryDate != null) 'expiryDate': data.expiryDate,
        if (data.description != null) 'description': data.description,
        if (data.size != null) 'size': data.size,
        if (data.brands != null) 'brands': data.brands,
        if (data.imageUrl != null) 'imageUrl': data.imageUrl,
      };

      Options options = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Handle image separately if provided
      if (imageFile != null) {
        // First, add product without image
        print('Request URL: products/scan/$storeId');
        print('Request Payload (JSON): ${jsonEncode(payload)}');

        final response = await connect().post(
          'products/scan/$storeId',
          data: payload,
          options: options,
        );

        if (response.statusCode != 201) {
          throw DioException(
            response: response,
            requestOptions: RequestOptions(path: 'products/scan/$storeId'),
          );
        }

        final addedProduct = AddProductResponse.fromJson(response.data);
        if (addedProduct.success && addedProduct.data != null) {
          // Upload image separately
          final imageResponse = await uploadProductImage(
            addedProduct.data!.id!,
            storeId,
            imageFile.path,
          );
          if (imageResponse != null) {
            return AddProductResponse(
              success: true,
              data: imageResponse,
              message: 'Product added with image successfully',
            );
          }
          return addedProduct; // Return product even if image upload fails
        }
        return null;
      } else {
        // Add product without image
        print('Request URL: products/scan/$storeId');
        print('Request Payload (JSON): ${jsonEncode(payload)}');

        final response = await connect().post(
          'products/scan/$storeId',
          data: payload,
          options: options,
        );

        print('ScanAndAdd Response: ${response.data}');
        if (response.statusCode == 201) {
          return AddProductResponse.fromJson(response.data);
        }
        return null;
      }
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
      showCustomToast(displayMessage??'Invalid display', success: false);
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

  Future<Product?> updateProduct(
      String id, Product data, String storeId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final payload = {
        'name': data.name,
        'code': data.code,
        'category': data.category,
        'price': data.price,
        'costPrice': data.costPrice,
        'quantity': data.quantity,
        'expiryDate': data.expiryDate,
        'brands': data.brands,
        'description': data.description,
        'imageUrl': data.imageUrl,
      };

      print('Updating product with payload: $payload');
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
    } on DioException catch (e) {
      print('DioError updating product: ${e.response?.data}');
      showCustomToast(
          e.response?.data['message'] ?? 'Failed to update product.');
      return null;
    } catch (e) {
      print('Error updating product: $e');
      showCustomToast('Failed to update product: $e');
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
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found.');

      final response = await connect().get(
        'products/total-stock/$storeId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Total Stock Response: ${response.data}');
        return response.data['data'];
      }
      throw Exception('Failed to fetch total stock.');
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

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath,
            filename:
                'product_image_${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg'),
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
