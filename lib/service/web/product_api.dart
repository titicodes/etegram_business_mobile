import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etegram_business/constants/app_url.dart';
import 'package:etegram_business/core/model/get_search_response.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/service/web/base_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/reuseable.dart';
import '../../locator.dart';
import '../../utils/snack_message.dart';
import '../local/storage_service.dart';
import '../local/user_service.dart';

class ProductApiService {
  StorageService storageService = locator<StorageService>();
  CustomerService userService = locator<CustomerService>();

  Future<String> _getToken() async {
    final box = GetStorage();
    String? accessToken = box.read(DbTable.tokenTableName);

    if (accessToken == null) {
      throw Exception('No token found');
    }
    return accessToken;
  }

  Future<String> _getStoreId() async {
    final box = GetStorage();
    String storeId = box.read(DbTable.storeTableName);
    if (storeId == null) {
      throw Exception('No StoreId found');
    }
    return storeId;
  }

  Future<bool> checkProductExistence(String code) async {
    try {
      final String? ownerId = await locator<CustomerService>().getOwnerId();
      final String? storeId = await locator<CustomerService>().getStoreId();

      if (ownerId == null || storeId == null) {
        showCustomToast('Could not retrieve user or store information.');
        return false;
      }

      Response response = await connect().get(
        "products/check-code",
        queryParameters: {
          'code': code,
          'ownerId': ownerId,
          'storeId': storeId,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseData = response.data;

        // If responseData is a String, decode it
        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }

        final existsData = responseData['data'];
        final exists = existsData['exists'];

        return exists ?? false;
      } else {
        debugPrint('Error checking product existence: ${response.statusCode}');
        showCustomToast('Failed to check product existence.');
        return false;
      }
    } catch (e) {
      debugPrint('Error checking product existence: $e');
      showCustomToast('Error checking product existence.');
      return false;
    }
  }


