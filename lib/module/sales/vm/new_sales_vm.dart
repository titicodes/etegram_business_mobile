import 'package:dio/dio.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/repository/sales_repository.dart';
import '../../../app_widget/barcode_scanner_view.dart';
import '../../../core/model/cart_item.dart';
import '../../../core/model/checkout_response.dart';
import '../../../core/model/get_scan_response.dart';
import 'package:flutter/material.dart';

import '../../../locator.dart';
import '../../../service/local/user_service.dart';
import '../../../utils/snack_message.dart';

class SaleViewModel extends BaseViewModel {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late BuildContext context;
  List<ScanProduct> reviewItems = [];
  List<Cart> cartItems = [];
  double discount = 0.0;
  double tax = 0.0;
  String paymentMethod = 'Cash';
  final _customerService = locator<CustomerService>();

  // Cache for previously scanned barcodes to prevent duplicate API calls
  final Map<String, ScanProduct> _productCache = {};

  void updateLoading(bool value) {
    isLoading.value = value;
    notifyListeners();
  }

  void updateDiscount(double value) {
    discount = value;
    notifyListeners();
  }

  void updateTax(double value) {
    tax = value;
    notifyListeners();
  }

  void updatePaymentMethod(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  Future<void> scanAndAddToReview(int code, BuildContext context) async {
    try {
      startLoader();
      final ownerId = await _customerService.getOwnerId();
      final storeId = await _customerService.getStoreId();

      if (ownerId == null || storeId == null) {
        showCustomToast('Missing owner or store ID.');
        return;
      }

      // First check if we have this product in cache
      final codeStr = code.toString();
      if (_productCache.containsKey(codeStr)) {
        final product = _productCache[codeStr]!;
        reviewItems.add(product);
        moveReviewToCart();
        notifyListeners();
        return;
      }

      // FIXED: Better error handling and debugging for API call
      print('Making API call for barcode: $code');
      final response = await salesRepository.getScanProduct(
          code: code, ownerId: ownerId, storeId: storeId);

      print('API response success: ${response?.success}');
      print('API response message: ${response?.message}');
      print('API response data: ${response?.data?.toJson()}');

      if (response?.success == true && response?.data?.product != null) {
        final product = response!.data!.product!;

        // Cache the product for future scans
        _productCache[codeStr] = product;

        reviewItems.add(product);
        moveReviewToCart();
        notifyListeners();
      } else {
        showCustomToast(
          response?.message ?? 'Product not found.',
        );
      }
    } catch (e) {
      print("Error in scanAndAddToReview: $e");
      showCustomToast('Error scanning product.');
    } finally {
      stopLoader();
    }
  }

  // Function to move items to the cart after scanning
  void moveReviewToCart() {
    cartItems = reviewItems
        .map((product) => Cart(
              id: product.id ?? '',
              name: product.name ?? 'Unknown Product',
              price: product.price ?? 0,
              code: product.code ?? '',
              quantity: 1,
              subtotal: product.price ?? 0,
            ))
        .toList();
    notifyListeners(); // Notify listeners after updating the cart
  }

  Future<CheckoutResponse?> checkout({
    required List<Map<String, dynamic>> cartItems,
    double discount = 0.0,
    double tax = 0.0,
    required String paymentMethod,
    required String storeId,
  }) async {
    try {
      startLoader();
      CheckoutResponse? response = await salesRepository.checkout(
        cartItems: cartItems,
        discount: discount,
        tax: tax,
        paymentMethod: paymentMethod,
        storeId: storeId,
      );

      if (response != null && response.success == true) {
        this.cartItems.clear();
        _productCache.clear(); // Clear cache after successful checkout
        notifyListeners();
        return response;
      } else {
        showCustomToast(response?.message ?? 'Checkout failed.');
        return null;
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    } catch (e, stackTrace) {
      // Print the full exception and stack trace
      print('Unexpected error during checkout: $e');
      print('Stack trace: $stackTrace');
      showCustomToast('An unexpected error occurred during checkout: $e');
      return null;
    } finally {
      stopLoader();
    }
  }

  // FIXED: Improved checkIfProductExists method with better debugging
  Future<bool> checkIfProductExists(
      String barcode, BuildContext context) async {
    try {
      startLoader();

      // Validate barcode
      final barcodeInt = int.tryParse(barcode.trim());
      if (barcodeInt == null) {
        showCustomToast('Invalid barcode format.');
        return false;
      }

      final ownerId = await _customerService.getOwnerId();
      final storeId = await _customerService.getStoreId();

      if (ownerId == null || storeId == null) {
        showCustomToast('Missing owner or store ID.');
        return false;
      }

      // Check cache first to save API calls
      if (_productCache.containsKey(barcode)) {
        final product = _productCache[barcode]!;
        _addOrUpdateCartItem(product);
        return true;
      }

      // DEBUGGING: Print parameters
      print(
          'Checking existence of barcode: $barcodeInt, Owner ID: $ownerId, Store ID: $storeId');

      // Call API to fetch scanned product with extensive logging
      print('About to call getScanProduct API');
      final response = await salesRepository.getScanProduct(
          code: barcodeInt, ownerId: ownerId, storeId: storeId);

      print('getScanProduct response received');
      print('Response success: ${response?.success}');
      print('Response message: ${response?.message}');

      // If response is null or unsuccessful, show message and return false
      if (response == null || response.success != true) {
        showCustomToast(response?.message ?? 'Product not found.');
        return false;
      }

      // If product is null (might happen if API returns success but no product)
      if (response.data?.product == null) {
        showCustomToast('Product data not available.');
        return false;
      }

      final product = response.data!.product!;

      // Cache the product for future scans
      _productCache[barcode] = product;

      // Ensure product has required fields
      if (product.id == null ||
          product.name == null ||
          product.price == null ||
          product.code == null) {
        showCustomToast('Product data is incomplete.');
        return false;
      }

      // Check stock availability
      final stock = product.stock ?? 0;
      if (stock <= 0) {
        showCustomToast('Product is out of stock.');
        return false;
      }

      // Add or update cart item
      _addOrUpdateCartItem(product);

      return true;
    } catch (e, stackTrace) {
      print("Unexpected error in checkIfProductExists: $e\n$stackTrace");
      showCustomToast('An unexpected error occurred while checking product.');
      return false;
    } finally {
      stopLoader();
    }
  }

  // ADDED: Helper method to add or update cart items
  void _addOrUpdateCartItem(ScanProduct product) {
    // Check if product is already in cart
    final existingIndex =
        cartItems.indexWhere((item) => item.code == product.code);

    if (existingIndex != -1) {
      // Product already exists → update quantity & subtotal
      cartItems[existingIndex].quantity += 1;
      cartItems[existingIndex].subtotal =
          cartItems[existingIndex].quantity * product.price!;
      print("Updated quantity for ${product.name}");
    } else {
      // Product is new → add to cart
      cartItems.add(Cart(
        id: product.id!,
        name: product.name!,
        price: product.price!,
        code: product.code!,
        quantity: 1,
        subtotal: product.price!,
      ));
      print("Added ${product.name} to cart");
    }

    // Debug print current cart state
    for (var item in cartItems) {
      print(
          'Cart → ${item.name}, Qty: ${item.quantity}, Subtotal: ${item.subtotal}');
    }

    notifyListeners();
  }

  void removeItemFromReview(Cart item) {
    cartItems.remove(item);
    notifyListeners();
  }

  void updateItemQuantityInReview(Cart cartItem, int newQuantity) {
    final index = cartItems.indexWhere((item) => item.code == cartItem.code);
    if (index != -1) {
      cartItems[index].quantity = newQuantity;
      cartItems[index].subtotal =
          cartItems[index].quantity * cartItems[index].price;
      notifyListeners();
    }
  }

  void addProductToCart(Cart product) {
    // Check if the product is already in the cart
    if (!cartItems.contains(product)) {
      cartItems.add(product); // Add new product to the cart
    } else {
      showCustomToast('This product is already in the cart.');
    }
  }

  // Calculate total price
  double calculateTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += item.subtotal ?? 0;
    }
    return total;
  }

