import 'package:etegram_business/core/model/checkout_response.dart';
import 'package:etegram_business/core/model/get_scan_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/web/sales_api_service.dart';

class SalesRepository {
  final SalesApiService _salesApiService = locator<SalesApiService>();

  // FIXED: Improved error handling in getScanProduct
  Future<GetScanResponse?> getScanProduct({
    required int code,
    required String ownerId,
    required String storeId,
  }) async {
    try {
      // Validate inputs
      if (code <= 0) {
        return GetScanResponse(
          success: false,
          message: 'Invalid barcode',
          data: null,
        );
      }

      if (ownerId.isEmpty || storeId.isEmpty) {
        return GetScanResponse(
          success: false,
          message: 'Owner ID or Store ID missing',
          data: null,
        );
      }

      // Make API call and handle response
      final response = await _salesApiService.getScanProduct(
        code: code,
        ownerId: ownerId,
        storeId: storeId,
      );

      // Return the response (which might be null, success=true, or success=false)
      return response;
    } catch (e) {
      print('Error in SalesRepository.getScanProduct: $e');

      // Return a valid response object with the error message
      return GetScanResponse(
        success: false,
        message: 'Failed to get product: $e',
        data: null,
      );
    }
  }

  Future<CheckoutResponse?> checkout({
    required List<Map<String, dynamic>> cartItems,
    double discount = 0.0,
    double tax = 0.0,
    required String paymentMethod,
    required String storeId,
  }) async {
    try {
      // Validate inputs
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

      // Make API call and handle response
      final response = await _salesApiService.checkout(
        cartItems: cartItems,
        discount: discount,
        tax: tax,
        paymentMethod: paymentMethod,
        storeId: storeId,
      );

      // Return the response (which might be null, success=true, or success=false)
      return response;
    } catch (e) {
      print('Error in SalesRepository.checkout: $e');

      // Return a valid response object with the error message
      return CheckoutResponse(
        success: false,
        message: 'Failed to process checkout: $e',
        data: null,
      );
    }
  }
}
