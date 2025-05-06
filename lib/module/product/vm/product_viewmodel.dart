import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/locator.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:camera/camera.dart';
import '../../../app_widget/add_product_scanner.dart';
import '../../../app_widget/barcode_scanner_view.dart';
import '../../../app_widget/celebration_widget.dart';
import '../../../constants/assets.dart';
import '../../../core/model/get_scan_response.dart';
import '../../../core/model/get_search_response.dart';
import '../../../core/model/product_model.dart';
import '../../../service/local/user_service.dart'; // Import UserService
import '../../../service/web/base_api.dart';
import '../../../utils/snack_message.dart';
import '../view/add_product.dart';
import 'package:http/http.dart' as http;

class PRoductViewModel extends BaseViewModel {
  // Controllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController costPriceController =
      TextEditingController(text: '0');
  final TextEditingController unitPriceController =
      TextEditingController(text: '0');
  final TextEditingController quantityController =
      TextEditingController(text: '1');
  final TextEditingController minQuantityController =
      TextEditingController(text: '1');
  final TextEditingController filterController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController stockController =
      TextEditingController(text: '0');
  final TextEditingController totalValueController =
      TextEditingController(text: '0');

  bool isFetchingExternalData = false;
  int currentIndex = 0;
  String productName = '';
  String productSize = '';
  String productFilter = '';
  String suppliedTo = "";
  int costPrice = 0;
  double unitPrice = 0;
  int quantity = 0;
  int minQuantity = 0;
  int totalValue = 0;

  List<Product> _products = [];
  final TabController? tabController;
  bool _isLoading = false;
  ProductData? selectedProduct;
  AddProductResponse? _addProductResponse;
  String search = "";
  TextEditingController searchController = TextEditingController();
  BarcodeScanner? _barcodeScanner;
  CameraController? _cameraController;

  String filterBy = "";
  String productImageUrl = "";

  bool _isUpdating = false;

  bool get isUpdating => _isUpdating;
  String? _updateErrorMessage;

  String? get updateErrorMessage => _updateErrorMessage;
  bool _isUpdateSuccessful = false;

  bool get isUpdateSuccessful => _isUpdateSuccessful;

  List<Product> get products => _products;



  bool _isAdding = false;

  bool get isAdding => _isAdding;
  String? _addErrorMessage;

  String? get addErrorMessage => _addErrorMessage;
  bool _isAddSuccessful = false;

  bool get isAddSuccessful => _isAddSuccessful;
  bool _isAddingProduct = false;

  bool get isAddingProduct => _isAddingProduct;
  bool _isCheckingProductExistence = false;

  bool get isCheckingProductExistence => _isCheckingProductExistence;

  PRoductViewModel({this.tabController}) {
    unitPriceController.addListener(updateTotals);
    quantityController.addListener(updateTotals);
    stockController.addListener(updateTotals);
  }

  List<String> filterBySelection = ["Electronic", "Discounted Sales"];
  bool _disposed = false;

  @override
  void dispose() {
    unitPriceController.removeListener(updateTotals);
    quantityController.removeListener(updateTotals);
    stockController.removeListener(updateTotals);

    searchController.dispose();
    _barcodeScanner?.close();
    _cameraController?.dispose();
    nameController.dispose();
    sizeController.dispose();
    costPriceController.dispose();
    unitPriceController.dispose();
    quantityController.dispose();
    minQuantityController.dispose();
    filterController.dispose();
    brandController.dispose();
    stockController.dispose();
    totalValueController.dispose();

    _disposed = true;
    super.dispose();
  }

