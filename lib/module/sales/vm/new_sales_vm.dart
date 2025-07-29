// import 'dart:async';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:etegram_business/base/base_vm.dart';
// import 'package:etegram_business/core/model/get_scan_response.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/service/local/user_service.dart';
// import 'package:etegram_business/utils/snack_message.dart';
//
// class SaleViewModel extends BaseViewModel {
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   List<Cart> cartItems = [];
//   double discount = 5.0;
//   double tax = 0.0;
//   String paymentMethod = 'CASH'; // Default to CASH
//   final _customerService = locator<CustomerService>();
//   final Map<String, ScanProduct> _productCache = {};
//   final Set<String> scannedBarcodes = {};
//   Timer? _debounceTimer;
//   void updateLoading(bool value) {
//     isLoading.value = value;
//     notifyListeners();
//   }
//
//   void updateDiscount(double value) {
//     discount = value;
//     notifyListeners();
//   }
//
//   void resetScannerState() {
//     _productCache.clear();
//     scannedBarcodes.clear();
//     print('SaleViewModel: Scanner state reset');
//   }
//
//   void updateTax(double value) {
//     tax = value;
//     notifyListeners();
//   }
//
//   void updatePaymentMethod(String method) {
//     paymentMethod = method == 'POS' ? 'CARD' : method.toUpperCase();
//     print('Selected payment method: $paymentMethod');
//     notifyListeners();
//   }
//
//   Future<bool> addToCart(String barcode, String activeStoreId) async {
//     try {
//       final ownerId = await _customerService.getOwnerId();
//       if (ownerId == null) {
//         print('Owner ID is missing');
//         showCustomToast('Owner ID is missing.');
//         return false;
//       }
//
//       // Always fetch from the database to ensure freshness
//       print('Making API call for barcode: $barcode');
//       final response = await salesRepository.getScanProduct(
//         code: barcode,
//         ownerId: ownerId,
//         storeId: activeStoreId,
//       );
//
//       print(
//           'addToCart Response: success=${response?.success}, message=${response?.message}, product=${response?.data?.product?.toJson()}');
//
//       if (response?.success == true && response?.data?.product != null) {
//         final product = response!.data!.product!;
//         _productCache[barcode] = product; // Update cache
//         _addOrUpdateCartItem(product);
//         notifyListeners();
//         print('Product added to cart: ${product.name}, code: ${product.code}');
//         return true;
//       } else {
//         print('Product not found: ${response?.message}');
//         _productCache.remove(barcode); // Clear cache for invalid barcode
//         showCustomToast(response?.message ?? 'Product not found.');
//         return false;
//       }
//     } catch (e, stackTrace) {
//       print('Error adding product to cart: $e\n$stackTrace');
//       _productCache.remove(barcode); // Clear cache on error
//       showCustomToast('Error scanning product: $e');
//       return false;
//     }
//   }
//
//   void _addOrUpdateCartItem(ScanProduct product) {
//     final existingIndex =
//         cartItems.indexWhere((item) => item.code == product.code);
//     if (existingIndex != -1) {
//       if (cartItems[existingIndex].quantity + 1 <= product.availableQuantity) {
//         cartItems[existingIndex].quantity += 1;
//         cartItems[existingIndex].subtotal =
//             cartItems[existingIndex].quantity * cartItems[existingIndex].price;
//         print(
//             "Updated cart item: ${product.name}, Quantity: ${cartItems[existingIndex].quantity}, Subtotal: ${cartItems[existingIndex].subtotal}");
//       } else {
//         showCustomToast(
//             'Maximum stock reached for ${product.name}. Available: ${product.availableQuantity}');
//       }
//     } else {
//       final newItem = Cart(
//         id: product.id ?? '',
//         name: product.name ?? 'Unknown Product',
//         price: product.price ?? 0.0,
//         code: product.code ?? '',
//         quantity: 1,
//         subtotal: product.price ?? 0.0,
//         availableQuantity: product.availableQuantity,
//         size: product.size ?? '0',
//       );
//       cartItems.add(newItem);
//       print(
//           "Added new cart item: ${newItem.name}, Quantity: ${newItem.quantity}, Subtotal: ${newItem.subtotal}");
//     }
//
//     if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
//     _debounceTimer = Timer(const Duration(milliseconds: 300), () {
//       notifyListeners();
//       print(
//           "Current cart state: ${cartItems.map((item) => 'Name: ${item.name}, Code: ${item.code}, Qty: ${item.quantity}, Subtotal: ${item.subtotal}').join('; ')}");
//     });
//   }
//
//   void removeItemFromReview(Cart item) {
//     cartItems.remove(item);
//     print("Removed cart item: ${item.name}, Code: ${item.code}");
//     notifyListeners();
//   }
//
//   void updateItemQuantityInReview(Cart cartItem, int newQuantity) {
//     final index = cartItems.indexWhere((item) => item.code == cartItem.code);
//     if (index != -1) {
//       if (newQuantity <= cartItems[index].availableQuantity &&
//           newQuantity > 0) {
//         cartItems[index].quantity = newQuantity;
//         cartItems[index].subtotal = newQuantity * cartItems[index].price;
//         print(
//             "Updated quantity for ${cartItems[index].name}: New Qty: $newQuantity, Subtotal: ${cartItems[index].subtotal}");
//       } else {
//         showCustomToast(
//             'Cannot set quantity to $newQuantity for ${cartItem.name}. Available stock: ${cartItems[index].availableQuantity}.');
//       }
//       notifyListeners();
//     }
//   }
//
//   Future<double> calculateTotalPrice() async {
//     return await compute(_calculateTotalPrice, {
//       'cartItems': cartItems,
//       'discount': discount,
//       'tax': tax,
//     });
//   }
//
//   static double _calculateTotalPrice(Map<String, dynamic> data) {
//     final List<Cart> cartItems = data['cartItems'] as List<Cart>;
//     final double discount = data['discount'] as double;
//     final double tax = data['tax'] as double;
//     double total = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
//     total -= total * (discount / 100);
//     total += total * (tax / 100);
//     print("Calculated total price: $total, Discount: $discount%, Tax: $tax%");
//     return total;
//   }
//
//   Future<String?> processCheckout(List<Cart> cartItems) async {
//     final storeId = await _customerService.getActiveStoreId();
//     if (storeId == null) {
//       print('Checkout failed: Store ID is missing');
//       showCustomToast('Store ID is missing.');
//       return "Store ID is missing.";
//     }
//
//     if (cartItems.isEmpty) {
//       print('Checkout failed: Cart is empty');
//       showCustomToast('Cart is empty. Please scan a product.');
//       return "Cart is empty.";
//     }
//
//     if (paymentMethod.isEmpty) {
//       print('Checkout failed: Payment method not selected');
//       showCustomToast('Please select a payment method.');
//       return "Payment method not selected.";
//     }
//
//     updateLoading(true);
//     try {
//       final formattedCartItems = cartItems
//           .map((item) => {
//                 'code': item.code,
//                 'quantity': item.quantity.toInt(), // Ensure integer for backend
//               })
//           .toList();
//
//       print('Initiating checkout with:');
//       print('Cart: $formattedCartItems');
//       print('Store ID: $storeId');
//       print('Discount: $discount');
//       print('Tax: $tax');
//       print('Payment Method: $paymentMethod');
//
//       final response = await salesRepository.checkout(
//         cartItems: formattedCartItems,
//         discount: discount,
//         tax: tax,
//         paymentMethod: paymentMethod,
//         storeId: storeId,
//       );
//
//       print('Checkout response:');
//       print('Success: ${response?.success}');
//       print('Message: ${response?.message}');
//       print('Data: ${response?.data?.toJson()}');
//
//       if (response?.success == true) {
//         this.cartItems.clear();
//         _productCache.clear();
//         scannedBarcodes.clear();
//         paymentMethod = 'CASH';
//         notifyListeners();
//         print('Checkout successful, cart and scanned barcodes cleared');
//         showCustomToast('Checkout completed successfully!', success: true);
//         return null;
//       } else {
//         final errorMessage = response?.message ?? 'Checkout failed.';
//         print('Checkout failed: $errorMessage');
//         showCustomToast(errorMessage, success: false);
//         return errorMessage;
//       }
//     } catch (e, stackTrace) {
//       print('Checkout error: $e\n$stackTrace');
//       showCustomToast('Error processing checkout: $e', success: false);
//       return 'Error processing checkout: $e';
//     } finally {
//       updateLoading(false);
//     }
//   }
//
//   void clearCart(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Clear Cart?"),
//         content: const Text(
//             "Are you sure you want to remove all items from the cart?"),
//         actions: [
//           TextButton(
//             child: const Text("Cancel"),
//             onPressed: () => Navigator.of(ctx).pop(),
//           ),
//           TextButton(
//             child: const Text("Clear All"),
//             onPressed: () {
//               cartItems.clear();
//               _productCache.clear();
//               scannedBarcodes.clear();
//               print("Cart cleared");
//               notifyListeners();
//               Navigator.of(ctx).pop();
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     print('SaleViewModel dispose called, but skipped for singleton');
//   }
// }

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/core/model/get_scan_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/utils/snack_message.dart';

