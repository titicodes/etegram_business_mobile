import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/core/model/product_history_model.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:path_provider/path_provider.dart';
import '../../../app_widget/celebration_widget.dart';
import '../../../base/base_vm.dart';
import '../../../constants/assets.dart';
import '../../../constants/colors.dart';
import '../../../routes/routes.dart';
import '../../../service/local/user_service.dart';

class ProductViewModel extends BaseViewModel {
  final CustomerService customerService = locator<CustomerService>();
  int currentIndex = 0;
  final formKey = GlobalKey<FormState>();
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
  final totalValue = ValueNotifier<String>('');
  final searchController = TextEditingController();
  final ValueNotifier<bool> isFetchingExternalData = ValueNotifier<bool>(false);
  final errorMessage = ValueNotifier<String?>(null);
  File? selectedImage;
  String? localImagePath;

  ProductViewModel() {
    priceController.addListener(_debouncedUpdateTotals);
    costPriceController.addListener(_debouncedUpdateTotals);
    quantityController.addListener(_debouncedUpdateTotals);
    minQuantityController.addListener(_debouncedUpdateTotals);
    print(
        'ProductViewModel: Added listeners for price, costPrice, quantity, minQuantity');
    print('ProductViewModel: Initialized instance ${hashCode}');
  }

  bool _isValidObjectId(String? id) {
    if (id == null || id.isEmpty) return false;
    final regex = RegExp(r'^[0-9a-fA-F]{24}$');
    return regex.hasMatch(id);
  }

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
  ValueListenable<double> get totalCost => _totalCost;
  final _totalCost = ValueNotifier<double>(0.0);
  ValueListenable<double> get totalSellingPrice => _totalSellingPrice;
  final _totalSellingPrice = ValueNotifier<double>(0.0);
  ValueListenable<int> get totalStock => _totalStock;
  final _totalStock = ValueNotifier<int>(0);
  String? productImageUrl;
  ValueListenable<bool> get isLoadingExpiring => _isLoadingExpiring;
  final _isLoadingExpiring = ValueNotifier<bool>(false);
  ValueListenable<bool> get isLoadingLowStock => _isLoadingLowStock;
  final _isLoadingLowStock = ValueNotifier<bool>(false);
  final _productTabIndex = ValueNotifier<int>(0);
  Timer? _debounce;
  final ValueNotifier<int> productTabIndex = ValueNotifier(0);

