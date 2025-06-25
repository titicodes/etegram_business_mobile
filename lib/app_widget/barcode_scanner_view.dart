//
// import 'package:etegram_business/app_widget/safe_mobile_scanner_view.dart';
// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:lottie/lottie.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/module/product/view/add_product.dart';
// import 'package:etegram_business/module/sales/view/scan_to_checkout.dart';
// import 'package:etegram_business/module/sales/vm/new_sales_vm.dart';
// import 'package:etegram_business/service/local/user_service.dart';
// import 'package:etegram_business/utils/snack_message.dart';
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/routes/routes.dart';
// import 'package:etegram_business/app_widget/scanner_control_bar.dart';
// import 'package:etegram_business/utils/widget_extension.dart';
//
// import '../constants/reuseable.dart';
//
//
// class CheckoutScannerView extends StatefulWidget {
//   const CheckoutScannerView({super.key});
//
//   @override
//   State<CheckoutScannerView> createState() => _CheckoutScannerViewState();
// }
//
// class _CheckoutScannerViewState extends State<CheckoutScannerView> {
//   final Set<String> _scannedBarcodes = {};
//   final CustomerService _customerService = locator<CustomerService>();
//   bool _isProcessing = false;
//
//   void _onBarcodeDetected(BarcodeCapture capture) async {
//     if (_isProcessing || capture.barcodes.isEmpty) return;
//
//     final barcodeValue = capture.barcodes.first.rawValue;
//     if (barcodeValue == null || barcodeValue.isEmpty || _scannedBarcodes.contains(barcodeValue)) return;
//
//     _scannedBarcodes.add(barcodeValue);
//     setState(() => _isProcessing = true);
//
//     try {
//       await _handleScan(barcodeValue);
//     } catch (e) {
//       print('Barcode processing error: $e');
//       showCustomToast('Error processing barcode: $e');
//     } finally {
//       if (mounted) setState(() => _isProcessing = false);
//     }
//   }
//
//   Future<void> _handleScan(String barcode) async {
//     final model = locator<SaleViewModel>();
//     final activeStoreId = await _customerService.getActiveStoreId();
//     if (activeStoreId == null) {
//       showCustomToast('No active store selected.');
//       return;
//     }
//
//     final exists = await model.checkIfProductExists(barcode, context, activeStoreId: activeStoreId);
//     if (exists) {
//       await showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => Dialog(
//           backgroundColor: Colors.transparent,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Lottie.asset(
//                 'assets/animations/success.json',
//                 height: 100,
//                 repeat: false,
//               ),
//               10.0.sbH,
//               const Text(
//                 'Product Scanned!',
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ],
//           ),
//         ),
//       ).timeout(const Duration(seconds: 1), onTimeout: () => Navigator.pop(context));
//     } else {
//       await _showProductNotFoundDialog(barcode);
//     }
//   }
//
//   Future<void> _showProductNotFoundDialog(String barcode) async {
//     final ownerId = await _customerService.getOwnerId();
//     final storeId = await _customerService.getActiveStoreId();
//     if (!mounted) return;
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Product Not Found'),
//         content: Text('Product with barcode "$barcode" not found.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _scannedBarcodes.remove(barcode);
//             },
//             child: const Text('Scan Another'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               navigationService.navigateToWidget(
//                 AddProductView(
//                   scannedCode: barcode,
//                   isEditing: false,
//                   ownerId: ownerId,
//                   storeId: storeId,
//                 ),
//               );
//             },
//             child: const Text('Add Product'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               navigationService.navigateTo(mainNavViewRoute);
//             },
//             child: const Text('Go to Home'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final model = locator<SaleViewModel>();
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan Products'),
//         actions: [
//           IconButton(
//             icon: Icon(
//               Icons.shopping_cart,
//               color: model.cartItems.isEmpty ? Colors.grey : ColorValues.primaryColor,
//             ),
//             onPressed: model.cartItems.isEmpty
//                 ? null
//                 : () => navigationService.navigateToWidget(
//               const ScanToCheckoutView(),
//               transitionBuilder: (context, animation, secondaryAnimation, child) {
//                 return SlideTransition(
//                   position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
//                   child: child,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           SafeMobileScannerView(
//             onDetect: _onBarcodeDetected,
//             overlay: Column(
//               children: const [
//                 Spacer(),
//                 // This requires scannerController if it interacts with flash/zoom
//                 // You may omit if unnecessary.
//                 // ScannerControlBar(scannerController: _controller),
//               ],
//             ),
//           ),
//           if (_isProcessing)
//             Container(
//               color: Colors.black54,
//               child: Center(
//                 child: Lottie.asset(
//                   'assets/animations/scanning.json',
//                   width: 150,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// import 'package:dio/dio.dart';
// import 'package:etegram_business/base/base_vm.dart';
// import 'package:etegram_business/repository/sales_repository.dart';
// import 'package:etegram_business/app_widget/barcode_scanner_view.dart';
// import 'package:etegram_business/core/model/cart_item.dart';
// import 'package:etegram_business/core/model/checkout_response.dart';
// import 'package:etegram_business/core/model/get_scan_response.dart';
// import 'package:flutter/material.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/service/local/user_service.dart';
// import 'package:etegram_business/utils/snack_message.dart';
//
// class SaleViewModel extends BaseViewModel {
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   late BuildContext context;
//   List<ScanProduct> reviewItems = [];
//   List<Cart> cartItems = [];
//   double discount = 5.0;
//   double tax = 0.0;
//   String? paymentMethod;
//   final _customerService = locator<CustomerService>();
//   final Map<String, ScanProduct> _productCache = {};
//
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
//   void updateTax(double value) {
//     tax = value;
//     notifyListeners();
//   }
//
//   void updatePaymentMethod(String method) {
//     paymentMethod = method == 'POS' ? 'CARD' : method.toUpperCase();
//     notifyListeners();
//   }
//
//   Future<void> scanAndAddToReview(String code, BuildContext context) async {
//     try {
//       startLoader();
//       final ownerId = await _customerService.getOwnerId();
//       final storeId = await _customerService.getActiveStoreId();
//
//       if (ownerId == null || storeId == null) {
//         showCustomToast('Missing owner or store ID.');
//         return;
//       }
//
//       if (_productCache.containsKey(code)) {
//         _addOrUpdateCartItem(_productCache[code]!);
//         notifyListeners();
//         return;
//       }
//
//       print('Making API call for barcode: $code');
//       final response = await salesRepository.getScanProduct(
//         code: code,
//         ownerId: ownerId,
//         storeId: storeId,
//       );
//
//       print('API response success: ${response?.success}');
//       print('API response message: ${response?.message}');
//       print('API response data: ${response?.data?.toJson()}');
//
//       if (response?.success == true && response?.data?.product != null) {
//         final product = response!.data!.product!;
//         _productCache[code] = product;
//         _addOrUpdateCartItem(product);
//         notifyListeners();
//       } else {
//         showCustomToast(response?.message ?? 'Product not found.');
//       }
//     } catch (e) {
//       print("Error in scanAndAddToReview: $e");
//       showCustomToast('Error scanning product.');
//     } finally {
//       stopLoader();
//     }
//   }
//
//   Future<bool> checkIfProductExists(String barcode, BuildContext context, {String? activeStoreId}) async {
//     try {
//       startLoader();
//       final barcodeStr = barcode.trim();
//       final ownerId = await _customerService.getOwnerId();
//       final storeId = activeStoreId ?? await _customerService.getActiveStoreId();
//
//       if (ownerId == null || storeId == null) {
//         showCustomToast('Missing owner or store ID.');
//         return false;
//       }
//
//       print('Checking barcode: $barcodeStr, Owner ID: $ownerId, Store ID: $storeId');
//
//       if (_productCache.containsKey(barcodeStr)) {
//         _addOrUpdateCartItem(_productCache[barcodeStr]!);
//         notifyListeners();
//         return true;
//       }
//
//       final response = await salesRepository.getScanProduct(
//         code: barcodeStr,
//         ownerId: ownerId,
//         storeId: storeId,
//       );
//
//       if (response?.success != true || response?.data?.product == null) {
//         showCustomToast(response?.message ?? 'Product not found.');
//         return false;
//       }
//
//       final product = response!.data!.product!;
//       if (product.id == null || product.name == null || product.price == null || product.code == null) {
//         showCustomToast('Product data is incomplete.');
//         return false;
//       }
//
//       final stock = product.stock ?? 0;
//       if (stock <= 0) {
//         showCustomToast('Product is out of stock.');
//         return false;
//       }
//
//       _productCache[barcodeStr] = product;
//       _addOrUpdateCartItem(product);
//       notifyListeners();
//       return true;
//     } catch (e, stackTrace) {
//       print("Error in checkIfProductExists: $e\n$stackTrace");
//       showCustomToast('Error checking product.');
//       return false;
//     } finally {
//       stopLoader();
//     }
//   }
//
//   void _addOrUpdateCartItem(ScanProduct product) {
//     final existingIndex = cartItems.indexWhere((item) => item.code == product.code);
//     if (existingIndex != -1) {
//       if (cartItems[existingIndex].quantity + 1 <= (product.stock ?? 0)) {
//         cartItems[existingIndex].quantity += 1;
//         cartItems[existingIndex].subtotal = cartItems[existingIndex].quantity * product.price!;
//         print("Updated quantity for ${product.name}");
//       } else {
//         showCustomToast('Maximum stock reached for ${product.name}.');
//       }
//     } else {
//       cartItems.add(Cart(
//         id: product.id!,
//         name: product.name!,
//         price: product.price!,
//         code: product.code!,
//         quantity: 1,
//         subtotal: product.price!,
//         availableQuantity: product.stock ?? 0,
//       ));
//       print("Added ${product.name} to cart");
//     }
//     for (var item in cartItems) {
//       print('Cart → ${item.name}, Qty: ${item.quantity}, Subtotal: ${item.subtotal}, Available: ${item.availableQuantity}');
//     }
//   }
//
//   void removeItemFromReview(Cart item) {
//     cartItems.remove(item);
//     notifyListeners();
//   }
//
//   void updateItemQuantityInReview(Cart cartItem, int newQuantity) {
//     final index = cartItems.indexWhere((item) => item.code == cartItem.code);
//     if (index != -1) {
//       if (newQuantity <= cartItems[index].availableQuantity) {
//         cartItems[index].quantity = newQuantity;
//         cartItems[index].subtotal = newQuantity * cartItems[index].price;
//         notifyListeners();
//       } else {
//         showCustomToast('Maximum stock reached for ${cartItem.name}.');
//       }
//     }
//   }
//
//   double calculateTotalPrice() {
//     double total = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
//     total -= total * (discount / 100);
//     total += total * (tax / 100);
//     return total;
//   }
//
//   Future<String?> processCheckout(List<Cart> cartItems) async {
//     final storeId = await _customerService.getActiveStoreId();
//     if (storeId == null) return "Store ID is missing.";
//
//     updateLoading(true);
//     try {
//       final formattedCartItems = cartItems.map((item) => {
//         'code': item.code,
//         'quantity': item.quantity,
//       }).toList();
//
//       final response = await salesRepository.checkout(
//         cartItems: formattedCartItems,
//         discount: discount,
//         tax: tax,
//         paymentMethod: paymentMethod ?? 'CASH',
//         storeId: storeId,
//       );
//
//       if (response?.success == true) {
//         this.cartItems.clear();
//         _productCache.clear();
//         paymentMethod = null;
//         notifyListeners();
//         return null;
//       } else {
//         return response?.message ?? "Checkout failed.";
//       }
//     } catch (e) {
//       print('Checkout error: $e');
//       return "Error processing checkout: $e";
//     } finally {
//       updateLoading(false);
//     }
//   }
//
//   void clearCart(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text("Clear Cart?"),
//         content: Text("Are you sure you want to remove all items from the cart?"),
//         actions: [
//           TextButton(
//             child: Text("Cancel"),
//             onPressed: () => Navigator.of(ctx).pop(),
//           ),
//           TextButton(
//             child: Text("Clear All"),
//             onPressed: () {
//               cartItems.clear();
//               _productCache.clear();
//               notifyListeners();
//               Navigator.of(ctx).pop();
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _handleDioError(DioException e) {
//     String errorMessage = 'Error processing request.';
//     if (e.response != null && e.response!.data is Map<String, dynamic>) {
//       errorMessage = e.response!.data['message'] ?? 'API Error: ${e.response!.statusCode}';
//     } else if (e.type == DioExceptionType.connectionTimeout) {
//       errorMessage = 'Connection timeout. Please check your internet connection.';
//     } else if (e.type == DioExceptionType.receiveTimeout) {
//       errorMessage = 'Server is taking too long to respond. Please try again later.';
//     } else {
//       errorMessage = 'Network error: ${e.message}';
//     }
//     print("DioException: $errorMessage");
//     showCustomToast(errorMessage);
//   }
//
//   @override
//   void dispose() {
//     //super.dispose();
//     // Prevent disposal for singleton instance
//     print('SaleViewModel dispose called, but skipped for singleton');
//     // Do not call super.dispose() to keep the singleton alive
//   }
// }

import 'package:etegram_business/app_widget/safe_mobile_scanner_view.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lottie/lottie.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/product/view/add_product.dart';
import 'package:etegram_business/module/sales/view/scan_to_checkout.dart';
import 'package:etegram_business/module/sales/vm/new_sales_vm.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/app_widget/scanner_control_bar.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import '../../../constants/reuseable.dart';

class CheckoutScannerView extends StatefulWidget {
  const CheckoutScannerView({super.key});

  @override
  State<CheckoutScannerView> createState() => _CheckoutScannerViewState();
}

class _CheckoutScannerViewState extends State<CheckoutScannerView> {
  final Set<String> _scannedBarcodes = {};
  final CustomerService _customerService = locator<CustomerService>();
  bool _isProcessing = false;

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing || capture.barcodes.isEmpty) return;

    final barcodeValue = capture.barcodes.first.rawValue;
    if (barcodeValue == null ||
        barcodeValue.isEmpty ||
        _scannedBarcodes.contains(barcodeValue)) return;

    _scannedBarcodes.add(barcodeValue);
    setState(() => _isProcessing = true);

    try {
      await _handleScan(barcodeValue);
    } catch (e, stackTrace) {
      print('Barcode processing error: $e\n$stackTrace');
      showCustomToast('Error processing barcode: $e');
    } finally {
      if (mounted) {
        _scannedBarcodes.remove(barcodeValue);
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleScan(String barcode) async {
    final model = locator<SaleViewModel>();
    final activeStoreId = await _customerService.getActiveStoreId();
    if (activeStoreId == null) {
      showCustomToast('No active store selected.');
      return;
    }

    print('Handling scan for barcode: $barcode, storeId: $activeStoreId');
    final exists = await model.checkIfProductExists(barcode, context,
        activeStoreId: activeStoreId);
    if (exists) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/success.json',
                height: 100,
                repeat: false,
              ),
              10.0.sbH,
              const Text(
                'Product Scanned!',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ).timeout(const Duration(seconds: 1),
          onTimeout: () => Navigator.pop(context));
      if (!mounted) return;
      navigationService.navigateToWidget(
        const ScanToCheckoutView(),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(animation),
            child: child,
          );
        },
      );
    } else {
      await _showProductNotFoundDialog(barcode);
    }
  }

  Future<void> _showProductNotFoundDialog(String barcode) async {
    final ownerId = await _customerService.getOwnerId();
    final storeId = await _customerService.getActiveStoreId();
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Not Found'),
        content: Text(
            'Product with barcode "$barcode" not found in store. Would you like to add it?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Scan Another'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (ownerId != null && storeId != null) {
                navigationService.navigateToWidget(
                  AddProductView(
                    scannedCode: barcode,
                    isEditing: false,
                    ownerId: ownerId,
                    storeId: storeId,
                  ),
                  transitionBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(1, 0), end: Offset.zero)
                          .animate(animation),
                      child: child,
                    );
                  },
                );
              } else {
                showCustomToast('Missing owner or store ID.');
              }
            },
            child: const Text('Add Product'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              navigationService.navigateTo(mainNavViewRoute);
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = locator<SaleViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Products'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: model.cartItems.isEmpty
                  ? Colors.grey
                  : ColorValues.primaryColor,
            ),
            onPressed: model.cartItems.isEmpty
                ? null
                : () => navigationService.navigateToWidget(
                      const ScanToCheckoutView(),
                      transitionBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                                  begin: const Offset(1, 0), end: Offset.zero)
                              .animate(animation),
                          child: child,
                        );
                      },
                    ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeMobileScannerView(
            onDetect: _onBarcodeDetected,
            overlayBuilder: (MobileScannerController controller) => Column(
              children: [
                const Spacer(),
                ScannerControlBar(
                  scannerController: controller,
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Lottie.asset(
                  'assets/animations/scan.json',
                  width: 150,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
