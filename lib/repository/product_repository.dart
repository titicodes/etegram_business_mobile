import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart'; // Ensure Dio is imported if used directly here for error types or FormData
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/core/model/product_history_model.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/service/local/cache.dart';
import 'package:etegram_business/service/local/storage_service.dart';

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

  // --- IMPORTANT CORRECTION HERE ---
  // Modify updateProduct to accept imageFile and imageUrl
  Future<Product?> updateProduct(String id, Product data, String storeId,
      {File? imageFile, String? imageUrl}) async {
    final updatedProduct = await apiService.updateProduct(
      id,
      data,
      storeId,
      imageFile: imageFile, // Pass the imageFile
      imageUrl: imageUrl, // Pass the imageUrl
    );
    if (updatedProduct != null) {
      // Store locally after successful API update
      await storageService.storeItem(
        key: DbTable.productTableName + id,
        value: jsonEncode(updatedProduct.toJson()),
      );
      print(
          'Updated product locally: ${updatedProduct.name}, imageUrl: ${updatedProduct.imageUrl}');
    }
    return updatedProduct;
  }
  // --- END OF IMPORTANT CORRECTION ---

  Future<bool> deleteProduct(String id, String storeId) async {
    final deleted = await apiService.deleteProduct(id, storeId);
    if (deleted) {
      await storageService.deleteItem(key: DbTable.productTableName + id);
      print('Deleted product from local storage: $id');
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
      print('Supplied product locally: ${updatedProduct.name}');
    }
    return updatedProduct;
  }

  // This method is no longer directly called from ProductViewModel's saveOrUpdateProduct
  // as image upload is now integrated into updateProduct/scanAndAddProduct in ProductApiService.
  // You might keep it if there's another specific use case for standalone image upload,
  // but it's not part of the standard product update flow anymore.
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
        print('Stored product image locally: ${product.imageUrl}');
      }
      return product;
    } catch (e) {
      print('Error uploading product image: $e');
      showCustomToast(
          'Failed to upload product image.'); // Consider if this toast should be here or only in ViewModel
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
    try {
      final response = await apiService.getFilteredProducts(
        storeId: storeId,
        search: search,
        category: category,
        page: page,
        limit: limit,
      );
      if (response != null &&
          response['data'] != null &&
          response['data'] is List) {
        return (response['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList();
      }
      print('No products found or invalid response data: $response');
      return [];
    } catch (e) {
      print('Error in getFilteredProducts: $e');
      showCustomToast('Failed to fetch products: ${e.toString()}',
          success: false);
      return [];
    }
  }

  Future<List<Product>> getExpiringProducts({
    required String storeId,
    int days = 30,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Added try-catch for robustness
      final response = await apiService.getExpiringProducts(
        storeId: storeId,
        days: days,
        page: page,
        limit: limit,
      );
      if (response != null &&
          response['data'] != null &&
          response['data'] is List) {
        return (response['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error in getExpiringProducts: $e');
      showCustomToast('Failed to fetch expiring products: ${e.toString()}',
          success: false);
      return [];
    }
  }

  Future<List<Product>> getLowStockProducts({
    required String storeId,
    int threshold = 5,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Added try-catch for robustness
      final response = await apiService.getLowStockProducts(
        storeId: storeId,
        threshold: threshold,
        page: page,
        limit: limit,
      );
      if (response != null &&
          response['data'] != null &&
          response['data'] is List) {
        return (response['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error in getLowStockProducts: $e');
      showCustomToast('Failed to fetch low stock products: ${e.toString()}',
          success: false);
      return [];
    }
  }

  Future<Map<String, dynamic>?> getInventorySummary(String storeId) async {
    return await apiService.getInventorySummary(storeId);
  }

  Future<Map<String, dynamic>> getTotalStockWithProducts(String storeId) async {
    // This method returns a map that includes 'totalQuantity' and 'products' list.
    // Ensure the API service returns this structure.
    return apiService.getTotalStockWithProducts(storeId);
  }

  Future<List<ProductHistory>> getProductHistory({
    String? productId,
    required String storeId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print(
          'Calling ProductApiService.getProductHistory: productId=$productId, storeId=$storeId, page=$page, limit=$limit');
      final response = await apiService.getProductHistory(
        productId: productId ?? '',
        storeId: storeId,
        page: page,
        limit: limit,
      );
      print('Raw API response: $response');
      if (response != null && response['history'] is List) {
        final historyList = (response['history'] as List)
            .map((item) => ProductHistory.fromJson(item))
            .toList();
        print('Parsed history list: $historyList');
        return historyList;
      }
      print('No valid history data in response: $response');
      return [];
    } catch (e, stackTrace) {
      print(
          'Error fetching or parsing product history: $e\nStack trace: $stackTrace');
      showCustomToast('Failed to fetch product history: ${e.toString()}');
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

      if (response != null &&
          response['success'] == true &&
          response['data'] != null) {
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
      showCustomToast('Failed to move product: ${e.toString()}');
      return null;
    }
  }
}
