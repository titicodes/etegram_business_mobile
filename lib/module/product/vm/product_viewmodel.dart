// import 'dart:async';
// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:etegram_business/routes/routes.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:etegram_business/app_widget/celebration_widget.dart';
// import '../../../base/base_vm.dart';
// import '../../../constants/assets.dart';
// import '../../../constants/colors.dart';
// import '../../../core/model/product_history_model.dart';
// import '../../../core/model/product_model.dart';
// import '../../../utils/snack_message.dart';
//
// class ProductViewModel extends BaseViewModel {
//   int currentIndex = 0;
//
//   // Form key
//   final formKey = GlobalKey<FormState>();
//
//   // Form controllers
//   final nameController = TextEditingController();
//   final codeController = TextEditingController();
//   final categoryController = TextEditingController();
//   final priceController = TextEditingController();
//   final costPriceController = TextEditingController();
//   final quantityController = TextEditingController();
//   final minQuantityController = TextEditingController();
//   final expiryDateController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final sizeController = TextEditingController();
//   final brandsController = TextEditingController();
//   final totalValueController = TextEditingController();
//   final searchController = TextEditingController();
//   final ValueNotifier<bool> isFetchingExternalData = ValueNotifier<bool>(false);
//   final errorMessage = ValueNotifier<String?>(null);
//   List<ProductHistory> productHistory = [];
//   int totalHistoryItems = 0;
//
//   ProductViewModel() {
//     priceController.addListener(updateTotals);
//     quantityController.addListener(updateTotals);
//     costPriceController.addListener(updateTotals);
//     minQuantityController.addListener(updateTotals);
//   }
//
//   bool _isValidObjectId(String? id) {
//     if (id == null || id.isEmpty) return false;
//     final regex = RegExp(r'^[0-9a-fA-F]{24}$');
//     return regex.hasMatch(id);
//   }
//
//   // Product lists
//   ValueListenable<List<Product>> get allProducts => _allProducts;
//   final _allProducts = ValueNotifier<List<Product>>([]);
//   ValueListenable<List<Product>> get expiringProducts => _expiringProducts;
//   final _expiringProducts = ValueNotifier<List<Product>>([]);
//   ValueListenable<List<Product>> get lowStockProducts => _lowStockProducts;
//   final _lowStockProducts = ValueNotifier<List<Product>>([]);
//   // ValueListenable<List<ProductHistory>> get productHistory => _productHistory;
//   final _productHistory = ValueNotifier<List<ProductHistory>>([]);
//
//   // Inventory summary
//   ValueListenable<double> get totalCost => _totalCost;
//   final _totalCost = ValueNotifier<double>(0.0);
//   ValueListenable<double> get totalSellingPrice => _totalSellingPrice;
//   final _totalSellingPrice = ValueNotifier<double>(0.0);
//   ValueListenable<int> get totalStock => _totalStock;
//   final _totalStock = ValueNotifier<int>(0);
//
//   // UI state
//   String? productImageUrl;
//   ValueListenable<bool> get isLoadingExpiring => _isLoadingExpiring;
//   final _isLoadingExpiring = ValueNotifier<bool>(false);
//   ValueListenable<bool> get isLoadingLowStock => _isLoadingLowStock;
//   final _isLoadingLowStock = ValueNotifier<bool>(false);
//   final _productTabIndex = ValueNotifier<int>(0);
//   Timer? _debounce;
//   final ValueNotifier<int> productTabIndex = ValueNotifier(0);
//   ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
//
//   void init() {
//     initialize();
//   }
//
//   final ValueNotifier<int> tabIndex = ValueNotifier(0);
//
//   List<DataTab> get tabOptions => [
//         DataTab(title: "Sent"),
//         DataTab(title: "Received"),
//       ];
//   //List<String> get productTabOptions => ['All Product', 'Expiring', 'Low Stock'];
//   List<DataTab> get productTabOptions => [
//         DataTab(title: "All Product"),
//         DataTab(title: "Expiring"),
//         DataTab(title: "Low Stock"),
//       ];
//
//   Future<void> initialize() async {
//     final storeId = customerService.activeStoreId;
//     if (storeId == null) {
//       errorMessage.value = 'No active store selected.';
//       showCustomToast('No active store selected.');
//       return;
//     }
//     errorMessage.value = null;
//     await Future.wait([
//       fetchAllProducts(storeId),
//       fetchExpiringProducts(storeId),
//       fetchLowStockProducts(storeId),
//       fetchInventorySummary(storeId),
//       fetchTotalStock(storeId),
//     ]);
//   }
//
//   void populateControllers(Product product) {
//     nameController.text = product.name ?? '';
//     codeController.text = product.code ?? '';
//     categoryController.text = product.category ?? '';
//     costPriceController.text = product.costPrice?.toStringAsFixed(2) ?? '0.00';
//     priceController.text = product.price?.toStringAsFixed(2) ?? '0.00';
//     quantityController.text = product.quantity?.toString() ?? '1';
//     minQuantityController.text = product.minQuantity?.toString() ?? '1';
//     expiryDateController.text = product.expiryDate ?? '';
//     descriptionController.text = product.description ?? '';
//     sizeController.text = product.size ?? '';
//     brandsController.text = product.brands ?? '';
//     productImageUrl = product.imageUrl;
//     updateTotals();
//     notifyListeners();
//   }
//
//   Future<void> fetchAllProducts(String storeId,
//       {String? search, String? category}) async {
//     startLoader();
//     errorMessage.value = null;
//     try {
//       if (category != null && !_isValidObjectId(category)) {
//         print('Invalid category ID: $category, omitting category filter');
//         category = null;
//       }
//
//       print(
//           'Fetching all products: storeId=$storeId, search=$search, category=$category');
//       final totalStockResponse =
//           await productRepository.getTotalStockWithProducts(storeId);
//       final products = totalStockResponse['products'] as List<dynamic>;
//       print('Fetched ${products.length} products from total stock: $products');
//       _allProducts.value =
//           products.map((json) => Product.fromJson(json)).toList();
//       if (_allProducts.value.isEmpty && (search == null || search.isEmpty)) {
//         errorMessage.value = 'No products found for this store.';
//       }
//     } catch (e) {
//       print('Error fetching all products: $e');
//       errorMessage.value = 'Failed to fetch products: $e';
//       showCustomToast('Failed to fetch products.');
//       _allProducts.value = [];
//     } finally {
//       stopLoader();
//     }
//   }
//
//   Future<void> fetchExpiringProducts(String storeId) async {
//     _isLoadingExpiring.value = true;
//     errorMessage.value = null;
//     try {
//       final products =
//           await productRepository.getExpiringProducts(storeId: storeId);
//       _expiringProducts.value = products;
//       if (products.isEmpty) {
//         errorMessage.value = 'No expiring products found.';
//       }
//     } catch (e) {
//       print('Error fetching expiring products: $e');
//       errorMessage.value = 'Failed to fetch expiring products: $e';
//       showCustomToast('Failed to fetch expiring products.');
//       _expiringProducts.value = [];
//     } finally {
//       _isLoadingExpiring.value = false;
//     }
//   }
//
//   Future<void> fetchLowStockProducts(String storeId) async {
//     _isLoadingLowStock.value = true;
//     errorMessage.value = null;
//     try {
//       final products =
//           await productRepository.getLowStockProducts(storeId: storeId);
//       _lowStockProducts.value = products;
//       if (products.isEmpty) {
//         errorMessage.value = 'No low stock products found.';
//       }
//     } catch (e) {
//       print('Error fetching low stock products: $e');
//       errorMessage.value = 'Failed to fetch low stock products: $e';
//       showCustomToast('Failed to fetch low stock products.');
//       _lowStockProducts.value = [];
//     } finally {
//       _isLoadingLowStock.value = false;
//     }
//   }
//
//   Future<void> fetchInventorySummary(String storeId) async {
//     try {
//       final summary = await productRepository.getInventorySummary(storeId);
//       if (summary != null) {
//         _totalCost.value = (summary['totalCost'] ?? 0).toDouble();
//         _totalSellingPrice.value =
//             (summary['totalSellingPrice'] ?? 0).toDouble();
//         _totalStock.value = (summary['totalQuantity'] ?? 0).toInt();
//       }
//     } catch (e) {
//       print('Error fetching inventory summary: $e');
//       errorMessage.value = 'Failed to fetch inventory summary: $e';
//       showCustomToast('Failed to fetch inventory summary.');
//     }
//   }
//
//   Future<void> fetchTotalStock(String storeId) async {
//     try {
//       final total = await productRepository.getTotalStockWithProducts(storeId);
//       _totalStock.value = (total['totalQuantity'] ?? 0).toInt();
//       final products = total['products'] as List<dynamic>;
//       if (_allProducts.value.isEmpty) {
//         _allProducts.value =
//             products.map((json) => Product.fromJson(json)).toList();
//       }
//     } catch (e) {
//       print('Error fetching total stock: $e');
//       errorMessage.value = 'Failed to fetch total stock: $e';
//       showCustomToast('Failed to fetch total stock.');
//     }
//   }
//
//   // Future<void> fetchProductHistory(String productId, String storeId) async {
//   //   startLoader();
//   //   try {
//   //     final history = await productRepository.getProductHistory(
//   //         productId: productId, storeId: storeId);
//   //     _productHistory.value = history;
//   //   } catch (e) {
//   //     print('Error fetching product history: $e');
//   //     showCustomToast('Failed to fetch product history.');
//   //   } finally {
//   //     stopLoader();
//   //   }
//   // }
//   Future<void> fetchProductHistory(String productId, String storeId, {int page = 1, int limit = 10}) async {
//     try {
//      startLoader();
//       isLoadingNotifier.value = true;
//       notifyListeners();
//
//       if (productId.isEmpty || storeId.isEmpty) {
//         print('Error: Invalid productId or storeId');
//         showCustomToast('Invalid product or store selected.');
//         return;
//       }
//       print('Fetching product history: productId=$productId, storeId=$storeId, page=$page, limit=$limit');
//       final history = await productRepository.getProductHistory(
//         productId: productId,
//         storeId: storeId,
//         page: page,
//         limit: limit,
//       );
//       productHistory = history;
//       totalHistoryItems = history.length;
//       print('Product history fetched: count=${productHistory.length}, total=$totalHistoryItems');
//
//       // Check for low stock and suggest action
//       if (history.isNotEmpty && history.any((h) => h.stock <= 5)) {
//         showCustomToast('Low stock detected! Consider restocking.');
//       }
//     } catch (e) {
//       print('Error fetching product history: $e');
//       showCustomToast('Failed to fetch product history: $e');
//     } finally {
//      stopLoader();
//       isLoadingNotifier.value = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchProductDetailsFromAPI(String barcode) async {
//     isFetchingExternalData.value = true;
//     notifyListeners();
//     print('Fetching product details for barcode: $barcode');
//
//     try {
//       final response = await http.get(Uri.parse(
//           'https://world.openfoodfacts.org/api/v0/product/$barcode.json'));
//       print('API response status: ${response.statusCode}');
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 1) {
//           final productData = data['product'];
//           nameController.text =
//               productData['product_name'] ?? productData['generic_name'] ?? '';
//           categoryController.text =
//               productData['categories'] ?? 'Uncategorized';
//           brandsController.text = productData['brands'] ?? '';
//           sizeController.text =
//               productData['quantity'] ?? productData['net_weight'] ?? '';
//           productImageUrl = productData['image_front_url'] ?? '';
//           codeController.text = barcode;
//           priceController.text = '0.00';
//           costPriceController.text = '0.00';
//           quantityController.text = '1';
//           minQuantityController.text = '5';
//           descriptionController.text = productData['ingredients_text'] ?? '';
//           updateTotals();
//           showCustomToast('Product details fetched successfully!');
//         } else {
//           clearControllers();
//           codeController.text = barcode;
//           showCustomToast('Product not found. Please enter details manually.');
//         }
//       } else {
//         clearControllers();
//         codeController.text = barcode;
//         showCustomToast('Failed to fetch product details.');
//       }
//     } catch (e) {
//       print('Error fetching product details: $e');
//       clearControllers();
//       codeController.text = barcode;
//       showCustomToast('Error fetching product details.');
//     } finally {
//       isFetchingExternalData.value = false;
//       notifyListeners();
//     }
//   }
//
//   Future<Product?> checkProductExistence(
//       String code, BuildContext context) async {
//     startLoader(message: 'Checking product...');
//     try {
//       final storeId = customerService.activeStoreId;
//       if (storeId == null) {
//         showCustomToast('No active store selected.');
//         return null;
//       }
//
//       print('Checking product existence: code=$code, storeId=$storeId');
//       final result =
//           await productRepository.checkProductExistence(code, storeId);
//       print('Check product response: $result');
//       if (result['success'] && result['exists'] && result['product'] != null) {
//         print('Product found: ${result['product'].toJson()}');
//         return result['product'] as Product;
//       }
//       print('No duplicate product found.');
//       return null;
//     } catch (e) {
//       print('Error checking product existence: $e');
//       showCustomToast('Error checking product: $e');
//       return null;
//     } finally {
//       stopLoader();
//       notifyListeners();
//     }
//   }
//
//   Future<void> showDuplicateDialog(BuildContext context, Product? product,
//       {bool fromSave = false}) async {
//     if (product == null) {
//       showCustomToast('Failed to fetch product details.');
//       return;
//     }
//     print(
//         'Showing duplicate dialog for product: ${product.name}, code: ${product.code}');
//     await showDialog(
//       context: context,
//       barrierDismissible: false, // Prevent dismissing dialog by tapping outside
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: Colors.white,
//         title: Row(
//           children: [
//             Icon(Icons.warning_rounded, color: Colors.orange, size: 28),
//             SizedBox(width: 8),
//             Text('Duplicate Product Found',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'The product "${product.name}" with barcode "${product.code}" is already in your store.',
//               style: TextStyle(fontSize: 16, color: Colors.grey[800]),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Would you like to edit the existing product or scan/add a different one?',
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               print('User chose to scan another product');
//               Navigator.pop(context);
//               if (fromSave) {
//                 clearControllers();
//                 navigationService.navigateTo(addProductScannerRoute);
//               }
//             },
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.grey[600],
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             ),
//             child: Text('Scan Another', style: TextStyle(fontSize: 16)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: ColorValues.primaryColor,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             ),
//             onPressed: () {
//               print('User chose to edit product: ${product.name}');
//               Navigator.pop(context);
//               navigationService.navigateTo(addProductViewRoute, arguments: {
//                 'isEditing': true,
//                 'product': product,
//                 'storeId': customerService.activeStoreId,
//                 'ownerId': customerService.getOwnerId(),
//               });
//             },
//             child: Text('Edit Product',
//                 style: TextStyle(fontSize: 16, color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> saveOrUpdateProduct({
//     required BuildContext context,
//     bool isEditing = false,
//     Product? existingProduct,
//     String? scannedCode,
//     required String ownerId,
//     required String storeId,
//   }) async {
//     if (!formKey.currentState!.validate()) {
//       showCustomToast('Please fill all required fields with valid values.');
//       return;
//     }
//
//     if (!_validateForm()) {
//       showCustomToast('Please ensure all numerical fields are valid.');
//       return;
//     }
//
//     final productCode = codeController.text.trim().isEmpty
//         ? scannedCode
//         : codeController.text.trim();
//     if (!isEditing && productCode != null && productCode.isNotEmpty) {
//       print('Checking for duplicate product with code: $productCode');
//       final duplicateProduct =
//           await checkProductExistence(productCode, context);
//       if (duplicateProduct != null) {
//         print('Duplicate product detected: ${duplicateProduct.name}');
//         stopLoader();
//         await showDuplicateDialog(context, duplicateProduct, fromSave: true);
//         return;
//       }
//     }
//
//     startLoader(
//         message: isEditing
//             ? 'Updating product...'
//             : 'Adding product to your store...');
//     try {
//       print(
//           'Saving product: name=${nameController.text}, code=$productCode, scannedCode=$scannedCode');
//
//       final productData = Product(
//         id: existingProduct?.id,
//         name: nameController.text.trim(),
//         code: productCode,
//         category: categoryController.text.trim().isEmpty
//             ? 'Uncategorized'
//             : categoryController.text.trim(),
//         price: double.tryParse(priceController.text)?.toInt() ?? 0,
//         costPrice: double.tryParse(costPriceController.text)?.toInt() ?? 0,
//         quantity: int.tryParse(quantityController.text) ?? 1,
//         minQuantity: int.tryParse(minQuantityController.text) ?? 1,
//         expiryDate: expiryDateController.text.trim().isEmpty
//             ? null
//             : expiryDateController.text.trim(),
//         description: descriptionController.text.trim().isEmpty
//             ? null
//             : descriptionController.text.trim(),
//         size: sizeController.text.trim().isEmpty
//             ? null
//             : sizeController.text.trim(),
//         brands: brandsController.text.trim().isEmpty
//             ? null
//             : brandsController.text.trim(),
//         store: storeId,
//         owner: ownerId,
//         imageUrl: productImageUrl,
//       );
//
//       if (isEditing && existingProduct != null) {
//         final updated = await productRepository.updateProduct(
//             existingProduct.id!, productData, storeId);
//         if (updated != null) {
//           _updateLists(updated);
//           await fetchTotalStock(storeId);
//           showCustomToast('Product updated successfully!');
//           navigationService.goBack();
//         } else {
//           showCustomToast('Failed to update product.');
//         }
//       } else {
//         final response = await productRepository.scanAndAddProduct(
//           data: productData,
//           scannedCode: productCode ?? '',
//           context: context,
//           storeId: storeId,
//           ownerId: ownerId,
//         );
//         print('Scan and add response: ${response?.data}');
//         if (response != null && response.success && response.data != null) {
//           _allProducts.value = [..._allProducts.value, response.data!];
//           await fetchTotalStock(storeId);
//           clearControllers();
//           navigationService.navigateToWidget(
//             CelebrationWidget(
//               title: 'Back to Dashboard',
//               onTap: () {
//                 navigationService.navigateTo(dashboardRoute);
//               },
//               child: Text(
//                 'Product "${productData.name}" Added Successfully!',
//                 style:
//                     const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             transitionBuilder: (context, animation, secondaryAnimation, child) {
//               return SlideTransition(
//                 position: Tween<Offset>(
//                   begin: const Offset(1.0, 0.0),
//                   end: Offset.zero,
//                 ).animate(animation),
//                 child: child,
//               );
//             },
//           );
//         } else {
//           showCustomToast(
//               'Failed to add product: ${response?.message ?? 'Unknown error'}');
//         }
//       }
//     } on DioException catch (e) {
//       print('DioError saving/updating product: ${e.response?.data}');
//       showCustomToast(
//           'Error: ${e.response?.data['message'] ?? 'Failed to process product'}');
//     } catch (e) {
//       print('Error saving/updating product: $e');
//       showCustomToast('Error processing product: $e');
//     } finally {
//       stopLoader();
//       notifyListeners();
//     }
//   }
//
//   Future<void> deleteProduct(BuildContext context, Product product) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Delete Product'),
//         content: Text(
//             'Are you sure you want to delete "${product.name}" from your store?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//             ),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed != true) return;
//
//     startLoader(message: 'Deleting product...');
//     try {
//       final storeId = customerService.activeStoreId!;
//       final deleted =
//           await productRepository.deleteProduct(product.id!, storeId);
//       if (deleted) {
//         _allProducts.value =
//             _allProducts.value.where((p) => p.id != product.id).toList();
//         _expiringProducts.value =
//             _expiringProducts.value.where((p) => p.id != product.id).toList();
//         _lowStockProducts.value =
//             _lowStockProducts.value.where((p) => p.id != product.id).toList();
//         await fetchTotalStock(storeId);
//         showCustomToast('Product deleted successfully.');
//       } else {
//         showCustomToast('Failed to delete product.');
//       }
//     } catch (e) {
//       print('Error deleting product: $e');
//       showCustomToast('Error deleting product: $e');
//     } finally {
//       stopLoader();
//       notifyListeners();
//     }
//   }
//
//   Future<void> supplyProduct(
//       BuildContext context, Product product, int additionalQuantity) async {
//     if (additionalQuantity <= 0) {
//       showCustomToast('Please enter a valid quantity.');
//       return;
//     }
//
//     startLoader(message: 'Restocking product...');
//     try {
//       final storeId = customerService.activeStoreId!;
//       final updated = await productRepository.supplyProduct(
//           product.id!, additionalQuantity, storeId);
//       if (updated != null) {
//         _updateLists(updated);
//         await fetchTotalStock(storeId);
//         showCustomToast('Product restocked successfully!');
//       } else {
//         showCustomToast('Failed to restock product.');
//       }
//     } catch (e) {
//       print('Error restocking product: $e');
//       showCustomToast('Error restocking product: $e');
//     } finally {
//       stopLoader();
//       notifyListeners();
//     }
//   }
//
//   void searchProduct(String query) {
//     if (_debounce?.isActive ?? false) {
//       _debounce?.cancel();
//     }
//     _debounce = Timer(const Duration(milliseconds: 500), () async {
//       final storeId = customerService.activeStoreId;
//       if (storeId == null) {
//         errorMessage.value = 'No active store selected.';
//         showCustomToast('No active store selected.');
//         return;
//       }
//       await fetchAllProducts(storeId,
//           search: query.trim().isEmpty ? null : query);
//     });
//   }
//
//   void _updateLists(Product updated) {
//     _allProducts.value = _allProducts.value
//         .map((p) => p.id == updated.id ? updated : p)
//         .toList();
//     if (_expiringProducts.value.any((p) => p.id == updated.id)) {
//       _expiringProducts.value = _expiringProducts.value
//           .map((p) => p.id == updated.id ? updated : p)
//           .toList();
//     }
//     if (_lowStockProducts.value.any((p) => p.id == updated.id)) {
//       _lowStockProducts.value = _lowStockProducts.value
//           .map((p) => p.id == updated.id ? updated : p)
//           .toList();
//     }
//   }
//
//   bool _validateForm() {
//     final price = double.tryParse(priceController.text);
//     final costPrice = double.tryParse(costPriceController.text);
//     final quantity = int.tryParse(quantityController.text);
//     final minQuantity = int.tryParse(minQuantityController.text);
//
//     return nameController.text.trim().isNotEmpty &&
//         categoryController.text.trim().isNotEmpty &&
//         price != null &&
//         price >= 0.0 &&
//         costPrice != null &&
//         costPrice >= 0.0 &&
//         quantity != null &&
//         quantity >= 1 &&
//         minQuantity != null &&
//         minQuantity >= 1;
//   }
//
//   void updateTotals() {
//     final price = double.tryParse(priceController.text) ?? 0.0;
//     final quantity = int.tryParse(quantityController.text) ?? 1;
//     final total = price * quantity;
//     totalValueController.text = total.toStringAsFixed(2);
//     notifyListeners();
//   }
//
//   String getTotalValue() {
//     return totalValueController.text.isEmpty
//         ? '0.00'
//         : totalValueController.text;
//   }
//
//   void clearControllers() {
//     nameController.clear();
//     codeController.clear();
//     categoryController.clear();
//     priceController.clear();
//     costPriceController.clear();
//     quantityController.clear();
//     minQuantityController.clear();
//     expiryDateController.clear();
//     descriptionController.clear();
//     sizeController.clear();
//     brandsController.clear();
//     totalValueController.clear();
//     productImageUrl = null;
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     nameController.dispose();
//     codeController.dispose();
//     categoryController.dispose();
//     priceController.dispose();
//     costPriceController.dispose();
//     quantityController.dispose();
//     minQuantityController.dispose();
//     expiryDateController.dispose();
//     descriptionController.dispose();
//     sizeController.dispose();
//     brandsController.dispose();
//     totalValueController.dispose();
//     searchController.dispose();
//     _allProducts.dispose();
//     _expiringProducts.dispose();
//     _lowStockProducts.dispose();
//     _productHistory.dispose();
//     _totalCost.dispose();
//     _totalSellingPrice.dispose();
//     _totalStock.dispose();
//     _isLoadingExpiring.dispose();
//     _isLoadingLowStock.dispose();
//     _productTabIndex.dispose();
//     isFetchingExternalData.dispose();
//     super.dispose();
//   }
//
//   final List<Color> containerColor = [
//     const Color(0xffFFF7E6),
//     const Color(0xffF0F0FF),
//     const Color(0xffFEEAFA),
//   ];
//
//   final List<String> productOperations = [
//     "Add Product",
//     "Product List",
//     "Move Products",
//   ];
//
//   final List<String> images = [
//     SvgAssets.addProduct,
//     SvgAssets.records,
//     SvgAssets.newSupplier,
//   ];
//
//   void changeContainer() {
//     currentIndex = (currentIndex + 1) % containerColor.length;
//     notifyListeners();
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:etegram_business/app_widget/celebration_widget.dart';
import '../../../base/base_vm.dart';
import '../../../constants/assets.dart';
import '../../../constants/colors.dart';
import '../../../core/model/product_history_model.dart';
import '../../../core/model/product_model.dart';
import '../../../utils/snack_message.dart';

