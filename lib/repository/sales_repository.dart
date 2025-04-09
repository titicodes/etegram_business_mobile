import 'package:etegram_business/service/web/sales_api_service.dart';

import '../core/model/checkout_response.dart';
import '../core/model/get_scan_response.dart';
import '../locator.dart';
import '../service/local/cache.dart';
import '../service/local/storage_service.dart';

class SalesRepository {
  StorageService storageService = locator<StorageService>();
  AppCache appCache = locator<AppCache>();
  SalesApiService salesApiService = locator<SalesApiService>();

  Future<CheckoutResponse?> checkout({
    required List<Map<String, dynamic>> cartItems,
    double discount = 0.0, // Optional discount with default value 0.0
    double tax = 0.0, // Optional tax with default value 0.0
    required String paymentMethod,
  }) async {
    return await salesApiService.checkout(
        cartItems: cartItems, paymentMethod: paymentMethod);
  }

  Future<GetScanResponse?> getScanProduct({required int? code}) async {
    return await salesApiService.getScanProduct(code: code);
  }

  Future<void> sendFcmToken(String userId, String fcmToken) async {
    return await salesApiService.sendFcmToken(userId, fcmToken);
  }
}