  void init({
    bool isEditing = false,
    String? scannedCode,
    Product? product,
    String? ownerId,
    String? storeId,
  }) {
    if (product != null) {
      populateControllers(product);
    } else if (scannedCode != null) {
      codeController.text = scannedCode;
      categoryController.text = 'Uncategorized';
    }
    print(
        'ProductViewModel: Initialized with scannedCode=$scannedCode, isEditing=$isEditing');
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
    startLoader(message: 'Fetching product details...');
    try {
      print(
          'ProductViewModel: Fetching product by code: code=$code, storeId=$storeId, ownerId=$ownerId');
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
          costPrice: 1.00,
          minQuantity: 1,
          category: 'Uncategorized',
          brands: null,
        ),
      );
      if (product.id != null && _isValidObjectId(product.id!)) {
        print('ProductViewModel: Fetched product: ${product.toJson()}');
        return AddProductResponse(success: true, data: product);
      } else {
        print('ProductViewModel: No product found for code: $code');
        return AddProductResponse(
            success: true, data: null, message: 'No product found');
      }
    } catch (e, stackTrace) {
      print(
          'ProductViewModel: Error fetching product by code: $e\n$stackTrace');
      return AddProductResponse(
          success: false, message: 'Failed to fetch product: $e');
    } finally {
      stopLoader();
    }
  }

  void populateControllers(Product product) {
    print(
        'ProductViewModel: Populating controllers for product: ${product.toJson()}');
    nameController.text = product.name ?? '';
    codeController.text = product.code ?? '';
    categoryController.text = product.category ?? 'Uncategorized';
    costPriceController.text = product.costPrice?.toStringAsFixed(2) ?? '0.00';
    priceController.text = product.price?.toStringAsFixed(2) ?? '1.00';
    quantityController.text = product.quantity?.toString() ?? '1';
    minQuantityController.text = product.minQuantity?.toString() ?? '1';
    if (product.expiryDate != null && product.expiryDate!.isNotEmpty) {
      try {
        final date = DateTime.parse(product.expiryDate!);
        expiryDateController.text = DateFormat('dd MMM yyyy').format(date);
      } catch (e) {
        print(
            'ProductViewModel: Error parsing expiry date: ${product.expiryDate}, error: $e');
        expiryDateController.text = product.expiryDate ?? '';
      }
    } else {
      expiryDateController.text = '';
    }
    descriptionController.text = product.description ?? '';
    sizeController.text = product.size ?? '';
    brandsController.text = product.brands?.join(', ') ?? '';
    productImageUrl = product.imageUrl;
    selectedImage = null;
    localImagePath = null;
    _debouncedUpdateTotals();
    print(
        'ProductViewModel: Controllers populated - name: ${nameController.text}, code: ${codeController.text}, brands: ${brandsController.text}, imageUrl: $productImageUrl');
    notifyListeners();
  }

  Future<void> fetchAllProducts(String storeId,
      {String? search, String? category}) async {
    startLoader();
    errorMessage.value = null;
    try {
      if (category != null && !_isValidObjectId(category)) {
        print(
            'ProductViewModel: Invalid category ID: $category, omitting category filter');
        category = null;
      }
      print(
          'ProductViewModel: Fetching all products: storeId=$storeId, search=$search, category=$category');
      final products = await productRepository.getFilteredProducts(
        storeId: storeId,
        search: search,
        category: category,
      );
      print('ProductViewModel: Fetched ${products.length} products.');
      _allProducts.value = products;
      if (_allProducts.value.isEmpty && (search == null || search.isEmpty)) {
        errorMessage.value = 'No products found for this store.';
      }
    } catch (e, stackTrace) {
      print('ProductViewModel: Error fetching all products: $e\n$stackTrace');
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
    } catch (e, stackTrace) {
      print(
          'ProductViewModel: Error fetching expiring products: $e\n$stackTrace');
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
    } catch (e, stackTrace) {
      print(
          'ProductViewModel: Error fetching low stock products: $e\n$stackTrace');
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
            'ProductViewModel: Inventory Summary - Total Cost: ${_totalCost.value}, Total Selling Price: ${_totalSellingPrice.value}, Total Quantity: ${_totalStock.value}');
      } else {
        print('ProductViewModel: Inventory summary data is null.');
        errorMessage.value = 'Failed to load inventory summary.';
      }
    } catch (e, stackTrace) {
      print(
          'ProductViewModel: Error fetching inventory summary: $e\n$stackTrace');
      errorMessage.value = 'Failed to fetch inventory summary: ${e.toString()}';
      showCustomToast('Failed to fetch inventory summary.', success: false);
    }
  }

  Future<void> fetchTotalStock(String storeId) async {
    try {
      final total = await productRepository.getTotalStockWithProducts(storeId);
      _totalStock.value = (total['totalQuantity'] as int? ?? 0).toInt();
      print('ProductViewModel: Fetched total stock: ${_totalStock.value}');
    } catch (e, stackTrace) {
      print('ProductViewModel: Error fetching total stock: $e\n$stackTrace');
      errorMessage.value = 'Failed to fetch total stock: ${e.toString()}';
      showCustomToast('Failed to fetch total stock.', success: false);
    }
  }

  Future<void> fetchProductHistory(String productId, String storeId) async {
    _isLoadingProductHistory.value = true;
    try {
      print(
          'ProductViewModel: Fetching product history: productId=$productId, storeId=$storeId');
      final history = await productRepository.getProductHistory(
        productId: productId,
        storeId: storeId,
      );
      print('ProductViewModel: Raw history from repository: $history');
      if (history.isNotEmpty) {
        _productHistory.value = history;
        print(
            'ProductViewModel: Updated _productHistory with ${history.length} entries');
      } else {
        _productHistory.value = [];
        print('ProductViewModel: No history entries found');
      }
    } catch (e, stackTrace) {
      print(
          'ProductViewModel: Error fetching product history: $e\n$stackTrace');
      _productHistory.value = [];
      showCustomToast('Failed to fetch product history: $e', success: false);
    } finally {
      _isLoadingProductHistory.value = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductDetailsFromAPI(String barcode,
      {bool silent = false}) async {
    isFetchingExternalData.value = true;
    notifyListeners();
    print('ProductViewModel: Fetching product details for barcode: $barcode');

    try {
      final response = await http.get(Uri.parse(
          'https://world.openfoodfacts.org/api/v0/product/$barcode.json'));
      print('ProductViewModel: API response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          final productData = data['product'];
          nameController.text =
              productData['product_name'] ?? productData['generic_name'] ?? '';
          categoryController.text =
              productData['categories'] ?? 'Uncategorized';
          brandsController.text =
              productData['brands']?.split(',').join(', ') ?? '';
          sizeController.text =
              productData['quantity'] ?? productData['net_weight'] ?? '';
          productImageUrl = productData['image_front_url'] ?? '';
          codeController.text = barcode;
          priceController.text = '1.00';
          costPriceController.text = '0.00';
          quantityController.text = '1';
          minQuantityController.text = '5';
          descriptionController.text = productData['ingredients_text'] ?? '';
          _debouncedUpdateTotals();
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
    } catch (e, stackTrace) {
      print(
          'ProductViewModel: Error fetching product details: $e\n$stackTrace');
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
        print('ProductViewModel: checkProductExistence: No active storeId');
        return false;
      }

      print(
          'ProductViewModel: Checking product existence: code=$code, storeId=$storeId');
      final result =
          await productRepository.checkProductExistence(code, storeId);
      print('ProductViewModel: Check product response: $result');

      if (result == null) {
        print(
            'ProductViewModel: checkProductExistence: Null response from repository');
        showCustomToast(
            'Unable to verify product due to server error. Please try again.',
            success: false);
        return false;
      }

      if (result['success'] == true && result['exists'] == true) {
        print('ProductViewModel: Product exists for code: $code');
        return true;
      } else if (result['success'] == true && result['exists'] == false) {
        print('ProductViewModel: No duplicate product found for code: $code');
        return false;
      } else {
        print(
            'ProductViewModel: Unexpected response: success=${result['success']}, exists=${result['exists']}');
        showCustomToast('Unable to verify product. Please try again later.',
            success: false);
        return false;
      }
    } catch (e, stackTrace) {
      print(
          'ProductViewModel: Error checking product existence: $e\n$stackTrace');
      showCustomToast('Failed to check product. Please try again.',
          success: false);
      return false;
    } finally {
      stopLoader();
    }
  }

  Future<void> showDuplicateDialog(BuildContext context, Product? product,
      {bool fromSave = false, String? barcode}) async {
    print('ProductViewModel: Showing duplicate dialog for barcode: $barcode');
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
              print(
                  'ProductViewModel: Duplicate dialog: Scan Another selected');
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
              print(
                  'ProductViewModel: Duplicate dialog: Edit Product selected');
              Navigator.pop(context);
              final storeId = await customerService.activeStoreId;
              final ownerId = await customerService.getOwnerId();
              if (storeId == null || ownerId == null) {
                showCustomToast('Store or owner information missing.',
                    success: false);
                return;
              }
              Product? existingProduct = product;
              if (existingProduct == null && barcode != null) {
                final response =
                    await fetchProductByCode(barcode, storeId, ownerId);
                existingProduct = response.data;
              }
              if (existingProduct != null) {
                await navigationService
                    .navigateTo(addProductViewRoute, arguments: {
                  'isEditing': true,
                  'product': existingProduct,
                  'storeId': storeId,
                  'ownerId': ownerId,
                  'needsImageSelection': existingProduct.imageUrl == null,
                });
              } else {
                showCustomToast(
                    'Failed to retrieve product for editing. Please try again.',
                    success: false);
              }
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
    String? ownerId,
    String? storeId,
    File? selectedImage,
  }) async {
    if (!formKey.currentState!.validate()) {
      showCustomToast('Please fill all required fields with valid values.',
          context: context);
      return;
    }

    final price = double.tryParse(priceController.text);
    final costPrice = double.tryParse(costPriceController.text);
    final quantity = int.tryParse(quantityController.text);
    final minQuantity = int.tryParse(minQuantityController.text);

    if (price == null || price <= 0) {
      showCustomToast('Price must be greater than 0.', context: context);
      return;
    }
    if (costPrice == null || costPrice < 0) {
      showCustomToast('Cost price cannot be negative.', context: context);
      return;
    }
    if (quantity == null || quantity < 0) {
      showCustomToast('Quantity cannot be negative.', context: context);
      return;
    }
    if (minQuantity == null || minQuantity < 1) {
      showCustomToast('Minimum quantity must be at least 1.', context: context);
      return;
    }

    final effectiveStoreId = storeId ?? await customerService.activeStoreId;
    final effectiveOwnerId = ownerId ?? await customerService.getOwnerId();
    if (effectiveStoreId == null || effectiveOwnerId == null) {
      showCustomToast('Store or owner information missing.',
          success: false, context: context);
      return;
    }

    String? productCode = isEditing
        ? (existingProduct?.code ?? codeController.text.trim())
        : (scannedCode ?? codeController.text.trim());

    if (productCode == null || productCode.isEmpty) {
      showCustomToast('Product code (barcode) cannot be empty.',
          context: context);
      return;
    }

    print('ProductViewModel: Performing duplicate check for code: $productCode');
    final exists = await checkProductExistence(productCode, context);
    if (exists) {
      print('ProductViewModel: Product exists for code: $productCode');
      if (!isEditing) {
        print(
            'ProductViewModel: Duplicate found during save (isEditing=false): $productCode');
        await showDuplicateDialog(context, null,
            barcode: productCode, fromSave: true);
        return;
      }
      print('ProductViewModel: Fetching product by code for editing: $productCode');
      final response = await fetchProductByCode(
          productCode, effectiveStoreId, effectiveOwnerId);
      if (!response.success || response.data?.id == null) {
        print(
            'ProductViewModel: Failed to fetch product ID for code: $productCode');
        showCustomToast(
          'Error: Product exists but could not be retrieved for editing. Please try again.',
          success: false,
          context: context,
        );
        return;
      }
      existingProduct = response.data;
    } else if (isEditing) {
      print('ProductViewModel: Product does not exist for editing: $productCode');
      showCustomToast(
        'Error: Product not found for editing. Please add it as a new product.',
        success: false,
        context: context,
      );
      return;
    }

    startLoader(message: isEditing ? 'Updating product...' : 'Adding product...');
    try {
      String? formattedExpiryDate;
      if (expiryDateController.text.trim().isNotEmpty) {
        try {
          final date =
          DateFormat('dd MMM yyyy').parse(expiryDateController.text.trim());
          formattedExpiryDate = DateFormat('yyyy-MM-dd').format(date);
        } catch (e) {
          print(
              'ProductViewModel: Failed to parse as dd MMM yyyy, trying ISO 8601: $e');
          try {
            final date = DateTime.parse(expiryDateController.text.trim());
            formattedExpiryDate = DateFormat('yyyy-MM-dd').format(date);
          } catch (e) {
            print('ProductViewModel: Failed to parse expiry date: $e');
            showCustomToast('Invalid expiry date format.',
                success: false, context: context);
            return;
          }
        }
      }

      Product productData = Product(
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
            : brandsController.text.trim().split(',').map((e) => e.trim()).toList(),
        storeId: effectiveStoreId,
        owner: effectiveOwnerId,
        imageUrl: selectedImage == null ? productImageUrl : null,
      );

      print('ProductViewModel: Saving product data: ${productData.toJson()}');

      if (isEditing && productData.id != null && _isValidObjectId(productData.id!)) {
        print('ProductViewModel: Updating product (isEditing=true): ${productData.id}');
        final updated = await productRepository.updateProduct(
          productData.id!,
          productData,
          effectiveStoreId,
          imageFile: selectedImage,
          imageUrl: selectedImage == null ? productImageUrl : null,
        );

        if (updated != null) {
          productImageUrl = updated.imageUrl;
          _updateProductLists(updated);
          await fetchInventorySummary(effectiveStoreId);
          showCustomToast('Product updated successfully!',
              success: true, context: context);
          navigationService.goBack();
        } else {
          showCustomToast('Failed to update product.',
              success: false, context: context);
        }
      } else if (!isEditing) {
        print('ProductViewModel: Adding new product: $productCode');
        final response = await productRepository.scanAndAddProduct(
          data: productData,
          scannedCode: productCode,
          storeId: effectiveStoreId,
          imageFile: selectedImage,
          ownerId: effectiveOwnerId,
        );

        if (response != null && response.success && response.data != null) {
          productImageUrl = response.data!.imageUrl;
          _allProducts.value = [..._allProducts.value, response.data!];
          await fetchInventorySummary(effectiveStoreId);
          clearControllers();
          showCustomToast(
            'Product "${response.data!.name}" added successfully!',
            success: true,
            context: context,
          );
          // Navigate to CelebrationWidget and clear the stack
          navigationService.navigateToWidgetAndRemoveUntil(
            CelebrationWidget(
              title: 'Back to Dashboard',
              onTap: () {
                print(
                    'ProductViewModel: CelebrationWidget: Navigating to dashboardRoute and clearing stack');
                navigationService.navigateToAndRemoveUntil(dashboardRoute);
              },
              child: Text(
                'Product "${response.data!.name}" Added Successfully!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          showCustomToast(
            'Failed to add product: ${response?.message ?? 'Unknown error'}',
            success: false,
            context: context,
          );
        }
      } else {
        showCustomToast(
          'Error: Cannot update product without a valid ID.',
          success: false,
          context: context,
        );
      }
    } catch (e, stackTrace) {
      print('ProductViewModel: Error processing product: $e\n$stackTrace');
      if (e.toString().contains('E11000') || e.toString().contains('duplicate key')) {
        print(
            'ProductViewModel: Duplicate key error detected, fetching product to edit');
        final response = await fetchProductByCode(
            productCode, effectiveStoreId, effectiveOwnerId);
        if (response.success && response.data?.id != null) {
          await showDuplicateDialog(context, response.data,
              barcode: productCode, fromSave: true);
        } else {
          showCustomToast(
            'Error: Product exists but could not be retrieved for editing.',
            success: false,
            context: context,
          );
        }
      } else {
        showCustomToast('Error processing product: Please try again.',
            success: false, context: context);
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
    } catch (e, stackTrace) {
      print('ProductViewModel: Error deleting product: $e\n$stackTrace');
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
    } catch (e, stackTrace) {
      print('ProductViewModel: Error restocking product: $e\n$stackTrace');
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

  void _debouncedUpdateTotals() {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      print('ProductViewModel: priceController.text = ${priceController.text}');
      print(
          'ProductViewModel: quantityController.text = ${quantityController.text}');
      final price = double.tryParse(priceController.text) ?? 0.0;
      final quantity = int.tryParse(quantityController.text) ?? 0;
      final total = price * quantity;
      final newTotal = total == 0.0 ? '' : total.toStringAsFixed(2);
      if (totalValue.value != newTotal) {
        totalValue.value = newTotal;
        print(
            'ProductViewModel: Updated totals - price: $price, quantity: $quantity, total: $total');
        notifyListeners();
      } else {
        print('ProductViewModel: No update needed - total unchanged: $total');
      }
    });
  }

  String getTotalValue() {
    return totalValue.value.isEmpty ? '0.00' : totalValue.value;
  }

  void updateTotals() {
    _debouncedUpdateTotals();
  }

  Future<void> selectExpiryDate(BuildContext context) async {
    final initialDate = expiryDateController.text.isNotEmpty
        ? DateTime.tryParse(expiryDateController.text) ?? DateTime.now()
        : DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      expiryDateController.text = DateFormat('dd MMM yyyy').format(pickedDate);
      _debouncedUpdateTotals();
    }
  }

  Future<void> pickImage(BuildContext context,
      {required ImageSource source}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxHeight: 600,
        maxWidth: 600,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (pickedFile != null) {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final targetPath = '${tempDir.path}/product_image_$timestamp.jpg';
        final targetFile = File(targetPath);
        await targetFile.writeAsBytes(await pickedFile.readAsBytes());
        if (await targetFile.exists()) {
          selectedImage = targetFile;
          localImagePath = targetFile.path;
          productImageUrl = null;
          print(
              'ProductViewModel: Image picked and persisted: ${targetFile.path}');
        } else {
          print('ProductViewModel: Failed to persist image to: $targetPath');
          showCustomToast('Failed to persist image.',
              success: false, context: context);
        }
        notifyListeners();
      } else {
        print('ProductViewModel: Image selection cancelled');
        showCustomToast('Image selection cancelled.',
            success: false, context: context);
      }
    } catch (e, stackTrace) {
      print('ProductViewModel: Error picking image: $e\n$stackTrace');
      showCustomToast('Failed to pick image.',
          success: false, context: context);
    }
  }

  void clearControllers() {
    nameController.clear();
    codeController.clear();
    categoryController.clear();
    priceController.clear();
    costPriceController.clear();
    quantityController.clear();
    minQuantityController.clear();
    expiryDateController.clear();
    descriptionController.clear();
    sizeController.clear();
    brandsController.clear();
    totalValue.value = '';
    productImageUrl = null;
    selectedImage = null;
    localImagePath = null;
    print('ProductViewModel: Cleared controllers');
    notifyListeners();
  }

  @override
  void dispose() {
    print('ProductViewModel: Disposing instance ${hashCode}');
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
    totalValue.dispose();
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
