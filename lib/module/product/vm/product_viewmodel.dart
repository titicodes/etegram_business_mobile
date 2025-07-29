// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:etegram_business/constants/style.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
// import 'package:http/http.dart' as http;
//
// import 'package:etegram_business/core/model/product_model.dart';
// import 'package:etegram_business/core/model/product_history_model.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/utils/snack_message.dart';
// import 'package:intl/intl.dart';
//
// import '../../../app_widget/celebration_widget.dart';
// import '../../../base/base_vm.dart';
// import '../../../constants/assets.dart';
// import '../../../constants/colors.dart';
// import '../../../routes/routes.dart';
// import '../../../service/local/user_service.dart';
//
// class ProductViewModel extends BaseViewModel {
//   final CustomerService customerService = locator<CustomerService>();
//
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
//
//   ProductViewModel() {
//     priceController.addListener(updateTotals);
//     quantityController.addListener(updateTotals);
//     costPriceController.addListener(updateTotals);
//     minQuantityController.addListener(updateTotals);
//     priceController.text = '1.00';
//     costPriceController.text = '0.00';
//     quantityController.text = '1';
//     minQuantityController.text = '1';
//     updateTotals();
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
//   ValueListenable<List<ProductHistory>> get productHistory => _productHistory;
//   final _productHistory = ValueNotifier<List<ProductHistory>>([]);
//   ValueListenable<bool> get isLoadingProductHistory => _isLoadingProductHistory;
//   final _isLoadingProductHistory = ValueNotifier<bool>(false);
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
//
//   ValueListenable<bool> get isLoadingExpiring => _isLoadingExpiring;
//   final _isLoadingExpiring = ValueNotifier<bool>(false);
//   ValueListenable<bool> get isLoadingLowStock => _isLoadingLowStock;
//   final _isLoadingLowStock = ValueNotifier<bool>(false);
//   final _productTabIndex = ValueNotifier<int>(0);
//   Timer? _debounce;
//   final ValueNotifier<int> productTabIndex = ValueNotifier(0);
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
//
//   List<DataTab> get productTabOptions => [
//         DataTab(title: "All Product"),
//         DataTab(title: "Expiring"),
//         DataTab(title: "Low Stock"),
//       ];
//
//   Future<void> initialize() async {
//     final storeId = await customerService.activeStoreId;
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
//     ]);
//   }
//
//   void populateControllers(Product product) {
//     nameController.text = product.name ?? '';
//     codeController.text = product.code ?? '';
//     categoryController.text = product.category ?? '';
//     costPriceController.text = product.costPrice?.toStringAsFixed(2) ?? '0.00';
//     priceController.text = product.price?.toStringAsFixed(2) ?? '1.00';
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
//       final products = await productRepository.getFilteredProducts(
//         storeId: storeId,
//         search: search,
//         category: category,
//       );
//       print('Fetched ${products.length} products.');
//       _allProducts.value = products;
//       if (_allProducts.value.isEmpty && (search == null || search.isEmpty)) {
//         errorMessage.value = 'No products found for this store.';
//       }
//     } catch (e) {
//       print('Error fetching all products: $e');
//       errorMessage.value = 'Failed to fetch products: ${e.toString()}';
//       showCustomToast('Failed to fetch products.', success: false);
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
//       errorMessage.value = 'Failed to fetch expiring products: ${e.toString()}';
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
//       errorMessage.value =
//           'Failed to fetch low stock products: ${e.toString()}';
//       showCustomToast('Failed to fetch low stock products.', success: false);
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
//         _totalCost.value = (summary['totalCost'] as num? ?? 0).toDouble();
//         _totalSellingPrice.value =
//             (summary['totalSellingPrice'] as num? ?? 0).toDouble();
//         _totalStock.value = (summary['totalQuantity'] as int? ?? 0).toInt();
//         print(
//             'Inventory Summary - Total Cost: ${_totalCost.value}, Total Selling Price: ${_totalSellingPrice.value}, Total Quantity: ${_totalStock.value}');
//       } else {
//         print('Inventory summary data is null.');
//         errorMessage.value = 'Failed to load inventory summary.';
//       }
//     } catch (e) {
//       print('Error fetching inventory summary: $e');
//       errorMessage.value = 'Failed to fetch inventory summary: ${e.toString()}';
//       showCustomToast('Failed to fetch inventory summary.', success: false);
//     }
//   }
//
//   Future<void> fetchTotalStock(String storeId) async {
//     try {
//       final total = await productRepository.getTotalStockWithProducts(storeId);
//       _totalStock.value = (total['totalQuantity'] as int? ?? 0).toInt();
//       print(
//           'Fetched total stock (from getTotalStockWithProducts): ${_totalStock.value}');
//     } catch (e) {
//       print('Error fetching total stock: $e');
//       errorMessage.value = 'Failed to fetch total stock: ${e.toString()}';
//       showCustomToast('Failed to fetch total stock.', success: false);
//     }
//   }
//
//   Future<void> fetchProductHistory(String productId, String storeId) async {
//     _isLoadingProductHistory.value = true;
//     try {
//       final history = await productRepository.getProductHistory(
//           productId: productId, storeId: storeId);
//       _productHistory.value = history;
//     } catch (e) {
//       print('Error fetching product history: $e');
//       showCustomToast('Failed to fetch product history.', success: false);
//     } finally {
//       _isLoadingProductHistory.value = false;
//     }
//   }
//
//   Future<void> fetchProductDetailsFromAPI(String barcode,
//       {bool silent = false}) async {
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
//           priceController.text = '1.00';
//           costPriceController.text = '0.00';
//           quantityController.text = '1';
//           minQuantityController.text = '5';
//           descriptionController.text = productData['ingredients_text'] ?? '';
//           updateTotals();
//           if (!silent) {
//             showCustomToast('Product details fetched successfully!',
//                 success: true);
//           }
//         } else {
//           clearControllers();
//           codeController.text = barcode;
//           if (!silent) {
//             showCustomToast(
//                 'Product not found. Please enter details manually.');
//           }
//         }
//       } else {
//         clearControllers();
//         codeController.text = barcode;
//         if (!silent) {
//           showCustomToast('Failed to fetch product details.', success: false);
//         }
//       }
//     } catch (e) {
//       print('Error fetching product details: $e');
//       clearControllers();
//       codeController.text = barcode;
//       if (!silent) {
//         showCustomToast('Error fetching product details.');
//       }
//     } finally {
//       isFetchingExternalData.value = false;
//       notifyListeners();
//     }
//   }
//
//   Future<bool> checkProductExistence(String code, BuildContext context) async {
//     startLoader(message: 'Checking product...');
//     try {
//       final storeId = await customerService.activeStoreId;
//       if (storeId == null) {
//         showCustomToast('No active store selected.', success: false);
//         print('checkProductExistence: No active storeId');
//         return false;
//       }
//
//       print('Checking product existence: code=$code, storeId=$storeId');
//       final result =
//           await productRepository.checkProductExistence(code, storeId);
//       print('Check product response: $result');
//
//       if (result == null) {
//         print('checkProductExistence: Null response from repository');
//         showCustomToast(
//             'Unable to verify product due to server error. Please try again.',
//             success: false);
//         return false;
//       }
//
//       if (result['success'] == true && result['exists'] == true) {
//         print('Product exists for code: $code');
//         return true;
//       } else if (result['success'] == true && result['exists'] == false) {
//         print('No duplicate product found for code: $code');
//         return false;
//       } else {
//         print(
//             'Unexpected response: success=${result['success']}, exists=${result['exists']}');
//         showCustomToast('Unable to verify product. Please try again later.',
//             success: false);
//         return false;
//       }
//     } catch (e, stackTrace) {
//       print('Error checking product existence: $e\n$stackTrace');
//       showCustomToast('Failed to check product. Please try again.',
//           success: false);
//       return false;
//     } finally {
//       stopLoader();
//       notifyListeners();
//     }
//   }
//
//   Future<void> showDuplicateDialog(BuildContext context, Product? product,
//       {bool fromSave = false, String? barcode}) async {
//     print('Showing duplicate dialog for barcode: $barcode');
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           'Product Already Exists',
//           style: subHeaderTextStyle.copyWith(color: ColorValues.primaryColor),
//         ),
//         content: RichText(
//           text: TextSpan(
//               text: 'A product with barcode ',
//               style: normalTextStyle,
//               children: <TextSpan>[
//                 TextSpan(
//                   text: "$barcode",
//                   style: normalTextStyle12,
//                 ),
//                 TextSpan(
//                     text:
//                         ' is already in your store. Would you like to edit it or scan another product?',
//                     style: normalTextStyle)
//               ]),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               print('Duplicate dialog: Scan Another selected');
//               Navigator.pop(context);
//               if (fromSave) {
//                 navigationService.navigateTo(addProductScannerRoute);
//               }
//             },
//             child: const Text('Scan Another'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: ColorValues.primaryColor,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//             ),
//             onPressed: () async {
//               print('Duplicate dialog: Edit Product selected');
//               Navigator.pop(context);
//               final storeId = await customerService.activeStoreId;
//               final ownerId = await customerService.getOwnerId();
//               if (storeId == null || ownerId == null) {
//                 showCustomToast('Store or owner information missing.',
//                     success: false);
//                 return;
//               }
//               // Fetch product details if not provided
//               Product? existingProduct = product;
//               if (existingProduct == null && barcode != null) {
//                 final products = await productRepository.getFilteredProducts(
//                     storeId: storeId, search: barcode);
//                 existingProduct = products.firstWhere((p) => p.code == barcode,
//                     orElse: () => Product(code: barcode, storeId: storeId));
//               }
//               await navigationService
//                   .navigateTo(addProductViewRoute, arguments: {
//                 'isEditing': true,
//                 'product': existingProduct,
//                 'storeId': storeId,
//                 'ownerId': ownerId,
//                 'needsImageSelection': false,
//               });
//             },
//             child: const Text('Edit Product'),
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
//     File? selectedImage,
//   }) async {
//     if (!formKey.currentState!.validate()) {
//       showCustomToast('Please fill all required fields with valid values.');
//       return;
//     }
//
//     final price = double.tryParse(priceController.text);
//     final costPrice = double.tryParse(costPriceController.text);
//     final quantity = int.tryParse(quantityController.text);
//     final minQuantity = int.tryParse(minQuantityController.text);
//
//     if (price == null || price <= 0) {
//       showCustomToast('Price must be greater than 0.');
//       return;
//     }
//     if (costPrice == null || costPrice < 0) {
//       showCustomToast('Cost price cannot be negative.');
//       return;
//     }
//     if (quantity == null || quantity < 1) {
//       showCustomToast('Quantity must be at least 1.');
//       return;
//     }
//     if (minQuantity == null || minQuantity < 1) {
//       showCustomToast('Minimum quantity must be at least 1.');
//       return;
//     }
//
//     String? productCode = isEditing
//         ? (existingProduct?.code ?? codeController.text.trim())
//         : (scannedCode ?? codeController.text.trim());
//
//     if (productCode == null || productCode.isEmpty) {
//       showCustomToast('Product code (barcode) cannot be empty.');
//       return;
//     }
//
//     // Fallback duplicate check before saving
//     if (!isEditing) {
//       print(
//           'saveOrUpdateProduct: Performing fallback duplicate check for code: $productCode');
//       final exists = await checkProductExistence(productCode, context);
//       if (exists) {
//         print('saveOrUpdateProduct: Duplicate found during save: $productCode');
//         await showDuplicateDialog(context, null,
//             barcode: productCode, fromSave: true);
//         return;
//       }
//     }
//
//     startLoader(
//         message: isEditing ? 'Updating product...' : 'Adding product...');
//     try {
//       final productData = Product(
//         id: existingProduct?.id,
//         name: nameController.text.trim(),
//         code: productCode,
//         category: categoryController.text.trim().isEmpty
//             ? 'Uncategorized'
//             : categoryController.text.trim(),
//         price: price,
//         costPrice: costPrice,
//         quantity: quantity,
//         minQuantity: minQuantity,
//         expiryDate: expiryDateController.text.trim().isEmpty
//             ? null
//             : DateFormat('yyyy-MM-dd').format(DateFormat('dd MMM yyyy')
//                 .parse(expiryDateController.text.trim())),
//         description: descriptionController.text.trim().isEmpty
//             ? null
//             : descriptionController.text.trim(),
//         size: sizeController.text.trim().isEmpty
//             ? null
//             : sizeController.text.trim(),
//         brands: brandsController.text.trim().isEmpty
//             ? null
//             : brandsController.text.trim(),
//         storeId: storeId,
//         imageUrl: selectedImage == null ? productImageUrl : null,
//       );
//
//       if (isEditing && existingProduct != null) {
//         print('Updating product (isEditing=true)');
//         final updated = await productRepository.updateProduct(
//           existingProduct.id!,
//           productData,
//           storeId,
//           imageFile: selectedImage,
//           imageUrl: selectedImage == null ? productImageUrl : null,
//         );
//
//         if (updated != null) {
//           productImageUrl = updated.imageUrl;
//           _updateProductLists(updated);
//           await fetchInventorySummary(storeId);
//           showCustomToast('Product updated successfully!', success: true);
//           navigationService.goBack();
//         } else {
//           showCustomToast('Failed to update product.', success: false);
//         }
//       } else {
//         print('Adding new product (isEditing=false)');
//         final response = await productRepository.scanAndAddProduct(
//           data: productData,
//           scannedCode: productCode,
//           storeId: storeId,
//           imageFile: selectedImage,
//           ownerId: ownerId,
//         );
//
//         if (response != null && response.success && response.data != null) {
//           _allProducts.value = [..._allProducts.value, response.data!];
//           await fetchInventorySummary(storeId);
//           clearControllers();
//           showCustomToast(
//               'Product "${response.data!.name}" added successfully!',
//               success: true);
//           navigationService.navigateToWidget(
//             CelebrationWidget(
//               title: 'Back to Dashboard',
//               onTap: () {
//                 navigationService.navigateTo(dashboardRoute);
//               },
//               child: Text(
//                 'Product "${response.data!.name}" Added Successfully!',
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
//               'Failed to add product: ${response?.message ?? 'Unknown error'}',
//               success: false);
//         }
//       }
//     } catch (e, stackTrace) {
//       print('Error processing product: $e\n$stackTrace');
//       if (e.toString().contains('E11000') ||
//           e.toString().contains('duplicate key')) {
//         await showDuplicateDialog(context, null,
//             barcode: productCode, fromSave: true);
//       } else {
//         showCustomToast('Error processing product: Please try again.',
//             success: false);
//       }
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
//       final storeId = await customerService.activeStoreId;
//       if (storeId == null) {
//         showCustomToast('No active store selected.');
//         stopLoader();
//         return;
//       }
//
//       final deleted =
//           await productRepository.deleteProduct(product.id!, storeId);
//       if (deleted) {
//         _allProducts.value =
//             _allProducts.value.where((p) => p.id != product.id).toList();
//         _expiringProducts.value =
//             _expiringProducts.value.where((p) => p.id != product.id).toList();
//         _lowStockProducts.value =
//             _lowStockProducts.value.where((p) => p.id != product.id).toList();
//
//         await fetchInventorySummary(storeId);
//         showCustomToast('Product deleted successfully.', success: true);
//       } else {
//         showCustomToast('Failed to delete product.', success: false);
//       }
//     } catch (e) {
//       print('Error deleting product: ${e.toString()}');
//       showCustomToast('Error deleting product: Please try again.',
//           success: false);
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
//       final storeId = await customerService.activeStoreId;
//       if (storeId == null) {
//         showCustomToast('No active store selected.');
//         stopLoader();
//         return;
//       }
//
//       final updated = await productRepository.supplyProduct(
//           product.id!, additionalQuantity, storeId);
//       if (updated != null) {
//         _updateProductLists(updated);
//         await fetchInventorySummary(storeId);
//         showCustomToast('Product restocked successfully!', success: true);
//       } else {
//         showCustomToast('Failed to restock product.', success: false);
//       }
//     } catch (e) {
//       print('Error restocking product: ${e.toString()}');
//       showCustomToast('Error restocking product: Please try again.',
//           success: false);
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
//       final storeId = await customerService.activeStoreId;
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
//   void _updateProductLists(Product updated) {
//     _allProducts.value = _allProducts.value
//         .map((p) => p.id == updated.id ? updated : p)
//         .toList();
//
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
//   void updateTotals() {
//     final price = double.tryParse(priceController.text) ?? 0.0;
//     final quantity = int.tryParse(quantityController.text) ?? 0;
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
//     priceController.text = '1.00';
//     costPriceController.text = '0.00';
//     quantityController.text = '1';
//     minQuantityController.text = '1';
//     expiryDateController.clear();
//     descriptionController.clear();
//     sizeController.clear();
//     brandsController.clear();
//     totalValueController.clear();
//     productImageUrl = null;
//     updateTotals();
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
//     isFetchingExternalData.dispose();
//     errorMessage.dispose();
//
//     _allProducts.dispose();
//     _expiringProducts.dispose();
//     _lowStockProducts.dispose();
//     _productHistory.dispose();
//     _isLoadingProductHistory.dispose();
//     _totalCost.dispose();
//     _totalSellingPrice.dispose();
//     _totalStock.dispose();
//     _isLoadingExpiring.dispose();
//     _isLoadingLowStock.dispose();
//     _productTabIndex.dispose();
//     tabIndex.dispose();
//     productTabIndex.dispose();
//
//     super.dispose();
//   }
//
//   final List<Color> containerColor = [
//     const Color(0xffFFF7E6),
//     const Color(0xffF0F0FF),
//   ];
//
//   final List<String> productOperations = [
//     "Add Product",
//     "Product List",
//   ];
//
//   final List<String> images = [
//     SvgAssets.addProduct,
//     SvgAssets.records,
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