class SaleViewModel extends BaseViewModel {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<List<Cart>> cartItems = ValueNotifier<List<Cart>>([]);
  double discount = 5.0;
  double tax = 0.0;
  String paymentMethod = 'CASH';
  final _customerService = locator<CustomerService>();
  final Map<String, ScanProduct> _productCache = {};
  final Set<String> scannedBarcodes = {};
  Timer? _debounceTimer;

  void updateLoading(bool value) {
    isLoading.value = value;
    notifyListeners();
  }

  void updateDiscount(double value) {
    discount = value;
    notifyListeners();
  }

  void init() {
    print('SaleViewModel: Initializing');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (cartItems.value.isEmpty) {
        resetScannerState();
      }
    });
  }

  void resetScannerState() {
    _productCache.clear();
    scannedBarcodes.clear();
    cartItems.value = [];
    print('SaleViewModel: Scanner state reset');
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

  Future<Map<String, dynamic>> addToCart(
      String barcode, String activeStoreId) async {
    try {
      final ownerId = await _customerService.getOwnerId();
      if (ownerId == null) {
        print('Owner ID is missing');
        showCustomToast('Owner ID is missing.', success: false);
        return {
          'success': false,
          'message': 'Owner ID is missing.',
          'product': null,
          'name': null
        };
      }

      if (_productCache.containsKey(barcode)) {
        print('Cache hit for barcode: $barcode');
        _addOrUpdateCartItem(_productCache[barcode]!);
        return {
          'success': true,
          'message': 'Product added from cache.',
          'product': _productCache[barcode],
          'name': _productCache[barcode]!.name
        };
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
        return {
          'success': true,
          'message': 'Product added to cart.',
          'product': product,
          'name': product.name
        };
      } else {
        print('Product not found or out of stock: ${response?.message}');
        _productCache.remove(barcode);
        final message = response?.message ?? 'Product not found.';
        // Extract product name from message if out of stock
        String? productName;
        if (message.toLowerCase().contains('out of stock')) {
          final match =
              RegExp(r'Product (.*?) is out of stock').firstMatch(message);
          productName = match?.group(1);
        }
        return {
          'success': false,
          'message': message,
          'product': response?.data?.product,
          'name': productName,
        };
      }
    } catch (e, stackTrace) {
      print('Error adding product to cart: $e\n$stackTrace');
      _productCache.remove(barcode);
      return {
        'success': false,
        'message': 'Error scanning product: $e',
        'product': null,
        'name': null
      };
    }
  }

  void _addOrUpdateCartItem(ScanProduct product) {
    final currentCart = List<Cart>.from(cartItems.value);
    final existingIndex =
        currentCart.indexWhere((item) => item.code == product.code);
    if (existingIndex != -1) {
      if (currentCart[existingIndex].quantity + 1 <=
          product.availableQuantity) {
        currentCart[existingIndex].quantity += 1;
        currentCart[existingIndex].subtotal =
            currentCart[existingIndex].quantity *
                currentCart[existingIndex].price;
        print(
            "Updated cart item: ${product.name}, Quantity: ${currentCart[existingIndex].quantity}, Subtotal: ${currentCart[existingIndex].subtotal}");
      } else {
        showCustomToast(
            'Maximum stock reached for ${product.name}. Available: ${product.availableQuantity}',
            success: false);
      }
    } else {
      final newItem = Cart(
        id: product.id ?? '',
        name: product.name ?? 'Unknown Product',
        price: product.price ?? 0.0,
        code: product.code ?? '',
        quantity: 1,
        subtotal: product.price ?? 0.0,
        availableQuantity: product.availableQuantity,
        size: product.size ?? '0',
      );
      currentCart.add(newItem);
      print(
          "Added new cart item: ${newItem.name}, Quantity: ${newItem.quantity}, Subtotal: ${newItem.subtotal}");
    }

    cartItems.value = currentCart;
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      notifyListeners();
      print(
          "Current cart state: ${cartItems.value.map((item) => 'Name: ${item.name}, Code: ${item.code}, Qty: ${item.quantity}, Subtotal: ${item.subtotal}').join('; ')}");
    });
  }

  void removeItemFromReview(Cart item) {
    final currentCart = List<Cart>.from(cartItems.value);
    currentCart.removeWhere((cartItem) => cartItem.code == item.code);
    cartItems.value = currentCart;
    print("Removed cart item: ${item.name}, Code: ${item.code}");
    notifyListeners();
  }

  void updateItemQuantityInReview(Cart cartItem, int newQuantity) {
    final currentCart = List<Cart>.from(cartItems.value);
    final index = currentCart.indexWhere((item) => item.code == cartItem.code);
    if (index != -1) {
      if (newQuantity <= currentCart[index].availableQuantity &&
          newQuantity > 0) {
        currentCart[index].quantity = newQuantity;
        currentCart[index].subtotal = newQuantity * currentCart[index].price;
        print(
            "Updated quantity for ${currentCart[index].name}: New Qty: $newQuantity, Subtotal: ${currentCart[index].subtotal}");
      } else {
        showCustomToast(
            'Cannot set quantity to $newQuantity for ${cartItem.name}. Available stock: ${currentCart[index].availableQuantity}.',
            success: false);
      }
      cartItems.value = currentCart;
      notifyListeners();
    }
  }

  Future<double> calculateTotalPrice() async {
    return await compute(_calculateTotalPrice, {
      'cartItems': cartItems.value,
      'discount': discount,
      'tax': tax,
    });
  }

  static double _calculateTotalPrice(Map<String, dynamic> data) {
    final List<Cart> cartItems = data['cartItems'] as List<Cart>;
    final double discount = data['discount'] as double;
    final double tax = data['tax'] as double;
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
      showCustomToast('Store ID is missing.', success: false);
      return "Store ID is missing.";
    }

    if (cartItems.isEmpty) {
      print('Checkout failed: Cart is empty');
      showCustomToast('Cart is empty. Please scan a product.', success: false);
      return "Cart is empty.";
    }

    if (paymentMethod.isEmpty) {
      print('Checkout failed: Payment method not selected');
      showCustomToast('Please select a payment method.', success: false);
      return "Payment method not selected.";
    }

    updateLoading(true);
    try {
      final formattedCartItems = cartItems
          .map((item) => {
                'code': item.code,
                'quantity': item.quantity.toInt(),
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
        paymentMethod: paymentMethod,
        storeId: storeId,
      );

      print('Checkout response:');
      print('Success: ${response?.success}');
      print('Message: ${response?.message}');
      print('Data: ${response?.data?.toJson()}');

      if (response?.success == true) {
        this.cartItems.value = [];
        _productCache.clear();
        scannedBarcodes.clear();
        paymentMethod = 'CASH';
        notifyListeners();
        print('Checkout successful, cart and scanned barcodes cleared');
        showCustomToast('Checkout completed successfully!', success: true);
        return null;
      } else {
        final errorMessage = response?.message ?? 'Checkout failed.';
        print('Checkout failed: $errorMessage');
        showCustomToast(errorMessage, success: false);
        return errorMessage;
      }
    } catch (e, stackTrace) {
      print('Checkout error: $e\n$stackTrace');
      showCustomToast('Error processing checkout: $e', success: false);
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
              cartItems.value = [];
              _productCache.clear();
              scannedBarcodes.clear();
              print("Cart cleared");
              notifyListeners();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('SaleViewModel dispose called');
    _debounceTimer?.cancel(); // Cancel the debounce timer
    cartItems.dispose();
    super.dispose();
  }
}
