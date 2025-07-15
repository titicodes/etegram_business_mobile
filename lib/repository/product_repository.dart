// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:etegram_business/core/model/product_model.dart';
// import 'package:etegram_business/core/model/product_history_model.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/utils/snack_message.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/service/local/cache.dart';
// import 'package:etegram_business/service/local/storage_service.dart';
// import 'package:etegram_business/service/web/product_api.dart';
//
// class ProductRepository {
//   final ProductApiService apiService = locator<ProductApiService>();
//   final StorageService storageService = locator<StorageService>();
//   final AppCache appCache = locator<AppCache>();
//
//   Future<Map<String, dynamic>> checkProductExistence(
//       String code, String storeId) async {
//     return await apiService.checkProductExistence(code, storeId);
//   }
//
//   Future<Product?> getProductById(String id, String storeId) async {
//     return await apiService.getProductById(id, storeId);
//   }
//
//   Future<Product?> getProductByCode(String code, String storeId) async {
//     return await apiService.getProductByCode(code, storeId);
//   }
//
//   Future<AddProductResponse?> scanAndAddProduct({
//     required Product data,
//     required String scannedCode,
//     required BuildContext context,
//     required String storeId,
//     required String ownerId,
//   }) async {
//     final response = await apiService.scanAndAddProduct(
//       data: data,
//       scannedCode: scannedCode,
//       storeId: storeId,
//       ownerId: ownerId,
//     );
//     if (response?.success == true && response?.data != null) {
//       await storageService.storeItem(
//         key: DbTable.productTableName + response!.data!.id!,
//         value: jsonEncode(response.data!.toJson()),
//       );
//       print('Stored product: ${response.data!.name}');
//     }
//     return response;
//   }
//
//   Future<Product?> updateProduct(
//       String id, Product data, String storeId) async {
//     final updatedProduct = await apiService.updateProduct(id, data, storeId);
//     if (updatedProduct != null) {
//       await storageService.storeItem(
//         key: DbTable.productTableName + id,
//         value: jsonEncode(updatedProduct.toJson()),
//       );
//       print('Updated product: ${updatedProduct.name}');
//     }
//     return updatedProduct;
//   }
//
//   Future<bool> deleteProduct(String id, String storeId) async {
//     final deleted = await apiService.deleteProduct(id, storeId);
//     if (deleted) {
//       await storageService.deleteItem(key: DbTable.productTableName + id);
//       print('Deleted product: $id');
//     }
//     return deleted;
//   }
//
//   Future<Product?> supplyProduct(
//       String id, int additionalQuantity, String storeId) async {
//     final updatedProduct =
//         await apiService.supplyProduct(id, additionalQuantity, storeId);
//     if (updatedProduct != null) {
//       await storageService.storeItem(
//         key: DbTable.productTableName + id,
//         value: jsonEncode(updatedProduct.toJson()),
//       );
//       print('Supplied product: ${updatedProduct.name}');
//     }
//     return updatedProduct;
//   }
//
//   Future<List<Product>> getFilteredProducts({
//     required String storeId,
//     String? search,
//     String? category,
//     int page = 1,
//     int limit = 10,
//   }) async {
//     final response = await apiService.getFilteredProducts(
//       storeId: storeId,
//       search: search,
//       category: category,
//       page: page,
//       limit: limit,
//     );
//     if (response != null) {
//       return (response['data'] as List)
//           .map((item) => Product.fromJson(item))
//           .toList();
//     }
//     return [];
//   }
//
//   Future<List<Product>> getExpiringProducts({
//     required String storeId,
//     int days = 30,
//     int page = 1,
//     int limit = 10,
//   }) async {
//     final response = await apiService.getExpiringProducts(
//       storeId: storeId,
//       days: days,
//       page: page,
//       limit: limit,
//     );
//     if (response != null) {
//       return (response['data'] as List)
//           .map((item) => Product.fromJson(item))
//           .toList();
//     }
//     return [];
//   }
//
//   Future<List<Product>> getLowStockProducts({
//     required String storeId,
//     int threshold = 5,
//     int page = 1,
//     int limit = 10,
//   }) async {
//     final response = await apiService.getLowStockProducts(
//       storeId: storeId,
//       threshold: threshold,
//       page: page,
//       limit: limit,
//     );
//     if (response != null) {
//       return (response['data'] as List)
//           .map((item) => Product.fromJson(item))
//           .toList();
//     }
//     return [];
//   }
//
//   Future<Map<String, dynamic>?> getInventorySummary(String storeId) async {
//     return await apiService.getInventorySummary(storeId);
//   }
//
//   Future<int> getTotalStock(String storeId) async {
//     final response = await apiService.getTotalStock(storeId);
//     return response?['totalQuantity']?.toInt() ?? 0;
//   }
//
//   // Future<List<ProductHistory>> getProductHistory({
//   //   required String productId,
//   //   required String storeId,
//   //   int page = 1,
//   //   int limit = 10,
//   // }) async {
//   //   try {
//   //     final response = await apiService.getProductHistory(
//   //       productId: productId,
//   //       storeId: storeId,
//   //       page: page,
//   //       limit: limit,
//   //     );
//   //     if (response != null && response['history'] != null) {
//   //       return (response['history'] as List).map((item) => ProductHistory.fromJson(item)).toList();
//   //     }
//   //     return [];
//   //   } catch (e) {
//   //     print('Error parsing product history: $e');
//   //     showCustomToast('Failed to parse product history.');
//   //     return [];
//   //   }
//   // }
//
//   Future<Map<String, dynamic>> getTotalStockWithProducts(String storeId) async {
//     return apiService.getTotalStockWithProducts(storeId);
//   }
//
//   Future<List<ProductHistory>> getProductHistory({
//     // Made optional
//     String? productId,
//     required String storeId,
//     int page = 1,
//     int limit = 10,
//   }) async {
//     try {
//       final response = await apiService.getProductHistory(
//         productId: productId ?? '',
//         storeId: storeId,
//         page: page,
//         limit: limit,
//       );
//       if (response != null && response['history'] != null) {
//         return (response['history'] as List)
//             .map((item) => ProductHistory.fromJson(item))
//             .toList();
//       }
//       return [];
//     } catch (e) {
//       print('Error parsing product history: $e');
//       showCustomToast('Failed to parse product history.');
//       return [];
//     }
//   }
//
//   Future<Product?> moveProduct({
//     required String productCode,
//     required int quantity,
//     required String storeId,
//     required bool isSentOut,
//     String? deliveryAgentId,
//     String? notes,
//   }) async {
//     try {
//       final endpoint = isSentOut
//           ? 'products/$storeId/send-out'
//           : 'products/$storeId/receive';
//       final response = await apiService.moveProduct(
//         productCode: productCode,
//         quantity: quantity,
//         storeId: storeId,
//         endpoint: endpoint,
//         deliveryAgentId: deliveryAgentId,
//         notes: notes,
//       );
//
//       if (response != null && response['success'] == true) {
//         final updatedProduct = Product.fromJson(response['data']);
//         await storageService.storeItem(
//           key: DbTable.productTableName + updatedProduct.id!,
//           value: jsonEncode(updatedProduct.toJson()),
//         );
//         print(
//             'Moved product: ${updatedProduct.name}, New Quantity: ${updatedProduct.quantity}');
//         return updatedProduct;
//       }
//       return null;
//     } catch (e) {
//       print('Error moving product: $e');
//       showCustomToast('Failed to move product.');
//       return null;
//     }
//   }
//
//   Future<Product?> uploadProductImage(
//       String productId, String storeId, String filePath) async {
//     try {
//       final product =
//           await apiService.uploadProductImage(productId, storeId, filePath);
//       if (product != null) {
//         await storageService.storeItem(
//           key: DbTable.productTableName + productId,
//           value: jsonEncode(product.toJson()),
//         );
//         print('Stored product image: ${product.imageUrl}');
//       }
//       return product;
//     } catch (e) {
//       print('Error uploading product image: $e');
//       showCustomToast('Failed to upload product image.');
//       return null;
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/core/model/product_history_model.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/service/local/cache.dart';
import 'package:etegram_business/service/local/storage_service.dart';
import 'package:flutter/material.dart';