class ProductViewModel extends BaseViewModel {
  int currentIndex = 0;

  // Form key
  final formKey = GlobalKey<FormState>();

  // Form controllers
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final costPriceController = TextEditingController();
  final quantityController = TextEditingController();
  final minQuantityController = TextEditingController();
  final expiryDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final sizeController = TextEditingController();
  final brandsController = TextEditingController();
  final totalValueController = TextEditingController();
  final searchController = TextEditingController();
  final ValueNotifier<bool> isFetchingExternalData = ValueNotifier<bool>(false);
  final errorMessage = ValueNotifier<String?>(null);

  ProductViewModel() {
    priceController.addListener(updateTotals);
    quantityController.addListener(updateTotals);
    costPriceController.addListener(updateTotals);
    minQuantityController.addListener(updateTotals);
    // Initialize default values
    priceController.text = '1.00'; // Ensure price > 0
    costPriceController.text = '0.00';
    quantityController.text = '1';
    minQuantityController.text = '1';
  }

  bool _isValidObjectId(String? id) {
    if (id == null || id.isEmpty) return false;
    final regex = RegExp(r'^[0-9a-fA-F]{24}$');
    return regex.hasMatch(id);
  }

  // Product lists
  ValueListenable<List<Product>> get allProducts => _allProducts;
  final _allProducts = ValueNotifier<List<Product>>([]);
  ValueListenable<List<Product>> get expiringProducts => _expiringProducts;
  final _expiringProducts = ValueNotifier<List<Product>>([]);
  ValueListenable<List<Product>> get lowStockProducts => _lowStockProducts;
  final _lowStockProducts = ValueNotifier<List<Product>>([]);
  ValueListenable<List<ProductHistory>> get productHistory => _productHistory;
  final _productHistory = ValueNotifier<List<ProductHistory>>([]);
  ValueListenable<bool> get isLoadingProductHistory => _isLoadingProductHistory;
  final _isLoadingProductHistory = ValueNotifier<bool>(false);

