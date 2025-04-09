import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/repository/sales_repository.dart';
import '../../../app_widget/barcode_scanner_view.dart';
import '../../../core/model/cart_item.dart';
import '../../../core/model/checkout_response.dart';
import '../../../core/model/get_scan_response.dart';
import 'package:flutter/material.dart';

import '../../../utils/snack_message.dart';

class SaleViewModel extends BaseViewModel {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late BuildContext context;
  List<ScanProduct> reviewItems = [];
  List<Cart> cartItems = [];
  double discount = 0.0;
  double tax = 0.0;
  String paymentMethod = 'Cash';

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
      final response = await salesRepository.getScanProduct(code: code);

      if (response?.success == true && response?.data?.product != null) {
        final product = response!.data!.product!;
        reviewItems.add(product);
        moveReviewToCart();
        notifyListeners();
      } else {
        showCustomToast(
          'Product not found.',
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
  }) async {
    try {
      startLoader();
      CheckoutResponse? response = await salesRepository.checkout(
        cartItems: cartItems,
        discount: discount,
        tax: tax,
        paymentMethod: paymentMethod,
      );

      if (response != null && response.success == true) {
        this.cartItems.clear();
        notifyListeners();
        return response;
      } else {
        showCustomToast(response?.message ?? 'Checkout failed.');
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Dio Error: ${e.response!.statusCode}, ${e.response!.data}');
        if (e.response!.data is Map<String, dynamic>) {
          showCustomToast('Checkout failed: ${e.response!.data['message']}');
        } else {
          showCustomToast('Checkout failed: ${e.response!.data}');
        }
      } else {
        print('Dio Error (Network): ${e.message}');
        showCustomToast('Checkout failed: Network error - ${e.message}');
      }
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

      // Call API to fetch scanned product
      final response = await salesRepository.getScanProduct(code: barcodeInt);
      print("API Response: $response");

      if (response == null ||
          response.success != true ||
          response.data?.product == null) {
        showCustomToast('Product not found.');
        return false;
      }

      final product = response.data!.product!;

      // Ensure product has required fields
      if ([product.id, product.name, product.price, product.code]
          .contains(null)) {
        showCustomToast('Product data is incomplete.');
        return false;
      }

      // Check stock availability
      final stock = product.stock ?? 0;
      if (stock <= 0) {
        showCustomToast('Product is out of stock.');
        return false;
      }

      // ✅ Check if product is already in cart
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

      // Debug print
      for (var item in cartItems) {
        print(
            'Cart → ${item.name}, Qty: ${item.quantity}, Subtotal: ${item.subtotal}');
      }

      notifyListeners();
      return true;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    } catch (e, stackTrace) {
      print("Unexpected error: $e\n$stackTrace");
      showCustomToast('An unexpected error occurred.');
      return false;
    } finally {
      stopLoader();
    }
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
        builder: (context) => const BarcodeScannerView(
          purpose: ScanPurpose.checkout,
        ),
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

      final response = await salesRepository.getScanProduct(code: barcodeInt);

      if (response != null &&
          response.success == true &&
          response.data?.product != null) {
        return true; // Product exists
      }

      return false; // Not found
    } catch (e) {
      print("Error checking product existence: $e");
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
              notifyListeners();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

void _handleError(DioException e) {
  String errorMessage = 'Error checking product.';
  if (e.response != null) {
    errorMessage = 'API Error: ${e.response!.data}';
  }
  print("DioException: $e");
  showCustomToast(errorMessage);
}