import '../constants/reuseable.dart';
import '../service/web/product_api.dart';

class ProductRepository {
  final ProductApiService apiService = locator<ProductApiService>();
  final StorageService storageService = locator<StorageService>();
  final AppCache appCache = locator<AppCache>();

  Future<Map<String, dynamic>> checkProductExistence(
      String code, String storeId) async {
    return await apiService.checkProductExistence(code, storeId);
  }

  Future<Product?> getProductById(String id, String storeId) async {
    return await apiService.getProductById(id, storeId);
  }

  Future<Product?> getProductByCode(String code, String storeId) async {
    return await apiService.getProductByCode(code, storeId);
  }

  Future<AddProductResponse?> scanAndAddProduct({
    required Product data,
    required String scannedCode,
    required String storeId,
    required String ownerId,
    File? imageFile,

  }) async {

    return await apiService.scanAndAddProduct(
      data: data,
      scannedCode: scannedCode,
      storeId: storeId,
      ownerId: ownerId,
      imageFile: imageFile,

    );
  }

  Future<Product?> updateProduct(
      String id, Product data, String storeId) async {
    final updatedProduct = await apiService.updateProduct(id, data, storeId);
    if (updatedProduct != null) {
      await storageService.storeItem(
        key: DbTable.productTableName + id,
        value: jsonEncode(updatedProduct.toJson()),
      );
      print(
          'Updated product: ${updatedProduct.name}, imageUrl: ${updatedProduct.imageUrl}');
    }
    return updatedProduct;
  }