  // Inventory summary
  ValueListenable<double> get totalCost => _totalCost;
  final _totalCost = ValueNotifier<double>(0.0);
  ValueListenable<double> get totalSellingPrice => _totalSellingPrice;
  final _totalSellingPrice = ValueNotifier<double>(0.0);
  ValueListenable<int> get totalStock => _totalStock;
  final _totalStock = ValueNotifier<int>(0);

  // UI state
  String? productImageUrl;
  ValueListenable<bool> get isLoadingExpiring => _isLoadingExpiring;
  final _isLoadingExpiring = ValueNotifier<bool>(false);
  ValueListenable<bool> get isLoadingLowStock => _isLoadingLowStock;
  final _isLoadingLowStock = ValueNotifier<bool>(false);
  final _productTabIndex = ValueNotifier<int>(0);
  Timer? _debounce;
  final ValueNotifier<int> productTabIndex = ValueNotifier(0);

  void init() {
    initialize();
  }

  final ValueNotifier<int> tabIndex = ValueNotifier(0);

  List<DataTab> get tabOptions => [
        DataTab(title: "Sent"),
        DataTab(title: "Received"),
      ];

  List<DataTab> get productTabOptions => [
        DataTab(title: "All Product"),
        DataTab(title: "Expiring"),
        DataTab(title: "Low Stock"),
      ];

