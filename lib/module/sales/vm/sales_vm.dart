// import 'package:etegram_business/base/base_vm.dart';
// import 'package:etegram_business/core/model/get_search_response.dart';
// import 'package:etegram_business/repository/product_repository.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import '../../../app_widget/barcode_scanner_view.dart';
// import '../../../constants/assets.dart';
// import '../../../core/model/cart_item.dart';
// import '../../../core/model/get_scan_response.dart';
// import '../../../core/model/product_model.dart';
// import 'package:flutter/material.dart';
//
// import '../../../locator.dart';
// import '../../../service/local/user_service.dart';
// import '../../../utils/snack_message.dart';
// import '../../product/view/add_product.dart';
//
// class SaleViewModel extends BaseViewModel {
//   ProductData? selectedProduct;
//   GetScanResponse? addProductResponse;
//   SearchProductResponse? searchProductResponse;
//   List<ProductData> search = [];
//   List<Cart> cartItems = [];
//   List<Cart> cart = [];
//   double totalAmount = 0.0;
//
//   double discount = 0.0;
//   double tax = 0.0;
//   String paymentMethod = 'Cash';
//   int quantity = 1;
//   double costPrice = 0.0;
//   double unitPrice = 0.0;
//   int minQuantity = 1;
//   final _customerService = locator<CustomerService>();
//
//   /// ✅ Update quantity values dynamically
//   void updateQuantity(int change) {
//     quantity = (quantity + change).clamp(1, 9999);
//     notifyListeners();
//   }
//
//   void updateCostPrice(int change) {
//     costPrice = (costPrice + change).clamp(0, 999999);
//     notifyListeners();
//   }
//
//   void updateUnitPrice(int change) {
//     unitPrice = (unitPrice + change).clamp(0, 999999);
//     notifyListeners();
//   }
//
//   void updateMinQuantity(int change) {
//     minQuantity = (minQuantity + change).clamp(1, quantity);
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
//     paymentMethod = method;
//     notifyListeners();
//   }
//
//   /// 📦 Scan and add product
//   Future<void> scanAndAddProduct(int code) async {
//     try {
//       startLoader();
//       final ownerId = await _customerService.getOwnerId();
//       final storeId = await _customerService.getStoreId();
//
//       if (ownerId == null || storeId == null) {
//         showCustomToast('Missing owner or store ID.');
//         return;
//       }
//       GetScanResponse? response =
//           await salesRepository.getScanProduct(code: code, ownerId: ownerId, storeId: storeId);
//
//       if (response?.success == true && response?.data?.product != null) {
//         ScanProduct product = response!.data!.product!;
//
//         // Check if product is already in cart
//         int index = cart.indexWhere((item) => item.code == product.code);
//         if (index != -1) {
//           cart[index].quantity += 1;
//           cart[index].subtotal = cart[index].quantity * cart[index].price;
//         } else {
//           cart.add(Cart(
//             id: product.id!,
//             name: product.name!,
//             price: product.price!,
//             code: product.code!,
//             quantity: 1,
//             subtotal: product.price!,
//           ));
//         }
//
//         _calculateTotal();
//         notifyListeners();
//       }
//     } catch (e) {
//       print("Error in scanAndAddProduct: $e");
//     } finally {
//       stopLoader();
//     }
//   }
//
//   /// 🔄 Calculate total amount
//   void _calculateTotal() {
//     totalAmount = cart.fold(0.0, (sum, item) => sum + item.subtotal);
//   }
//
//  }