  Future<bool> deleteProduct(String id, String storeId) async {
    final deleted = await apiService.deleteProduct(id, storeId);
    if (deleted) {
      await storageService.deleteItem(key: DbTable.productTableName + id);
      print('Deleted product: $id');
    }
    return deleted;
  }

  Future<Product?> supplyProduct(
      String id, int additionalQuantity, String storeId) async {
    final updatedProduct =
        await apiService.supplyProduct(id, additionalQuantity, storeId);
    if (updatedProduct != null) {
      await storageService.storeItem(
        key: DbTable.productTableName + id,
        value: jsonEncode(updatedProduct.toJson()),
      );
      print('Supplied product: ${updatedProduct.name}');
    }
    return updatedProduct;
  }

  Future<Product?> uploadProductImage(
      String productId, String storeId, String filePath) async {
    try {
      final product =
          await apiService.uploadProductImage(productId, storeId, filePath);
      if (product != null) {
        await storageService.storeItem(
          key: DbTable.productTableName + productId,
          value: jsonEncode(product.toJson()),
        );
        print('Stored product image: ${product.imageUrl}');
      }
      return product;
    } catch (e) {
      print('Error uploading product image: $e');
      showCustomToast('Failed to upload product image.');
      return null;
    }
  }

  Future<List<Product>> getFilteredProducts({
    required String storeId,
    String? search,
    String? category,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiService.getFilteredProducts(
      storeId: storeId,
      search: search,
      category: category,
      page: page,
      limit: limit,
    );
    if (response != null) {
      return (response['data'] as List)
          .map((item) => Product.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<List<Product>> getExpiringProducts({
    required String storeId,
    int days = 30,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiService.getExpiringProducts(
      storeId: storeId,
      days: days,
      page: page,
      limit: limit,
    );
    if (response != null) {
      return (response['data'] as List)
          .map((item) => Product.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<List<Product>> getLowStockProducts({
    required String storeId,
    int threshold = 5,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiService.getLowStockProducts(
      storeId: storeId,
      threshold: threshold,
      page: page,
      limit: limit,
    );
    if (response != null) {
      return (response['data'] as List)
          .map((item) => Product.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>?> getInventorySummary(String storeId) async {
    return await apiService.getInventorySummary(storeId);
  }

  Future<Map<String, dynamic>> getTotalStockWithProducts(String storeId) async {
    return apiService.getTotalStockWithProducts(storeId);
  }

  Future<List<ProductHistory>> getProductHistory({
    String? productId,
    required String storeId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await apiService.getProductHistory(
        productId: productId ?? '',
        storeId: storeId,
        page: page,
        limit: limit,
      );
      if (response != null && response['history'] != null) {
        return (response['history'] as List)
            .map((item) => ProductHistory.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error parsing product history: $e');
      showCustomToast('Failed to parse product history.');
      return [];
    }
  }

  Future<Product?> moveProduct({
    required String productCode,
    required int quantity,
    required String storeId,
    required bool isSentOut,
    String? deliveryAgentId,
    String? notes,
  }) async {
    try {
      final endpoint = isSentOut
          ? 'products/$storeId/send-out'
          : 'products/$storeId/receive';
      final response = await apiService.moveProduct(
        productCode: productCode,
        quantity: quantity,
        storeId: storeId,
        endpoint: endpoint,
        deliveryAgentId: deliveryAgentId,
        notes: notes,
      );

      if (response != null && response['success'] == true) {
        final updatedProduct = Product.fromJson(response['data']);
        await storageService.storeItem(
          key: DbTable.productTableName + updatedProduct.id!,
          value: jsonEncode(updatedProduct.toJson()),
        );
        print(
            'Moved product: ${updatedProduct.name}, New Quantity: ${updatedProduct.quantity}');
        return updatedProduct;
      }
      return null;
    } catch (e) {
      print('Error moving product: $e');
      showCustomToast('Failed to move product.');
      return null;
    }
  }
}