  void updateTotals() {
    if (_disposed) return;
    int unitPrice = int.tryParse(unitPriceController.text) ?? 0;
    int quantity = int.tryParse(quantityController.text) ?? 0;
    int stock = int.tryParse(stockController.text) ?? 0;
    totalValue = unitPrice * stock;
    totalValueController.text = totalValue.toString();
    notifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> init() async {
    await fetchProducts();
  }

  void addProduct(Product product) {
    final newProduct = Product(
      name: productName,
      size: productSize,
      price: unitPrice.toInt(),
      quantity: quantity,
    );
    _products.add(newProduct);
    notifyListeners();
  }

  bool disposed = false;

  Future<void> fetchProducts({String? query}) async {
    try {
      _isLoading = true;
      notifyListeners();
      List<Product>? response;
      if (query != null && query.isNotEmpty) {
        response = await productRepository.searchProduct(query);
      } else {
        response = await productRepository.searchProduct("");
      }
      if (response != null) {
        _products = response;
      } else {
        _products = [];
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
      showCustomToast('Error loading products.');
      _products = [];
    } finally {
      _isLoading = false;
      if (!disposed) notifyListeners();
    }
  }

  Future<void> searchProduct(String query) async {
    if (query.isEmpty) {
      await fetchProducts();
    } else {
      await fetchProducts(query: query);
    }
  }

  Future<void> updateProduct(Product updatedProduct) async {
    try {
      _isUpdating = true;
      _updateErrorMessage = null;
      _isUpdateSuccessful = false;
      notifyListeners();
      final response = await productRepository.updateProduct(
          updatedProduct.id!, updatedProduct);
      if (response != null) {
        showCustomToast('Product updated successfully.');
        _isUpdateSuccessful = true;
        await fetchProducts();
      } else {
        _updateErrorMessage = 'Failed to update product.';
        showCustomToast('Failed to update product.');
      }
    } catch (e) {
      debugPrint("Error updating product: $e");
      _updateErrorMessage = 'Error updating product: ${e.toString()}';
      showCustomToast('Error updating product.');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  void clearControllers() {
    nameController.clear();
    sizeController.clear();
    filterController.clear();
    costPriceController.text = '0';
    unitPriceController.text = '0';
    quantityController.text = '1';
    minQuantityController.text = '1';
    brandController.clear();
    stockController.text = '0';
    totalValueController.text = '0';
    productImageUrl = '';
    notifyListeners();
  }

  Future<void> startBarcodeScan(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScannerView(),
      ),
    );
  }

  final List<Cart> _cartItems = [];
  List<Cart> get cartItems => _cartItems;

  // Update the scanAndAddProduct method to show celebration screen on success
  Future<void> scanAndAddProduct(
    Product product,
    String scannedCode,
    BuildContext context,
    String ownerId,
    String storeId,
  ) async {
    if (_isAddingProduct) return;
    _isAddingProduct = true;
    notifyListeners();

    try {
      // Debug log for parameter verification
      debugPrint('ViewModel - scanAndAddProduct called with:');
      debugPrint('- scannedCode: $scannedCode');
      debugPrint('- ownerId: $ownerId');
      debugPrint('- storeId: $storeId');

      // Parameter validation
      if (scannedCode.isEmpty) {
        showCustomToast('Scanned code is missing.');
        _isAddingProduct = false;
        notifyListeners();
        return;
      }

      if (ownerId.isEmpty) {
        showCustomToast('Owner ID is missing.');
        _isAddingProduct = false;
        notifyListeners();
        return;
      }

      if (storeId.isEmpty) {
        showCustomToast('Store ID is missing.');
        _isAddingProduct = false;
        notifyListeners();
        return;
      }

      final AddProductResponse? response =
          await productRepository.scanAndAddProduct(
        data: product,
        scannedCode: scannedCode,
        context: context,
        storeId: storeId,
        ownerId: ownerId,
      );

      // If the response is not null, it means the product was added successfully
      if (response != null) {
        // Show the celebration screen
        await showCelebrationScreen(context, productName: product.name);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        showCustomToast('Product with this code already exists.');
      } else {
        debugPrint('Error adding product via scan: $e');
        showCustomToast('Error adding product.');
      }
    } catch (e) {
      debugPrint('General error adding product via scan: $e');
      showCustomToast('An unexpected error occurred.');
    } finally {
      _isAddingProduct = false;
      if (!disposed) notifyListeners();
    }
  }

  Future<bool> checkProductExistence(String code, BuildContext context) async {
    if (_isCheckingProductExistence) return false;
    _isCheckingProductExistence = true;
    notifyListeners();
    try {
      startLoader();
      final String? ownerId = await locator<CustomerService>().getOwnerId();
      final String? storeId = await locator<CustomerService>().getStoreId();

      print(
          'Checking Existence - Code: $code, Owner ID: $ownerId, Store ID: $storeId'); // Add logging

      if (ownerId == null || storeId == null) {
        showCustomToast('Could not retrieve user or store information.');
        stopLoader();
        _isCheckingProductExistence = false;
        notifyListeners();
        return false;
      }

      Response response =
          await connect().get("products/check-code", queryParameters: {
        'code': code,
        'ownerId': ownerId,
        'storeId': storeId,
      });

      if (response.statusCode == 200) {
        dynamic responseData = response.data; // Don't immediately cast

        if (responseData is String) {
          debugPrint('Error: Unexpected String response: $responseData');
          showCustomToast('Error checking product existence.');
          stopLoader();
          _isCheckingProductExistence = false;
          notifyListeners();
          return false;
        } else if (responseData is Map<String, dynamic>) {
          final existsData = responseData['data'] as Map<String, dynamic>?;
          final exists = existsData?['exists'] as bool?;
          stopLoader();
          _isCheckingProductExistence = false;
          notifyListeners();
          return exists ?? false;
        } else {
          debugPrint('Error: Unexpected response format: $responseData');
          showCustomToast('Error checking product existence.');
          stopLoader();
          _isCheckingProductExistence = false;
          notifyListeners();
          return false;
        }
      } else {
        debugPrint('Error checking product existence: ${response.statusCode}');
        showCustomToast('Failed to check product existence.');
        stopLoader();
        _isCheckingProductExistence = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error checking product existence: $e');
      showCustomToast('Error checking product existence.');
      stopLoader();
      _isCheckingProductExistence = false;
      notifyListeners();
      return false;
    } finally {
      if (!_isCheckingProductExistence) {
        stopLoader(); // Ensure stopLoader is called if not already done
        _isCheckingProductExistence = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchProductDetailsFromAPI(String barcode) async {
    isFetchingExternalData = true;
    notifyListeners();

    final apiUrl =
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json';

    try {
      debugPrint('Fetching product data from: $apiUrl');
      final response = await http.get(Uri.parse(apiUrl));

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint(
          'API Response Body: ${response.body.substring(0, min(100, response.body.length))}...');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 1) {
          final productData = data['product'];

          nameController.text = productData['product_name']?.toString() ??
              productData['generic_name']?.toString() ??
              'Unknown Product';

          String size = '';
          for (var sizeField in [
            'quantity',
            'net_weight',
            'serving_size',
            'packaging'
          ]) {
            if (productData.containsKey(sizeField) &&
                productData[sizeField] != null &&
                productData[sizeField].toString().isNotEmpty) {
              size = productData[sizeField].toString();
              break;
            }
          }
          sizeController.text = size;

          brandController.text =
              productData['brands']?.toString() ?? 'Unknown Brand';

          filterController.text =
              productData['categories']?.toString() ?? 'Unknown Category';

          productImageUrl = productData['image_front_url']?.toString() ??
              productData['image_url']?.toString() ??
              productData['image_thumb_url']?.toString() ??
              '';

          costPriceController.text = '0';
          unitPriceController.text = '0';
          quantityController.text = '1';
          minQuantityController.text = '1';
          stockController.text = '0';

          updateTotals();

          showCustomToast('Product details found!');
        } else {
          debugPrint(
              'Product not found in Open Food Facts for barcode: $barcode');
          showCustomToast('Product not found. Please enter details manually.');
          clearControllers();
        }
      } else {
        debugPrint(
            'Failed to fetch product details for barcode: $barcode. Status: ${response.statusCode}');
        showCustomToast(
            'Failed to fetch product details. Please enter manually.');
        clearControllers();
      }
    } catch (e) {
      debugPrint(
          'Error fetching product details from API for barcode: $barcode. Error: $e');
      showCustomToast('Error fetching product details. Please enter manually.');
      clearControllers();
    } finally {
      isFetchingExternalData = false;
      notifyListeners();
    }
  }

  /// ✅ Save or Update Product
  // Update the saveOrUpdateProduct method to show celebration for new products
  Future<void> saveOrUpdateProduct({
    Product? existingProduct,
    bool isEditing = false,
    String? scannedCode,
    required BuildContext context,
    required String ownerId,
    required String storeId,
  }) async {
    if (formKey.currentState!.validate()) {
      try {
        startLoader();
        updateTotals();

        int? stock = int.tryParse(stockController.text);
        int? costPrice = int.tryParse(costPriceController.text);
        int? unitPrice = int.tryParse(unitPriceController.text);
        int? quantity = int.tryParse(quantityController.text);
        int? minQuantity = int.tryParse(minQuantityController.text);
        int? totalValue = int.tryParse(totalValueController.text);

        if (stock == null ||
            costPrice == null ||
            unitPrice == null ||
            quantity == null ||
            minQuantity == null) {
          showCustomToast("Please enter valid numbers for all fields.");
          stopLoader();
          return;
        }

        Product productData = Product(
          name: nameController.text,
          code: scannedCode,
          category: filterController.text,
          price: unitPrice * quantity,
          quantity: quantity,
          unitPrice: unitPrice,
          minQuantity: minQuantity,
          size: sizeController.text,
          brands: brandController.text,
          stock: stock,
          totalCost: totalValue ?? (unitPrice * stock),
          owner: ownerId,
        );

        if (isEditing && existingProduct != null) {
          await updateProduct(productData.copyWith(id: existingProduct.id));
          showCustomToast("Product updated successfully");
        } else {
          // Parameter validation
          if (scannedCode == null || scannedCode.isEmpty) {
            showCustomToast(
                "Scanned code is missing. Please scan a barcode first.");
            stopLoader();
            return;
          }

          if (ownerId.isEmpty) {
            showCustomToast(
                "Owner ID is missing. Please check your account settings.");
            stopLoader();
            return;
          }

          if (storeId.isEmpty) {
            showCustomToast(
                "Store ID is missing. Please check your store settings.");
            stopLoader();
            return;
          }

          // Add the product
          await scanAndAddProduct(
              productData, scannedCode, context, ownerId, storeId);

          // Note: We don't need a separate showCelebrationScreen call here
          // since scanAndAddProduct already handles it
        }

        stopLoader();
      } catch (e) {
        stopLoader();
        debugPrint("Error saving/updating product: $e");
        showCustomToast("Failed to save/update product. Please try again.");
      }
    }
  }

  final List<Color> containerColor = [
    Color(0xffFFF7E6),
    Color(0xffF0F0FF),
    Color(0xffFEEAFA)
  ];

  final List<String> productOperations = [
    "Add Product",
    "Product List",
    "Move Products"
  ];

  final List<String> images = [
    SvgAssets.addProduct,
    SvgAssets.records,
    SvgAssets.newSupplier,
  ];

  void changeContainer() {
    currentIndex = ((currentIndex + 1) % containerColor.length);
    notifyListeners();
  }

  // Add this method to your PRoductViewModel class
  Future<void> showCelebrationScreen(BuildContext context,
      {String? productName}) async {
    // Wait a moment for any ongoing operations to complete
    await Future.delayed(const Duration(milliseconds: 300));

    // Navigate to the celebration screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CelebrationWidget(
          title: "Scan Another Product",
          onTap: () {
            // Close the celebration screen
            Navigator.pop(context);
            // Go back to the scanner
            startBarcodeScan(context);
          },
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                "Product Added Successfully!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 10),
              if (productName != null && productName.isNotEmpty)
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
