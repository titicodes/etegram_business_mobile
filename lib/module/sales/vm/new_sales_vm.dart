import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/core/model/get_scan_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/utils/snack_message.dart';

import '../../../core/model/product_model.dart';

class SaleViewModel extends BaseViewModel {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<List<Cart>> cartItems = ValueNotifier<List<Cart>>([]);
  final ValueNotifier<double> discount = ValueNotifier<double>(0.0);
  double tax = 0.0;
  String paymentMethod = 'CASH';
  String? temporaryDeliveryAddress;
  final CustomerService customerService = locator<CustomerService>();
  final Map<String, ScanProduct> _productCache = {};
  final Set<String> scannedBarcodes = {};
  Timer? _debounceTimer;
  bool _isStoreOwner = false;

  SaleViewModel() {
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final role = await customerService.getUserRole();
    _isStoreOwner = role?.contains('STORE_OWNER') ?? false;
    print('SaleViewModel: User isStoreOwner: $_isStoreOwner');
    notifyListeners();
  }

  void updateLoading(bool value) {
    isLoading.value = value;
    notifyListeners();
  }

  void updateDiscount(double value) {
    if (_isStoreOwner) {
      if (value >= 0 && value <= 100) {
        discount.value = value;
        print('SaleViewModel: Updated discount to $value');
        notifyListeners();
      } else {
        showCustomToast('Discount must be between 0 and 100.', success: false);
      }
    } else {
      showCustomToast('Only store owners can apply discounts.', success: false);
    }
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
    temporaryDeliveryAddress = null;
    print('SaleViewModel: Scanner state reset');
    notifyListeners();
  }

  void updatePaymentMethod(String method) {
    paymentMethod = method == 'POS' ? 'CARD' : method.toUpperCase();
    print('SaleViewModel: Selected payment method: $paymentMethod');
    notifyListeners();
  }

  Future<Map<String, dynamic>> addToCart(String barcode, String storeId) async {
    try {
      if (_productCache.containsKey(barcode)) {
        print('SaleViewModel: Cache hit for barcode: $barcode');
        final product = _productCache[barcode]!;
        if (product.availableQuantity == 0) {
          return {
            'success': false,
            'message': 'Product ${product.name} is out of stock.',
            'product': product,
            'name': product.name,
          };
        }
        _addOrUpdateCartItem(product);
        return {
          'success': true,
          'message': 'Product added from cache.',
          'product': product,
          'name': product.name,
        };
      }

      print('SaleViewModel: Making API call for barcode: $barcode');
      final response = await salesRepository.getScanProduct(
        code: barcode,
        storeId: storeId,
      );

      print(
          'SaleViewModel: addToCart Response: success=${response?.success}, message=${response?.message}, product=${response?.data?.product?.toJson()}');

      if (response?.success == true && response?.data?.product != null) {
        final product = response!.data!.product!;
        if (product.availableQuantity == 0) {
          print('SaleViewModel: Product out of stock: ${product.name}');
          _productCache[barcode] = product;
          return {
            'success': false,
            'message': 'Product ${product.name} is out of stock.',
            'product': product,
            'name': product.name,
          };
        }
        _productCache[barcode] = product;
        _addOrUpdateCartItem(product);
        return {
          'success': true,
          'message': 'Product added to cart.',
          'product': product,
          'name': product.name,
        };
      } else {
        print('SaleViewModel: Product not found: ${response?.message}');
        _productCache.remove(barcode);
        final message = response?.message ?? 'Product not found.';
        String? productName;
        ScanProduct? product;
        if (message.toLowerCase().contains('out of stock') &&
            response?.data?.product != null) {
          product = response!.data!.product!;
          productName = product.name != 'Unknown Product' ? product.name : null;
          if (productName == null) {
            final match =
                RegExp(r'Product (.*?) is out of stock').firstMatch(message);
            productName = match?.group(1);
          }
        } else if (message.contains('Store not found')) {
          return {
            'success': false,
            'message': 'Store not found or you do not have permission.',
            'product': null,
            'name': null,
          };
        } else {
          final match =
              RegExp(r'Product (.*?) is out of stock').firstMatch(message);
          productName = match?.group(1);
        }
        return {
          'success': false,
          'message': message,
          'product': product,
          'name': productName,
        };
      }
    } catch (e, stackTrace) {
      print('SaleViewModel: Error adding product to cart: $e\n$stackTrace');
      _productCache.remove(barcode);
      return {
        'success': false,
        'message': 'Error scanning product: $e',
        'product': null,
        'name': null,
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
            "SaleViewModel: Updated cart item: ${product.name}, Quantity: ${currentCart[existingIndex].quantity}, Subtotal: ${currentCart[existingIndex].subtotal}");
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
          "SaleViewModel: Added new cart item: ${newItem.name}, Quantity: ${newItem.quantity}, Subtotal: ${newItem.subtotal}");
    }