  Future<void> initialize() async {
    final storeId = customerService.activeStoreId;
    if (storeId == null) {
      errorMessage.value = 'No active store selected.';
      showCustomToast('No active store selected.');
      return;
    }
    errorMessage.value = null;
    await Future.wait([
      fetchAllProducts(storeId),
      fetchExpiringProducts(storeId),
      fetchLowStockProducts(storeId),
      fetchInventorySummary(storeId),
      fetchTotalStock(storeId),
    ]);
  }

  void populateControllers(Product product) {
    nameController.text = product.name ?? '';
    codeController.text = product.code ?? '';
    categoryController.text = product.category ?? '';
    costPriceController.text = product.costPrice?.toStringAsFixed(2) ?? '0.00';
    priceController.text = product.price?.toStringAsFixed(2) ?? '1.00';
    quantityController.text = product.quantity?.toString() ?? '1';
    minQuantityController.text = product.minQuantity?.toString() ?? '1';
    expiryDateController.text = product.expiryDate ?? '';
    descriptionController.text = product.description ?? '';
    sizeController.text = product.size ?? '';
    brandsController.text = product.brands ?? '';
    productImageUrl = product.imageUrl;
    updateTotals();
    notifyListeners();
  }

  Future<void> fetchAllProducts(String storeId,
      {String? search, String? category}) async {
    startLoader();
    errorMessage.value = null;
    try {
      if (category != null && !_isValidObjectId(category)) {
        print('Invalid category ID: $category, omitting category filter');
        category = null;
      }

      print(
          'Fetching all products: storeId=$storeId, search=$search, category=$category');
      final totalStockResponse =
          await productRepository.getTotalStockWithProducts(storeId);
      final products = totalStockResponse['products'] as List<dynamic>;
      print('Fetched ${products.length} products from total stock: $products');
      _allProducts.value =
          products.map((json) => Product.fromJson(json)).toList();
      if (_allProducts.value.isEmpty && (search == null || search.isEmpty)) {
        errorMessage.value = 'No products found for this store.';
      }
    } catch (e) {
      print('Error fetching all products: $e');
      errorMessage.value = 'Failed to fetch products: $e';
      showCustomToast('Failed to fetch products.');
      _allProducts.value = [];
    } finally {
      stopLoader();
    }
  }

