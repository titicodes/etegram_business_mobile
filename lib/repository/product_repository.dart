import 'dart:convert';
import 'package:etegram_business/core/model/get_search_response.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/service/web/product_api.dart';

import '../constants/reuseable.dart';
import '../locator.dart';
import '../service/local/cache.dart';
import '../service/local/storage_service.dart';

class ProductRepository {
  StorageService storageService = locator<StorageService>();
  AppCache appCache = locator<AppCache>();
  ProductApiService productApiService = locator<ProductApiService>();

  Future<AddProductResponse?> scanAndAddProduct(
      {required Product data, required String scannedCode}) async {
    var response = await productApiService.scanAndAddProduct(
        data: data, scannedCode: scannedCode);
    if (response != null && response.success == true && response.data != null) {
      await storeScanAndAddProduct(response.data!);
    }
    return response;
  }

  storeScanAndAddProduct(Product product) async {
    print("Storing scanned product: ${product.name}");
    await storageService.storeItem(
      key: DbTable.producTableName,
      value: jsonEncode(product.toJson()), // ✅ Store only product data
    );
  }

  Future<void> storeFetchedProduct(SearchProductResponse? response) async {
    if (response != null) {
      await storageService.storeItem(
        key: DbTable.producTableName,
        value: jsonEncode(response.toJson()),
      );
    }
  }

  Future<List<Product>?> searchProduct(String query) async {
    return await productApiService.searchProduct(query);
  }

  Future<SearchProductResponse?> getProducts({
    int page = 1,
    int limit = 10,
  }) async {
    var response = await productApiService.getProducts(page: page,limit: limit);
    if (response != null && response.success == true) {
      await storeFetchedProduct(response); // Store in local storage
      return response;
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchExpiringProducts(
      int page, int limit) async {
    return await productApiService.fetchExpiringProducts(page, limit);
  }

  Future<Map<String, dynamic>?> fetchLowStockProducts(
      int page, int limit) async {
    return await productApiService.fetchLowStockProducts(page, limit);
  }

  // Future<Product?> searchProducts(String query) async {
  //   return await productApiService.searchProduct(query);
  // }

  // product_repository.dart

  Future<SearchProductResponse?> getFilteredProducts(String query) async {
    return await productApiService.getFilteredProducts(query);
  }

  Future<bool> deleteProduct(String id) async {
    return await productApiService.deleteProduct(id);
  }

  Future<Product?> updateProduct(String id, Product updatedProduct) async {
    return await productApiService.updateProduct(id, updatedProduct);
  }

  Future<Product?> supplyProduct(String id, int additionalStock) async {
    return await productApiService.supplyProduct(id, additionalStock);
  }
}