  Future<AddProductResponse?> scanAndAddProduct({
    required Product data,
    required String scannedCode,
    required BuildContext context,
    String? storeId,  // Add storeId parameter
    String? ownerId,  // Add ownerId parameter
  }) async {
    debugPrint('API Service - scanAndAddProduct called with:');
    debugPrint('- scannedCode: $scannedCode');
    debugPrint('- passed ownerId: $ownerId');
    debugPrint('- passed storeId: $storeId');

    final token = await _getToken();

    // Get IDs from service only if they weren't provided
    String? finalOwnerId = ownerId;
    String? finalStoreId = storeId;

    if (finalOwnerId == null || finalOwnerId.isEmpty) {
      finalOwnerId = await locator<CustomerService>().getOwnerId();
      debugPrint('- fetched ownerId from service: $finalOwnerId');
    }

    if (finalStoreId == null || finalStoreId.isEmpty) {
      finalStoreId = await locator<CustomerService>().getStoreId();
      debugPrint('- fetched storeId from service: $finalStoreId');
    }

    debugPrint('Final values:');
    debugPrint('- finalOwnerId: $finalOwnerId');
    debugPrint('- finalStoreId: $finalStoreId');

    if (finalStoreId == null || finalStoreId.isEmpty) {
      debugPrint('Error: No StoreId provided. Cannot add product.');
      return null;
    }

    if (finalOwnerId == null || finalOwnerId.isEmpty) {
      debugPrint('Error: No OwnerId provided. Cannot add product.');
      return null;
    }

    final payload = {
      "name": data.name ?? "",
      "code": scannedCode,
      "category": data.category ?? "DefaultCategory",
      "price": data.price ?? 0.0,
      "quantity": data.quantity ?? 0,
      "unitPrice": data.unitPrice ?? 0.0,
      "unitId": data.unitId ?? 1,
      "totalCost": data.totalCost ?? 0.0,
      "size": data.size ?? "",
      "totalQuantity": data.totalQuantity ?? 0,
      "minQuantity": data.minQuantity ?? 0,
      "expiryDate": data.expiryDate ?? "",
      "brands": data.brands ?? "",
      "stock": data.stock ?? 0,
      //"owner": finalOwnerId,  // Remove this line
      "store": finalStoreId
    };

    try {
      Response response = await connect().post(
        AppUrls.scanAddProductsUrl,
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Raw Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          return AddProductResponse.fromJson(responseData);
        } else {
          throw Exception("Unexpected response format: $responseData");
        }
      }
      return null;
    } on DioException catch (e) {
      final message = e.response?.data is String
          ? e.response?.data
          : e.response?.data?['message'] ?? 'Unknown error';
      debugPrint("API Error: $message");
      return null;
    } catch (e) {
      debugPrint("General error adding product via scan: $e");
      return null;
    }
  }


  Future<List<Product>?> searchProduct(String query) async {
    try {
      Response response = await connect().get(
        AppUrls.searchProductUrl,
        queryParameters: {"search": query},
      );

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          throw Exception("Unexpected response format");
        }

        // Check if responseData['data'] and responseData['data']['data'] exist and are lists
        if (responseData['data'] != null &&
            responseData['data']['data'] is List) {
          List<dynamic> productList = responseData['data']['data'];
          return productList.map((item) => Product.fromJson(item)).toList();
        } else {
          return []; // Return an empty list if data is not in the expected format
        }
      }
      return null;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? "An error occurred";
      debugPrint("API Error: $errorMessage");
      return null;
    }
  }

  Future<SearchProductResponse?> getFilteredProducts(String query) async {
    try {
      Response response = await connect().get(
        "products/filter",
        queryParameters: {"search": query},
      );

      if (response.statusCode == 200) {
        return SearchProductResponse.fromJson(response.data);
      } else {
        print("Failed to search products. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error searching products: $e");
      return null;
    }
  }

  /// 📦 Get paginated list of products
  Future<Product?> getProducts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Response response = await connect().get("products");
      Product? dataResponse = Product.fromJson(jsonDecode(response.data));
      return dataResponse;
    } on DioException catch (e) {
      print(e.response);
      return null;
    }
  }

  /// 🆔 Get single product by ID
  Future<Product?> getProductById(String id) async {
    try {
      Response response = await connect().get("api/products/$id");

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      }
    } catch (e) {
      print("Error fetching product: $e");
    }
    return null;
  }

  /// ➕ Add a new product
  Future<AddProductResponse?> addProduct(Product data) async {
    final payload = {
      "name": data.name,
      "code": data.code,
      "categoryId": data.categoryId,
      "price": data.price,
      "stock": data.stock,
      "expiryDate": data.expiryDate,
      "quantity": data.quantity,
      "unitPrice": data.unitPrice,
      "unitId": data.unitId,
      "totalCost": data.totalCost,
      "size": data.size,
      "totalQuantity": data.totalQuantity,
      "minQuantity": data.minQuantity
    };

    try {
      Response response = await connect().post("products", data: payload);
      if (response.statusCode == 201) {
        return AddProductResponse.fromJson(response.data);
      }
    } catch (e) {
      print("Error adding product: $e");
    }
    return null;
  }

  /// ✏️ Update a product

  Future<Product?> updateProduct(String id, Product updatedProduct) async {
    try {
      final response = await connect().put(
        '${AppUrls.baseUrl}products/$id', // Assuming your endpoint format
        data: updatedProduct.toJson(),
      );

      if (response.statusCode == 200) {
        // Assuming your backend returns the updated product
        return Product.fromJson(response.data);
      } else {
        print('Error updating product: ${response.statusCode}');
        print('Response data: ${response.data}');
        return null;
      }
    } on DioException catch (e) {
      print('DioError updating product: $e');
      print('DioError response: ${e.response?.data}');
      return null;
    } catch (e) {
      print('General error updating product: $e');
      return null;
    }
  }

  /// ❌ Delete a product
  Future<bool> deleteProduct(String id) async {
    try {
      Response response = await connect().delete("products/$id");

      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting product: $e");
    }
    return false;
  }

  /// 🚀 Supply an existing product (Increase stock & optionally update details)
  Future<Product?> supplyProduct(String id, int additionalStock) async {
    try {
      Response response = await connect().patch(
        "products/$id/supply", // Correct URL
        data: {"stock": additionalStock}, // Correct data
      );

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      }
    } catch (e) {
      print("Error supplying product: $e");
    }
    return null;
  }

  Future<List<Product>?> fetchExpiringProducts(int page, int limit) async {
    try {
      Response response =
          await connect().get('products/expiring?page=$page&limit=$limit');

      if (response.statusCode == 200 && response.data != null) {
        dynamic decodedResponse = response.data;
        if (decodedResponse is String) {
          decodedResponse = jsonDecode(decodedResponse);
        }

        if (decodedResponse is Map &&
            decodedResponse['data'] is Map &&
            decodedResponse['data']['data'] is List) {
          List<dynamic> productList = decodedResponse['data']['data'];
          return productList
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          print(
              "Unexpected response format for expiring products: $decodedResponse");
          return null;
        }
      } else {
        print(
            "Failed to fetch expiring products. Status code: ${response.statusCode}, Response: ${response.data}");
        return null;
      }
    } catch (e) {
      print("Error fetching expiring products: $e");
    }
    return null;
  }

  Future<List<Product>?> fetchLowStockProducts(int page, int limit) async {
    try {
      Response response =
          await connect().get('products/low-stock?page=$page&limit=$limit');

      if (response.statusCode == 200 && response.data != null) {
        dynamic decodedResponse = response.data;
        if (decodedResponse is String) {
          decodedResponse = jsonDecode(decodedResponse);
        }

        if (decodedResponse is Map &&
            decodedResponse['data'] is Map &&
            decodedResponse['data']['data'] is List) {
          List<dynamic> productList = decodedResponse['data']['data'];
          return productList
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          print(
              "Unexpected response format for expiring products: $decodedResponse");
          return null;
        }
      } else {
        print(
            "Failed to fetch expiring products. Status code: ${response.statusCode}, Response: ${response.data}");
        return null;
      }
    } catch (e) {
      print("Error fetching expiring products: $e");
    }
    return null;
  }

  Future<String?> fetchProductIdByBarcode(String barcode) async {
    try {
      Response response = await connect().get(
        '${AppUrls.baseUrl}products?code=$barcode',
      );

      if (response.statusCode == 200 && response.data["data"].isNotEmpty) {
        return response.data["data"][0]
            ["_id"]; // Adjust based on your API response
      } else {
        print("⚠️ No product found with this barcode.");
        return null;
      }
    } on DioException catch (e) {
      print("❌ Error fetching product ID: ${e.response?.data}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchInventorySummary() async {
    try {
      Response response = await connect().get('products/inventory-summary');
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is String) {
          try {
            return jsonDecode(response.data) as Map<String, dynamic>;
          } catch (e) {
            print('Error decoding JSON: $e');
            return null;
          }
        } else if (response.data is Map<String, dynamic>) {
          return response.data;
        } else {
          print('Unexpected response data type: ${response.data.runtimeType}');
          return null;
        }
      } else {
        print(
            'Failed to fetch inventory summary. Status code: ${response.statusCode}, Response: ${response.data}');
        return null;
      }
    } on DioException catch (e) {
      print('DioError fetching inventory summary: $e');
      print('DioError response: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error fetching inventory summary: $e');
      return null;
    }
  }
}