  Future<void> fetchExpiringProducts(String storeId) async {
    _isLoadingExpiring.value = true;
    errorMessage.value = null;
    try {
      final products =
          await productRepository.getExpiringProducts(storeId: storeId);
      _expiringProducts.value = products;
      if (products.isEmpty) {
        errorMessage.value = 'No expiring products found.';
      }
    } catch (e) {
      print('Error fetching expiring products: $e');
      errorMessage.value = 'Failed to fetch expiring products: $e';
      showCustomToast('Failed to fetch expiring products.');
      _expiringProducts.value = [];
    } finally {
      _isLoadingExpiring.value = false;
    }
  }

  Future<void> fetchLowStockProducts(String storeId) async {
    _isLoadingLowStock.value = true;
    errorMessage.value = null;
    try {
      final products =
          await productRepository.getLowStockProducts(storeId: storeId);
      _lowStockProducts.value = products;
      if (products.isEmpty) {
        errorMessage.value = 'No low stock products found.';
      }
    } catch (e) {
      print('Error fetching low stock products: $e');
      errorMessage.value = 'Failed to fetch low stock products: $e';
      showCustomToast('Failed to fetch low stock products.');
      _lowStockProducts.value = [];
    } finally {
      _isLoadingLowStock.value = false;
    }
  }

