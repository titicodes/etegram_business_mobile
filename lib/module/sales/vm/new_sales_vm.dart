

import 'package:dio/dio.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/core/model/get_scan_response.dart';
import 'package:flutter/material.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/utils/snack_message.dart';

class SaleViewModel extends BaseViewModel {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Cart> cartItems = [];
  double discount = 5.0;
  double tax = 0.0;
  String? paymentMethod;
  final _customerService = locator<CustomerService>();
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
    paymentMethod = method == 'POS' ? 'CARD' : method.toUpperCase();
    print('Selected payment method: $paymentMethod');
    notifyListeners();
  }

  Future<bool> addToCart(String barcode, String activeStoreId) async {
    try {
      final ownerId = await _customerService.getOwnerId();
      if (ownerId == null) {
        print('Owner ID is missing');
        showCustomToast('Owner ID is missing.');
        return false;
      }

      // Check cache first to avoid unnecessary API calls
      if (_productCache.containsKey(barcode)) {
        _addOrUpdateCartItem(_productCache[barcode]!);
        notifyListeners();
        return true;
      }

      print('Making API call for barcode: $barcode');
      final response = await salesRepository.getScanProduct(
        code: barcode,
        ownerId: ownerId,
        storeId: activeStoreId,
      );

      print(
          'addToCart Response: success=${response?.success}, message=${response?.message}, product=${response?.data?.product?.toJson()}');

      if (response?.success == true && response?.data?.product != null) {
        final product = response!.data!.product!;
        _productCache[barcode] = product;
        _addOrUpdateCartItem(product);
        notifyListeners();
        print('Product added to cart: ${product.name}, code: ${product.code}');
        return true;
      } else {
        print('Product not found: ${response?.message}');
        showCustomToast(response?.message ?? 'Product not found.');
        return false;
      }
    } catch (e, stackTrace) {
      print('Error adding product to cart: $e\n$stackTrace');
      showCustomToast('Error scanning product: $e');
      return false;
    }
  }

  void _addOrUpdateCartItem(ScanProduct product) {
    final existingIndex =
        cartItems.indexWhere((item) => item.code == product.code);
    if (existingIndex != -1) {
      if (cartItems[existingIndex].quantity + 1 <= (product.stock ?? 0)) {
        cartItems[existingIndex].quantity += 1;
        cartItems[existingIndex].subtotal =
            cartItems[existingIndex].quantity * product.price!;
        print(
            "Updated cart item: ${product.name}, Quantity: ${cartItems[existingIndex].quantity}, Subtotal: ${cartItems[existingIndex].subtotal}");
      } else {
        showCustomToast('Maximum stock reached for ${product.name}.');
      }
    } else {
      final newItem = Cart(
        id: product.id ?? '',
        name: product.name ?? 'Unknown Product',
        price: product.price ?? 0,
        code: product.code ?? '',
        quantity: 1,
        subtotal: product.price ?? 0,
        availableQuantity: product.stock ?? 0,
        size: product.size ?? '0',
      );
      cartItems.add(newItem);
      print(
          "Added new cart item: ${newItem.name}, Quantity: ${newItem.quantity}, Subtotal: ${newItem.subtotal}");
    }
    print(
        "Current cart state: ${cartItems.map((item) => 'Name: ${item.name}, Code: ${item.code}, Qty: ${item.quantity}, Subtotal: ${item.subtotal}').join('; ')}");
    print('Cart items in SaleViewModel: ${cartItems.length}');
  }

  void removeItemFromReview(Cart item) {
    cartItems.remove(item);
    print("Removed cart item: ${item.name}, Code: ${item.code}");
    notifyListeners();
  }

  void updateItemQuantityInReview(Cart cartItem, int newQuantity) {
    final index = cartItems.indexWhere((item) => item.code == cartItem.code);
    if (index != -1) {
      if (newQuantity <= cartItems[index].availableQuantity &&
          newQuantity > 0) {
        cartItems[index].quantity = newQuantity;
        cartItems[index].subtotal = newQuantity * cartItems[index].price;
        print(
            "Updated quantity for ${cartItems[index].name}: New Qty: $newQuantity, Subtotal: ${cartItems[index].subtotal}");
        notifyListeners();
      } else {
        showCustomToast('Invalid quantity for ${cartItem.name}.');
      }
    }
  }

  double calculateTotalPrice() {
    double total = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
    total -= total * (discount / 100);
    total += total * (tax / 100);
    print("Calculated total price: $total, Discount: $discount%, Tax: $tax%");
    return total;
  }

  Future<String?> processCheckout(List<Cart> cartItems) async {
    final storeId = await _customerService.getActiveStoreId();
    if (storeId == null) {
      print('Checkout failed: Store ID is missing');
      showCustomToast('Store ID is missing.');
      return "Store ID is missing.";
    }

    if (cartItems.isEmpty) {
      print('Checkout failed: Cart is empty');
      showCustomToast('Cart is empty. Please scan a product.');
      return "Cart is empty.";
    }

    if (paymentMethod == null) {
      print('Checkout failed: Payment method not selected');
      showCustomToast('Please select a payment method.');
      return "Payment method not selected.";
    }

    updateLoading(true);
    try {
      final formattedCartItems = cartItems
          .map((item) => {
                'code': item.code,
                'quantity': item.quantity,
              })
          .toList();

      print('Initiating checkout with:');
      print('Cart: $formattedCartItems');
      print('Store ID: $storeId');
      print('Discount: $discount');
      print('Tax: $tax');
      print('Payment Method: $paymentMethod');

      final response = await salesRepository.checkout(
        cartItems: formattedCartItems,
        discount: discount,
        tax: tax,
        paymentMethod: paymentMethod!,
        storeId: storeId,
      );

      print('Checkout response:');
      print('Success: ${response?.success}');
      print('Message: ${response?.message}');
      print('Data: ${response?.data}');

      if (response?.success == true) {
        this.cartItems.clear();
        _productCache.clear();
        paymentMethod = null;
        notifyListeners();
        print('Checkout successful, cart cleared');
        showCustomToast('Checkout completed successfully!');
        return null;
      } else {
        final errorMessage = response?.message ?? 'Checkout failed.';
        print('Checkout failed: $errorMessage');
        showCustomToast(errorMessage);
        return errorMessage;
      }
    } catch (e, stackTrace) {
      print('Checkout error: $e\n$stackTrace');
      showCustomToast('Error processing checkout: $e');
      return 'Error processing checkout: $e';
    } finally {
      updateLoading(false);
    }
  }

  void clearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear Cart?"),
        content: const Text(
            "Are you sure you want to remove all items from the cart?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text("Clear All"),
            onPressed: () {
              cartItems.clear();
              _productCache.clear();
              print("Cart cleared");
              notifyListeners();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _handleDioError(DioException e) {
    String errorMessage = 'Error processing request.';
    if (e.response != null && e.response!.data is Map<String, dynamic>) {
      errorMessage =
          e.response!.data['message'] ?? 'API Error: ${e.response!.statusCode}';
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

  @override
  void dispose() {
    print('SaleViewModel dispose called, but skipped for singleton');
  }
}