    cartItems.value = currentCart;
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      notifyListeners();
      print(
          "SaleViewModel: Current cart state: ${cartItems.value.map((item) => 'Name: ${item.name}, Code: ${item.code}, Qty: ${item.quantity}, Subtotal: ${item.subtotal}').join('; ')}");
    });
  }

  void removeItemFromReview(Cart item) {
    final currentCart = List<Cart>.from(cartItems.value);
    currentCart.removeWhere((cartItem) => cartItem.code == item.code);
    cartItems.value = currentCart;
    print("SaleViewModel: Removed cart item: ${item.name}, Code: ${item.code}");
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
            "SaleViewModel: Updated quantity for ${currentCart[index].name}: New Qty: $newQuantity, Subtotal: ${currentCart[index].subtotal}");
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
      'discount': discount.value,
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
    print(
        "SaleViewModel: Calculated total price: $total, Discount: $discount%, Tax: $tax%");
    return total;
  }

  Future<String?> processCheckout(List<Cart> cartItems,
      {String? deliveryAddress}) async {
    final storeId = await customerService.getActiveStoreId();
    if (storeId == null) {
      print('SaleViewModel: Checkout failed: Store ID is missing');
      showCustomToast('Store ID is missing.', success: false);
      return "Store ID is missing.";
    }

    if (cartItems.isEmpty) {
      print('SaleViewModel: Checkout failed: Cart is empty');
      showCustomToast('Cart is empty. Please scan a product.', success: false);
      return "Cart is empty.";
    }

    if (paymentMethod.isEmpty) {
      print('SaleViewModel: Checkout failed: Payment method not selected');
      showCustomToast('Please select a payment method.', success: false);
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

      final checkoutDeliveryAddress = deliveryAddress?.trim().isNotEmpty == true
          ? deliveryAddress!.trim()
          : null;

      print('SaleViewModel: Initiating checkout with:');
      print('Cart: $formattedCartItems');
      print('Store ID: $storeId');
      print('Discount: ${discount.value}');
      print('Tax: $tax');
      print('Payment Method: $paymentMethod');
      print('Delivery Address: ${checkoutDeliveryAddress ?? 'Not provided'}');

      final response = await salesRepository.checkout(
        cartItems: formattedCartItems,
        discount: discount.value,
        tax: tax,
        paymentMethod: paymentMethod,
        storeId: storeId,
        deliveryAddress: checkoutDeliveryAddress,
      );

      print('SaleViewModel: Checkout response:');
      print('Success: ${response?.success}');
      print('Message: ${response?.message}');
      print('Data: ${response?.data?.toJson()}');
      print('EmailWarning: ${response?.emailWarning}');

      if (response?.success == true) {
        this.cartItems.value = [];
        _productCache.clear();
        scannedBarcodes.clear();
        paymentMethod = 'CASH';
        temporaryDeliveryAddress = null;
        discount.value = 0.0;
        notifyListeners();
        print(
            'SaleViewModel: Checkout successful, cart and scanned barcodes cleared');
        showCustomToast(
            'Checkout completed successfully! Invoice sent to your email.',
            success: true);
        if (response?.emailWarning != null) {
          showCustomToast(response!.emailWarning!, success: false);
        }
        return null;
      } else {
        final errorMessage = response?.message ?? 'Checkout failed.';
        print('SaleViewModel: Checkout failed: $errorMessage');
        showCustomToast(errorMessage, success: false);
        return errorMessage;
      }
    } catch (e, stackTrace) {
      print('SaleViewModel: Checkout error: $e\n$stackTrace');
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
              temporaryDeliveryAddress = null;
              discount.value = 0.0;
              print("SaleViewModel: Cart cleared");
              notifyListeners();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void addProductDirectly(Product product) {
    if (product.quantity == null || product.quantity! <= 0) {
      showCustomToast('Product ${product.name ?? 'Unknown'} is out of stock.', success: false);
      return;
    }
    final scanProduct = ScanProduct(
      id: product.id ?? '',
      name: product.name ?? 'Unknown Product',
      code: product.code ?? '',
      price: product.price ?? 0.0,
      quantity: product.quantity ?? 0,
      size: product.size ?? '',
      categoryId: product.category ?? '',
      availableQuantity: product.quantity ?? 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      v: 0,
      description: product.description,
      brands: product.brands,
      expiryDate: product.expiryDate != null ? DateTime.tryParse(product.expiryDate!) : null,
      costPrice: product.costPrice,
      store: product.storeId,
      owner: product.owner,
      stock: product.quantity ?? 0,
      imageUrl: product.imageUrl,
      minQuantity: product.minQuantity ?? 1,
    );
    _addOrUpdateCartItem(scanProduct);
    showCustomToast('Added ${product.name} to cart', success: true);
  }

  @override
  void dispose() {
    print('SaleViewModel: Disposing instance ${hashCode}');
    _debounceTimer?.cancel();
    discount.dispose();
    super.dispose();
  }
}