  Future<void> fetchInventorySummary(String storeId) async {
    try {
      final summary = await productRepository.getInventorySummary(storeId);
      if (summary != null) {
        _totalCost.value = (summary['totalCost'] ?? 0).toDouble();
        _totalSellingPrice.value =
            (summary['totalSellingPrice'] ?? 0).toDouble();
        _totalStock.value = (summary['totalQuantity'] ?? 0).toInt();
      }
    } catch (e) {
      print('Error fetching inventory summary: $e');
      errorMessage.value = 'Failed to fetch inventory summary: $e';
      showCustomToast('Failed to fetch inventory summary.');
    }
  }

  Future<void> fetchTotalStock(String storeId) async {
    try {
      final total = await productRepository.getTotalStockWithProducts(storeId);
      _totalStock.value = (total['totalQuantity'] ?? 0).toInt();
      final products = total['products'] as List<dynamic>;
      if (_allProducts.value.isEmpty) {
        _allProducts.value =
            products.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching total stock: $e');
      errorMessage.value = 'Failed to fetch total stock: $e';
      showCustomToast('Failed to fetch total stock.');
    }
  }

  Future<void> fetchProductHistory(String productId, String storeId) async {
    _isLoadingProductHistory.value = true;
    try {
      final history = await productRepository.getProductHistory(
          productId: productId, storeId: storeId);
      _productHistory.value = history;
    } catch (e) {
      print('Error fetching product history: $e');
      showCustomToast('Failed to fetch product history.');
    } finally {
      _isLoadingProductHistory.value = false;
    }
  }

  Future<void> fetchProductDetailsFromAPI(String barcode) async {
    isFetchingExternalData.value = true;
    notifyListeners();
    print('Fetching product details for barcode: $barcode');

    try {
      final response = await http.get(Uri.parse(
          'https://world.openfoodfacts.org/api/v0/product/$barcode.json'));
      print('API response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          final productData = data['product'];
          nameController.text =
              productData['product_name'] ?? productData['generic_name'] ?? '';
          categoryController.text =
              productData['categories'] ?? 'Uncategorized';
          brandsController.text = productData['brands'] ?? '';
          sizeController.text =
              productData['quantity'] ?? productData['net_weight'] ?? '';
          productImageUrl = productData['image_front_url'] ?? '';
          codeController.text = barcode;
          priceController.text = '1.00'; // Ensure price > 0
          costPriceController.text = '0.00';
          quantityController.text = '1';
          minQuantityController.text = '5';
          descriptionController.text = productData['ingredients_text'] ?? '';
          updateTotals();
          showCustomToast('Product details fetched successfully!');
        } else {
          clearControllers();
          codeController.text = barcode;
          showCustomToast('Product not found. Please enter details manually.');
        }
      } else {
        clearControllers();
        codeController.text = barcode;
        showCustomToast('Failed to fetch product details.');
      }
    } catch (e) {
      print('Error fetching product details: $e');
      clearControllers();
      codeController.text = barcode;
      showCustomToast('Error fetching product details.');
    } finally {
      isFetchingExternalData.value = false;
      notifyListeners();
    }
  }