  Future<void> startBarcodeScan(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScannerView(),
      ),
    );
  }

  Future<bool> getProductByBarcode(String barcode) async {
    try {
      startLoader();

      final barcodeInt = int.tryParse(barcode);
      if (barcodeInt == null) {
        showCustomToast('Invalid barcode format.');
        return false;
      }

      final ownerId = await _customerService.getOwnerId();
      final storeId = await _customerService.getStoreId();

      if (ownerId == null || storeId == null) {
        showCustomToast('Missing owner or store ID.');
        return false;
      }

      // Check cache first
      if (_productCache.containsKey(barcode)) {
        return true;
      }

      final response = await salesRepository.getScanProduct(
          code: barcodeInt, ownerId: ownerId, storeId: storeId);

      if (response != null &&
          response.success == true &&
          response.data?.product != null) {
        // Add to cache
        _productCache[barcode] = response.data!.product!;
        return true; // Product exists
      }

      showCustomToast(response?.message ?? 'Product not found.');
      return false; // Not found
    } catch (e) {
      print("Error checking product existence: $e");
      showCustomToast('Error checking product: $e');
      return false;
    } finally {
      stopLoader();
    }
  }

  void clearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Clear Cart?"),
        content:
            Text("Are you sure you want to remove all items from the cart?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text("Clear All"),
            onPressed: () {
              cartItems.clear();
              _productCache.clear(); // Clear cache on cart clear
              notifyListeners();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<String?> processCheckout(List<Cart> cartItems) async {
    final String? storeId = await locator<CustomerService>().getStoreId();
    if (storeId == null) return "Store ID is missing.";

    updateLoading(true);

    try {
      final response = await checkout(
        cartItems: cartItems.map((e) => e.toJson()).toList(),
        discount: discount,
        tax: tax,
        paymentMethod: paymentMethod,
        storeId: storeId,
      );

      if (response?.success == true) {
        _productCache.clear(); // Clear cache after successful checkout
        return null; // success
      } else {
        return response?.message ?? "Unknown error";
      }
    } catch (e) {
      return "An error occurred: $e";
    } finally {
      updateLoading(false);
    }
  }

  // FIXED: Improved error handling
  void _handleDioError(DioException e) {
    String errorMessage = 'Error processing request.';
    if (e.response != null) {
      if (e.response!.data is Map<String, dynamic> &&
          e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      } else {
        errorMessage = 'API Error: ${e.response!.statusCode}';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      errorMessage =
          'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      errorMessage =
          'Server is taking too long to respond. Please try again later.';
    } else {
      errorMessage = 'Network error: ${e.message}';
    }
    print("DioException: $errorMessage");
    showCustomToast(errorMessage);
  }
}
