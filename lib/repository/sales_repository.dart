import 'package:etegram_business/core/model/checkout_response.dart';
import 'package:etegram_business/core/model/get_scan_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/web/sales_api_service.dart';
import '../core/model/sales_records.dart';

class SalesRepository {
  final SalesApiService _salesApiService = locator<SalesApiService>();

  Future<GetScanResponse?> getScanProduct({
    required String code,
    required String storeId,
  }) async {
    try {
      if (code.isEmpty || code == "0") {
        return GetScanResponse(
          success: false,
          message: 'Invalid barcode',
          data: null,
        );
      }

      if (storeId.isEmpty) {
        return GetScanResponse(
          success: false,
          message: 'Owner ID or Store ID missing',
          data: null,
        );
      }

      final response = await _salesApiService.getScanProduct(
        code: code,
        storeId: storeId,
      );

      return response;
    } catch (e) {
      print('Error in SalesRepository.getScanProduct: $e');
      return GetScanResponse(
        success: false,
        message: 'Failed to get product: $e',
        data: null,
      );
    }
  }

  Future<CheckoutResponse?> checkout({
    required List<Map<String, dynamic>> cartItems,
    required double discount,
    required double tax,
    required String paymentMethod,
    required String storeId,
    String? deliveryAddress,
  }) async {
    try {
      if (cartItems.isEmpty) {
        return CheckoutResponse(
          success: false,
          message: 'Cart is empty',
          data: null,
        );
      }

      if (storeId.isEmpty) {
        return CheckoutResponse(
          success: false,
          message: 'Store ID is missing',
          data: null,
        );
      }

      final sanitizedCartItems = cartItems.map((item) {
        return {
          'code': item['code'] as String,
          'quantity': (item['quantity'] as num).toInt(),
        };
      }).toList();

      final response = await _salesApiService.checkout(
          cartItems: sanitizedCartItems,
          discount: discount,
          tax: tax,
          paymentMethod: paymentMethod,
          storeId: storeId,
          deliveryAddress: deliveryAddress);

      return response;
    } catch (e, stackTrace) {
      print('Error in SalesRepository.checkout: $e\n$stackTrace');
      return CheckoutResponse(
        success: false,
        message: 'Failed to process checkout: $e',
        data: null,
      );
    }
  }

  Future<List<SalesRecord>> getSalesHistory({
    required String storeId,
    String? productId,
  }) async {
    return _salesApiService.getSalesHistory(
      storeId: storeId,
      productId: productId,
    );
  }

  Future<List<SalesRecord>> getOwingRecords({
    required String storeId,
    String? supplierId,
  }) async {
    return _salesApiService.getOwingRecords(
      storeId: storeId,
      supplierId: supplierId,
    );
  }

  Future<List<SalesRecord>> getOwedRecords({
    required String storeId,
    String? customerId,
  }) async {
    return _salesApiService.getOwedRecords(
      storeId: storeId,
      customerId: customerId,
    );
  }
}