import 'package:etegram_business/constants/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/core/model/product_history_model.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/utils/snack_message.dart';

import '../../../app_widget/celebration_widget.dart';
import '../../../base/base_vm.dart';
import '../../../constants/assets.dart';
import '../../../constants/colors.dart';
import '../../../routes/routes.dart';
import '../../../service/local/user_service.dart';

class ProductViewModel extends BaseViewModel {
  final CustomerService customerService = locator<CustomerService>();

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
    priceController.text = '1.00';
    costPriceController.text = '0.00';
    quantityController.text = '1';
    minQuantityController.text = '1';
    updateTotals();
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
    final storeId = await customerService.activeStoreId;
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
    ]);
  }

  Future<AddProductResponse> fetchProductByCode(
      String code, String storeId, String ownerId) async {
    try {
      print('Fetching product by code: code=$code, storeId=$storeId, ownerId=$ownerId');
      final products = await productRepository.getFilteredProducts(
        storeId: storeId,
        search: code,
      );
      final product = products.firstWhere(
            (p) => p.code == code,
        orElse: () => Product(
          code: code,
          storeId: storeId,
          owner: ownerId,
          name: '',
          quantity: 0,
          price: 1.00,
        ),
      );
      print('Fetched product: ${product.toJson()}');
      return AddProductResponse(success: true, data: product);
    } catch (e) {
      print('Error fetching product by code: $e');
      return AddProductResponse(
          success: false, message: 'Failed to fetch product: $e');
    }
  }

  void populateControllers(Product product) {
    nameController.text = product.name ?? '';
    codeController.text = product.code ?? '';
    categoryController.text = product.category ?? '';
    costPriceController.text = product.costPrice?.toStringAsFixed(2) ?? '0.00';
    priceController.text = product.price?.toStringAsFixed(2) ?? '1.00';
    quantityController.text = product.quantity?.toString() ?? '1';
    minQuantityController.text = product.minQuantity?.toString() ?? '1';
    // Format ISO 8601 date to 'dd MMM yyyy' if possible
    if (product.expiryDate != null && product.expiryDate!.isNotEmpty) {
      try {
        final date = DateTime.parse(product.expiryDate!);
        expiryDateController.text = DateFormat('dd MMM yyyy').format(date);
      } catch (e) {
        print('Error parsing expiry date: ${product.expiryDate}, error: $e');
        expiryDateController.text = product.expiryDate!;
      }
    } else {
      expiryDateController.text = '';
    }
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
      final products = await productRepository.getFilteredProducts(
        storeId: storeId,
        search: search,
        category: category,
      );
      print('Fetched ${products.length} products.');
      _allProducts.value = products;
      if (_allProducts.value.isEmpty && (search == null || search.isEmpty)) {
        errorMessage.value = 'No products found for this store.';
      }
    } catch (e) {
      print('Error fetching all products: $e');
      errorMessage.value = 'Failed to fetch products: ${e.toString()}';
      showCustomToast('Failed to fetch products.', success: false);
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
      errorMessage.value = 'Failed to fetch expiring products: ${e.toString()}';
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
      errorMessage.value =
      'Failed to fetch low stock products: ${e.toString()}';
      showCustomToast('Failed to fetch low stock products.', success: false);
      _lowStockProducts.value = [];
    } finally {
      _isLoadingLowStock.value = false;
    }
  }

  Future<void> fetchInventorySummary(String storeId) async {
    try {
      final summary = await productRepository.getInventorySummary(storeId);
      if (summary != null) {
        _totalCost.value = (summary['totalCost'] as num? ?? 0).toDouble();
        _totalSellingPrice.value =
            (summary['totalSellingPrice'] as num? ?? 0).toDouble();
        _totalStock.value = (summary['totalQuantity'] as int? ?? 0).toInt();
        print(
            'Inventory Summary - Total Cost: ${_totalCost.value}, Total Selling Price: ${_totalSellingPrice.value}, Total Quantity: ${_totalStock.value}');
      } else {
        print('Inventory summary data is null.');
        errorMessage.value = 'Failed to load inventory summary.';
      }
    } catch (e) {
      print('Error fetching inventory summary: $e');
      errorMessage.value = 'Failed to fetch inventory summary: ${e.toString()}';
      showCustomToast('Failed to fetch inventory summary.', success: false);
    }
  }

  Future<void> fetchTotalStock(String storeId) async {
    try {
      final total = await productRepository.getTotalStockWithProducts(storeId);
      _totalStock.value = (total['totalQuantity'] as int? ?? 0).toInt();
      print(
          'Fetched total stock (from getTotalStockWithProducts): ${_totalStock.value}');
    } catch (e) {
      print('Error fetching total stock: $e');
      errorMessage.value = 'Failed to fetch total stock: ${e.toString()}';
      showCustomToast('Failed to fetch total stock.', success: false);
    }
  }

  Future<void> fetchProductHistory(String productId, String storeId) async {
    _isLoadingProductHistory.value = true;
    try {
      print('Fetching product history: productId=$productId, storeId=$storeId');
      final history = await productRepository.getProductHistory(
        productId: productId,
        storeId: storeId,
      );
      print('Raw history from repository: $history');
      if (history.isNotEmpty) {
        _productHistory.value = history;
        print('Updated _productHistory with ${history.length} entries: $history');
      } else {
        _productHistory.value = [];
        print('No history entries found in response');
      }
    } catch (e, stackTrace) {
      print('Error fetching product history: $e\nStack trace: $stackTrace');
      _productHistory.value = [];
      showCustomToast('Failed to fetch product history: $e', success: false);
    } finally {
      _isLoadingProductHistory.value = false;
      notifyListeners();
      print('Notified listeners, isLoadingProductHistory: ${_isLoadingProductHistory.value}');
    }
  }

  Future<void> fetchProductDetailsFromAPI(String barcode,
      {bool silent = false}) async {
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
          priceController.text = '1.00';
          costPriceController.text = '0.00';
          quantityController.text = '1';
          minQuantityController.text = '5';
          descriptionController.text = productData['ingredients_text'] ?? '';
          updateTotals();
          if (!silent) {
            showCustomToast('Product details fetched successfully!',
                success: true);
          }
        } else {
          clearControllers();
          codeController.text = barcode;
          if (!silent) {
            showCustomToast(
                'Product not found. Please enter details manually.');
          }
        }
      } else {
        clearControllers();
        codeController.text = barcode;
        if (!silent) {
          showCustomToast('Failed to fetch product details.', success: false);
        }
      }
    } catch (e) {
      print('Error fetching product details: $e');
      clearControllers();
      codeController.text = barcode;
      if (!silent) {
        showCustomToast('Error fetching product details.');
      }
    } finally {
      isFetchingExternalData.value = false;
      notifyListeners();
    }
  }

  Future<bool> checkProductExistence(String code, BuildContext context) async {
    startLoader(message: 'Checking product...');
    try {
      final storeId = await customerService.activeStoreId;
      if (storeId == null) {
        showCustomToast('No active store selected.', success: false);
        print('checkProductExistence: No active storeId');
        return false;
      }

      print('Checking product existence: code=$code, storeId=$storeId');
      final result =
      await productRepository.checkProductExistence(code, storeId);
      print('Check product response: $result');

      if (result == null) {
        print('checkProductExistence: Null response from repository');
        showCustomToast(
            'Unable to verify product due to server error. Please try again.',
            success: false);
        return false;
      }

      if (result['success'] == true && result['exists'] == true) {
        print('Product exists for code: $code');
        return true;
      } else if (result['success'] == true && result['exists'] == false) {
        print('No duplicate product found for code: $code');
        return false;
      } else {
        print(
            'Unexpected response: success=${result['success']}, exists=${result['exists']}');
        showCustomToast('Unable to verify product. Please try again later.',
            success: false);
        return false;
      }
    } catch (e, stackTrace) {
      print('Error checking product existence: $e\n$stackTrace');
      showCustomToast('Failed to check product. Please try again.',
          success: false);
      return false;
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<void> showDuplicateDialog(BuildContext context, Product? product,
      {bool fromSave = false, String? barcode}) async {
    print('Showing duplicate dialog for barcode: $barcode');
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Product Already Exists',
          style: subHeaderTextStyle.copyWith(color: ColorValues.primaryColor),
        ),
        content: RichText(
          text: TextSpan(
              text: 'A product with barcode ',
              style: normalTextStyle,
              children: <TextSpan>[
                TextSpan(
                  text: "$barcode",
                  style: normalTextStyle12,
                ),
                TextSpan(
                    text:
                    ' is already in your store. Would you like to edit it or scan another product?',
                    style: normalTextStyle)
              ]),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('Duplicate dialog: Scan Another selected');
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
            onPressed: () async {
              print('Duplicate dialog: Edit Product selected');
              Navigator.pop(context);
              final storeId = await customerService.activeStoreId;
              final ownerId = await customerService.getOwnerId();
              if (storeId == null || ownerId == null) {
                showCustomToast('Store or owner information missing.',
                    success: false);
                return;
              }
              // Fetch product details if not provided
              Product? existingProduct = product;
              if (existingProduct == null && barcode != null) {
                final response =
                await fetchProductByCode(barcode, storeId, ownerId);
                existingProduct = response.data;
              }
              await navigationService.navigateTo(addProductViewRoute,
                  arguments: {
                    'isEditing': true,
                    'product': existingProduct,
                    'storeId': storeId,
                    'ownerId': ownerId,
                    'needsImageSelection': false,
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

    String? productCode = isEditing
        ? (existingProduct?.code ?? codeController.text.trim())
        : (scannedCode ?? codeController.text.trim());

    if (productCode == null || productCode.isEmpty) {
      showCustomToast('Product code (barcode) cannot be empty.');
      return;
    }

    // Fallback duplicate check before saving
    if (!isEditing) {
      print(
          'saveOrUpdateProduct: Performing fallback duplicate check for code: $productCode');
      final exists = await checkProductExistence(productCode, context);
      if (exists) {
        print('saveOrUpdateProduct: Duplicate found during save: $productCode');
        await showDuplicateDialog(context, null,
            barcode: productCode, fromSave: true);
        return;
      }
    }

    startLoader(
        message: isEditing ? 'Updating product...' : 'Adding product...');
    try {
      // Parse expiry date with fallback for ISO 8601
      String? formattedExpiryDate;
      if (expiryDateController.text.trim().isNotEmpty) {
        try {
          // Try parsing as 'dd MMM yyyy'
          final date =
          DateFormat('dd MMM yyyy').parse(expiryDateController.text.trim());
          formattedExpiryDate = DateFormat('yyyy-MM-dd').format(date);
        } catch (e) {
          print('Failed to parse as dd MMM yyyy, trying ISO 8601: $e');
          try {
            // Fallback to ISO 8601
            final date = DateTime.parse(expiryDateController.text.trim());
            formattedExpiryDate = DateFormat('yyyy-MM-dd').format(date);
          } catch (e) {
            print('Failed to parse expiry date: $e');
            showCustomToast('Invalid expiry date format.', success: false);
            return;
          }
        }
      }

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
        expiryDate: formattedExpiryDate,
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
        owner: ownerId,
        imageUrl: selectedImage == null ? productImageUrl : null,
      );

      if (isEditing && existingProduct != null) {
        print('Updating product (isEditing=true)');
        final updated = await productRepository.updateProduct(
          existingProduct.id!,
          productData,
          storeId,
          imageFile: selectedImage,
          imageUrl: selectedImage == null ? productImageUrl : null,
        );

        if (updated != null) {
          productImageUrl = updated.imageUrl;
          _updateProductLists(updated);
          await fetchInventorySummary(storeId);
          showCustomToast('Product updated successfully!', success: true);
          navigationService.goBack();
        } else {
          showCustomToast('Failed to update product.', success: false);
        }
      } else {
        print('Adding new product (isEditing=false)');
        final response = await productRepository.scanAndAddProduct(
          data: productData,
          scannedCode: productCode,
          storeId: storeId,
          imageFile: selectedImage,
          ownerId: ownerId,
        );

        if (response != null && response.success && response.data != null) {
          _allProducts.value = [..._allProducts.value, response.data!];
          await fetchInventorySummary(storeId);
          clearControllers();
          showCustomToast(
              'Product "${response.data!.name}" added successfully!',
              success: true);
          navigationService.navigateToWidget(
            CelebrationWidget(
              title: 'Back to Dashboard',
              onTap: () {
                navigationService.navigateTo(dashboardRoute);
              },
              child: Text(
                'Product "${response.data!.name}" Added Successfully!',
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
              'Failed to add product: ${response?.message ?? 'Unknown error'}',
              success: false);
        }
      }
    } catch (e, stackTrace) {
      print('Error processing product: $e\n$stackTrace');
      if (e.toString().contains('E11000') ||
          e.toString().contains('duplicate key')) {
        await showDuplicateDialog(context, null,
            barcode: productCode, fromSave: true);
      } else {
        showCustomToast('Error processing product: Please try again.',
            success: false);
      }
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
      final storeId = await customerService.activeStoreId;
      if (storeId == null) {
        showCustomToast('No active store selected.');
        stopLoader();
        return;
      }

      final deleted =
      await productRepository.deleteProduct(product.id!, storeId);
      if (deleted) {
        _allProducts.value =
            _allProducts.value.where((p) => p.id != product.id).toList();
        _expiringProducts.value =
            _expiringProducts.value.where((p) => p.id != product.id).toList();
        _lowStockProducts.value =
            _lowStockProducts.value.where((p) => p.id != product.id).toList();

        await fetchInventorySummary(storeId);
        showCustomToast('Product deleted successfully.', success: true);
      } else {
        showCustomToast('Failed to delete product.', success: false);
      }
    } catch (e) {
      print('Error deleting product: ${e.toString()}');
      showCustomToast('Error deleting product: Please try again.',
          success: false);
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
      final storeId = await customerService.activeStoreId;
      if (storeId == null) {
        showCustomToast('No active store selected.');
        stopLoader();
        return;
      }

      final updated = await productRepository.supplyProduct(
          product.id!, additionalQuantity, storeId);
      if (updated != null) {
        _updateProductLists(updated);
        await fetchInventorySummary(storeId);
        showCustomToast('Product restocked successfully!', success: true);
      } else {
        showCustomToast('Failed to restock product.', success: false);
      }
    } catch (e) {
      print('Error restocking product: ${e.toString()}');
      showCustomToast('Error restocking product: Please try again.',
          success: false);
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
      final storeId = await customerService.activeStoreId;
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

  void updateTotals() {
    final price = double.tryParse(priceController.text) ?? 0.0;
    final quantity = int.tryParse(quantityController.text) ?? 0;
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
    codeController.text = '';
    categoryController.clear();
    priceController.text = '1.00';
    costPriceController.text = '0.00';
    quantityController.text = '1';
    minQuantityController.text = '1';
    expiryDateController.clear();
    descriptionController.clear();
    sizeController.clear();
    brandsController.clear();
    totalValueController.clear();
    productImageUrl = null;
    updateTotals();
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
    isFetchingExternalData.dispose();
    errorMessage.dispose();

    _allProducts.dispose();
    _expiringProducts.dispose();
    _lowStockProducts.dispose();
    _productHistory.dispose();
    _isLoadingProductHistory.dispose();
    _totalCost.dispose();
    _totalSellingPrice.dispose();
    _totalStock.dispose();
    _isLoadingExpiring.dispose();
    _isLoadingLowStock.dispose();
    _productTabIndex.dispose();
    tabIndex.dispose();
    productTabIndex.dispose();

    super.dispose();
  }

  final List<Color> containerColor = [
    const Color(0xffFFF7E6),
    const Color(0xffF0F0FF),
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
