import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etegram_business/constants/app_url.dart';
import 'package:etegram_business/core/model/get_search_response.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/service/web/base_api.dart';
import 'package:flutter/cupertino.dart';

import '../../locator.dart';
import '../local/storage_service.dart';
import '../local/user_service.dart';

class ProductApiService {
  StorageService storageService = locator<StorageService>();
  CustomerService userService = locator<CustomerService>();

  Future<AddProductResponse?> scanAndAddProduct({
    required Product data,
    required String scannedCode,
  }) async {
    print('Scanned Code in scanAndAddProduct: $scannedCode');

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
    };

    try {
      Response response =
          await connect().post(AppUrls.scanAddProductsUrl, data: payload);

      print("Response Status: ${response.statusCode}");
      print("Raw Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;

        // Check if responseData is a Map
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
          : e.response?.data['message'] ?? 'Unknown error';
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
  Future<SearchProductResponse?> getProducts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Send the HTTP GET request to the server
      Response response = await connect().get(
        AppUrls.getProductsUrl,
        queryParameters: {"page": page, "limit": limit},
      );

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        // Deserialize the response data to a SearchProductResponse object
        return SearchProductResponse.fromJson(response.data);
      }
    } catch (e) {
      print("Error fetching products: $e");
    }

    return null;
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
      Response response = await connect().post("api/products", data: payload);
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
      Response response = await connect().delete("api/products/$id");

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

  Future<Map<String, dynamic>?> fetchExpiringProducts(
      int page, int limit) async {
    try {
      Response response = await connect().get(
        "products/expiring?page=$page&limit=$limit",
      );

      if (response.statusCode == 200) {
        return {
          'data': (response.data['data'] as List)
              .map((json) => Product.fromJson(json))
              .toList(),
          'metadata': response.data['metadata'],
        };
      }
    } catch (e) {
      print("Error fetching expiring products: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchLowStockProducts(
      int page, int limit) async {
    try {
      final response = await connect().get(
        'products/low-stock?page=$page&limit=$limit',
      );

      if (response.statusCode == 200) {
        return {
          'data': (response.data['data'] as List)
              .map((json) => Product.fromJson(json))
              .toList(),
          'metadata': response.data['metadata'],
        };
      }
    } catch (e) {
      print("Error fetching low stock products: $e");
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
}