  Future<Product?> checkProductExistence(
      String code, BuildContext context) async {
    startLoader(message: 'Checking product...');
    try {
      final storeId = customerService.activeStoreId;
      if (storeId == null) {
        showCustomToast('No active store selected.');
        return null;
      }

      print('Checking product existence: code=$code, storeId=$storeId');
      final result =
          await productRepository.checkProductExistence(code, storeId);
      print('Check product response: $result');
      if (result['success'] && result['exists'] && result['product'] != null) {
        print('Product found: ${result['product'].toJson()}');
        return result['product'] as Product;
      }
      print('No duplicate product found.');
      return null;
    } catch (e) {
      print('Error checking product existence: $e');
      showCustomToast('Error checking product: $e');
      return null;
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<void> showDuplicateDialog(BuildContext context, Product? product,
      {bool fromSave = false}) async {
    if (product == null) {
      showCustomToast('Failed to fetch product details.');
      return;
    }
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Product Already Exists'),
        content: Text(
            'The product "${product.name}" with barcode "${product.code}" is already in your store. Would you like to edit it or scan another product?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (fromSave) {
                navigationService.navigateTo(addProductScannerRoute);
              }
            },
            child: const Text('Scan Another'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorValues.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              navigationService.navigateTo(addProductViewRoute, arguments: {
                'isEditing': true,
                'product': product,
                'storeId': customerService.activeStoreId,
                'ownerId': customerService.getOwnerId(),
              });
            },
            child: const Text('Edit Product'),
          ),
        ],
      ),
    );
  }

  Future<void> saveOrUpdateProduct({
    required BuildContext context,
    bool isEditing = false,
    Product? existingProduct,
    String? scannedCode,
    required String ownerId,
    required String storeId,
    File? selectedImage,
  }) async {
    if (!formKey.currentState!.validate()) {
      showCustomToast('Please fill all required fields with valid values.');
      return;
    }

    final price = double.tryParse(priceController.text);
    final costPrice = double.tryParse(costPriceController.text);
    final quantity = int.tryParse(quantityController.text);
    final minQuantity = int.tryParse(minQuantityController.text);

    if (price == null || price <= 0) {
      showCustomToast('Price must be greater than 0.');
      return;
    }
    if (costPrice == null || costPrice < 0) {
      showCustomToast('Cost price cannot be negative.');
      return;
    }
    if (quantity == null || quantity < 1) {
      showCustomToast('Quantity must be at least 1.');
      return;
    }
    if (minQuantity == null || minQuantity < 1) {
      showCustomToast('Minimum quantity must be at least 1.');
      return;
    }

    final productCode = codeController.text.trim().isEmpty
        ? scannedCode
        : codeController.text.trim();
    if (!isEditing && productCode != null && productCode.isNotEmpty) {
      final existingProduct = await checkProductExistence(productCode, context);
      if (existingProduct != null) {
        await showDuplicateDialog(context, existingProduct, fromSave: true);
        return;
      }
    }

    startLoader(
        message: isEditing ? 'Updating product...' : 'Adding product...');
    try {
      final productData = Product(
        id: existingProduct?.id,
        name: nameController.text.trim(),
        code: productCode,
        category: categoryController.text.trim().isEmpty
            ? 'Uncategorized'
            : categoryController.text.trim(),
        price: price,
        costPrice: costPrice,
        quantity: quantity,
        minQuantity: minQuantity,
        expiryDate: expiryDateController.text.trim().isEmpty
            ? null
            : expiryDateController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        size: sizeController.text.trim().isEmpty
            ? null
            : sizeController.text.trim(),
        brands: brandsController.text.trim().isEmpty
            ? null
            : brandsController.text.trim(),
        storeId: storeId,
        imageUrl: productImageUrl,
      );

      if (isEditing && existingProduct != null) {
        final updated = await productRepository.updateProduct(
            existingProduct.id!, productData, storeId);
        if (updated != null) {
          if (selectedImage != null) {
            final imageProduct = await productRepository.uploadProductImage(
                updated.id!, storeId, selectedImage.path);
            if (imageProduct != null) {
              productImageUrl = imageProduct.imageUrl;
            }
          }
          _updateProductLists(updated);
          await fetchTotalStock(storeId);
          showCustomToast('Product updated successfully!');
          navigationService.goBack();
        } else {
          showCustomToast('Failed to update product.');
        }
      } else {
        final response = await productRepository.scanAndAddProduct(
          data: productData,
          scannedCode: productCode ?? '',
          storeId: storeId,
          imageFile: selectedImage,
          ownerId: ownerId,
        );
        if (response != null && response.success && response.data != null) {
          _allProducts.value = [..._allProducts.value, response.data!];
          await fetchTotalStock(storeId);
          clearControllers();
          navigationService.navigateToWidget(
            CelebrationWidget(
              title: 'Back to Dashboard',
              onTap: () {
                navigationService.navigateTo(dashboardRoute);
              },
              child: Text(
                'Product "${productData.name}" Added Successfully!',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        } else {
          showCustomToast(
              'Failed to add product: ${response?.message ?? 'Unknown error'}');
        }
      }
    } catch (e) {
      showCustomToast('Error processing product: $e');
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product'),
        content: Text(
            'Are you sure you want to delete "${product.name}" from your store?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    startLoader(message: 'Deleting product...');
    try {
      final storeId = customerService.activeStoreId!;
      final deleted =
          await productRepository.deleteProduct(product.id!, storeId);
      if (deleted) {
        _allProducts.value =
            _allProducts.value.where((p) => p.id != product.id).toList();
        _expiringProducts.value =
            _expiringProducts.value.where((p) => p.id != product.id).toList();
        _lowStockProducts.value =
            _lowStockProducts.value.where((p) => p.id != product.id).toList();
        await fetchTotalStock(storeId);
        showCustomToast('Product deleted successfully.');
      } else {
        showCustomToast('Failed to delete product.');
      }
    } catch (e) {
      print('Error deleting product: $e');
      showCustomToast('Error deleting product: $e');
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<void> supplyProduct(
      BuildContext context, Product product, int additionalQuantity) async {
    if (additionalQuantity <= 0) {
      showCustomToast('Please enter a valid quantity.');
      return;
    }

    startLoader(message: 'Restocking product...');
    try {
      final storeId = customerService.activeStoreId!;
      final updated = await productRepository.supplyProduct(
          product.id!, additionalQuantity, storeId);
      if (updated != null) {
        _updateProductLists(updated);
        await fetchTotalStock(storeId);
        showCustomToast('Product restocked successfully!');
      } else {
        showCustomToast('Failed to restock product.');
      }
    } catch (e) {
      print('Error restocking product: $e');
      showCustomToast('Error restocking product: $e');
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  void searchProduct(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final storeId = customerService.activeStoreId;
      if (storeId == null) {
        errorMessage.value = 'No active store selected.';
        showCustomToast('No active store selected.');
        return;
      }
      await fetchAllProducts(storeId,
          search: query.trim().isEmpty ? null : query);
    });
  }

  void _updateProductLists(Product updated) {
    _allProducts.value = _allProducts.value
        .map((p) => p.id == updated.id ? updated : p)
        .toList();
    if (_expiringProducts.value.any((p) => p.id == updated.id)) {
      _expiringProducts.value = _expiringProducts.value
          .map((p) => p.id == updated.id ? updated : p)
          .toList();
    }
    if (_lowStockProducts.value.any((p) => p.id == updated.id)) {
      _lowStockProducts.value = _lowStockProducts.value
          .map((p) => p.id == updated.id ? updated : p)
          .toList();
    }
  }

  bool _validateForm() {
    final price = double.tryParse(priceController.text);
    final costPrice = double.tryParse(costPriceController.text);
    final quantity = int.tryParse(quantityController.text);
    final minQuantity = int.tryParse(minQuantityController.text);

    return nameController.text.trim().isNotEmpty &&
        categoryController.text.trim().isNotEmpty &&
        price != null &&
        price > 0.0 && // Ensure price > 0
        costPrice != null &&
        costPrice >= 0.0 &&
        quantity != null &&
        quantity >= 1 &&
        minQuantity != null &&
        minQuantity >= 1;
  }

  void updateTotals() {
    final price = double.tryParse(priceController.text) ?? 1.0;
    final quantity = int.tryParse(quantityController.text) ?? 1;
    final total = price * quantity;
    totalValueController.text = total.toStringAsFixed(2);
    notifyListeners();
  }

  String getTotalValue() {
    return totalValueController.text.isEmpty
        ? '0.00'
        : totalValueController.text;
  }

  void clearControllers() {
    nameController.clear();
    codeController.clear();
    categoryController.clear();
    priceController.text = '1.00'; // Ensure price > 0
    costPriceController.text = '0.00';
    quantityController.text = '1';
    minQuantityController.text = '1';
    expiryDateController.clear();
    descriptionController.clear();
    sizeController.clear();
    brandsController.clear();
    totalValueController.clear();
    productImageUrl = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    nameController.dispose();
    codeController.dispose();
    categoryController.dispose();
    priceController.dispose();
    costPriceController.dispose();
    quantityController.dispose();
    minQuantityController.dispose();
    expiryDateController.dispose();
    descriptionController.dispose();
    sizeController.dispose();
    brandsController.dispose();
    totalValueController.dispose();
    searchController.dispose();
    _allProducts.dispose();
    _expiringProducts.dispose();
    _lowStockProducts.dispose();
    _productHistory.dispose();
    _totalCost.dispose();
    _totalSellingPrice.dispose();
    _totalStock.dispose();
    _isLoadingExpiring.dispose();
    _isLoadingLowStock.dispose();
    _isLoadingProductHistory.dispose();
    _productTabIndex.dispose();
    isFetchingExternalData.dispose();
    super.dispose();
  }

  final List<Color> containerColor = [
    const Color(0xffFFF7E6),
    const Color(0xffF0F0FF),
   //const Color(0xffFEEAFA),
  ];

  final List<String> productOperations = [
    "Add Product",
    "Product List",
  ];

  final List<String> images = [
    SvgAssets.addProduct,
    SvgAssets.records,
  ];

  void changeContainer() {
    currentIndex = (currentIndex + 1) % containerColor.length;
    notifyListeners();
  }
}
