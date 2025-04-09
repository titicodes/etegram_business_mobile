import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/locator.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:camera/camera.dart';
import '../../../app_widget/barcode_scanner_view.dart';
import '../../../app_widget/celebration_widget.dart';
import '../../../constants/assets.dart';
import '../../../core/model/get_scan_response.dart';
import '../../../core/model/get_search_response.dart';
import '../../../core/model/product_model.dart';
import '../../../core/model/supply_response.dart';
import '../../../utils/snack_message.dart';
import '../../sales/vm/new_sales_vm.dart';
import '../view/add_product.dart';
import 'package:http/http.dart' as http;

class PRoductViewModel extends BaseViewModel {
  // Controllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController costPriceController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController minQuantityController = TextEditingController();
  final TextEditingController filterController = TextEditingController();
  final TextEditingController brandController = TextEditingController();

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
  List<Product> _products = [];
  final TabController? tabController;
  bool _isLoading = false;
  ProductData? selectedProduct;
  AddProductResponse? _addProductResponse;
  String search = "";
  TextEditingController searchController = TextEditingController();
  TextEditingController stockController = TextEditingController();
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

  @override
  bool get isLoading => _isLoading;

  AddProductResponse? get addProductResponse => _addProductResponse;

  bool _isAdding = false;

  bool get isAdding => _isAdding;
  String? _addErrorMessage;

  String? get addErrorMessage => _addErrorMessage;
  bool _isAddSuccessful = false;

  bool get isAddSuccessful => _isAddSuccessful;
  bool _isAddingProduct = false;

  bool get isAddingProduct => _isAddingProduct;

  PRoductViewModel({this.tabController});

  List<String> filterBySelection = ["Electronic", "Discounted Sales"];
  bool _disposed = false;

  @override
  void dispose() {
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

    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Initialize ViewModel
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

  // Fetch All Products or Perform Search
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

  // Search Product Function
  Future<void> searchProduct(String query) async {
    if (query.isEmpty) {
      await fetchProducts(); // Reset to all products when search is cleared
    } else {
      await fetchProducts(query: query);
    }
  }

  // Update Product Function
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
        await fetchProducts(); // Refresh list
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
    costPriceController.clear();
    unitPriceController.clear();
    quantityController.text = '1';
    minQuantityController.text = '1';
    brandController.clear(); // Clear the brand controller
    productImageUrl = '';
    notifyListeners();
  }

  Future<void> startBarcodeScan(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerView(
          purpose: ScanPurpose.add,
        ),
      ),
    );
  }

  final List<Cart> _cartItems = [];
  List<Cart> get cartItems => _cartItems;

  Future<void> scanAndAddProduct(
      Product product, String scannedCode, BuildContext context) async {
    // Add BuildContext
    if (_isAddingProduct) return;
    _isAddingProduct = true;
    notifyListeners();

    try {
      final AddProductResponse? response =
          await productRepository.scanAndAddProduct(
              // Explicit type
              data: product,
              scannedCode: scannedCode);

      if (response != null &&
          response.success == true &&
          response.data != null) {
        showCustomToast('Product added successfully.');

        // Navigate to CelebrationWidget
      } else {
        showCustomToast(
            'Failed to add product: ${response?.message ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        showCustomToast('Product code already exists.');
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

  Future<void> fetchProductDetailsFromAPI(String barcode) async {
    isFetchingExternalData = true;
    _safeNotifyListeners();

    final apiUrl =
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 1) {
          final productData = data['product'];

          debugPrint('Product Data: ${jsonEncode(productData)}');

          nameController.text =
              productData['product_name']?.toString() ?? 'Unknown Product';

          String size = '';
          if (productData.containsKey('quantity') &&
              productData['quantity'] != null) {
            size = productData['quantity'].toString();
          } else if (productData.containsKey('net_weight') &&
              productData['net_weight'] != null) {
            size = productData['net_weight'].toString();
          } else if (productData.containsKey('serving_size') &&
              productData['serving_size'] != null) {
            size = productData['serving_size'].toString();
          } else if (productData.containsKey('packaging') &&
              productData['packaging'] != null) {
            size = productData['packaging'].toString();
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

          costPriceController.text = '';
          unitPriceController.text = '';
          quantityController.text = '1';
          minQuantityController.text = '1';

          showCustomToast('Product details found!');
        } else {
          debugPrint(
              'Product not found in Open Food Facts for barcode: $barcode');
          showCustomToast('Product not found.');
        }
      } else {
        debugPrint(
            'Failed to fetch product details for barcode: $barcode. Status: ${response.statusCode}');
        showCustomToast('Failed to fetch product details.');
      }
    } catch (e) {
      debugPrint(
          'Error fetching product details from API for barcode: $barcode. Error: $e');
      showCustomToast('Error fetching product details.');
    } finally {
      isFetchingExternalData = false;
      _safeNotifyListeners();
    }
  }

  /// ✅ Save or Update Product
  Future<void> saveOrUpdateProduct({
    Product? existingProduct,
    bool isEditing = false,
    String? scannedCode,
    required BuildContext context,
  }) async {
    if (formKey.currentState!.validate()) {
      try {
        startLoader();

        // ✅ Only attempt this for newly scanned product
        if (!isEditing && scannedCode != null) {
          // Use SaleViewModel to check if product exists
          final saleVM =
              locator<SaleViewModel>(); // or access from Provider/BaseView
          bool exists = await saleVM.checkIfProductExists(scannedCode, context);

          if (exists) {
            // Product already exists, added to cart
            showCustomToast("Product exists. Added to cart instead.");
            stopLoader();
            Navigator.pop(context); // Go back or show cart
            return;
          }
        }

        // ✅ Continue with normal add/edit logic
        int? stock = int.tryParse(stockController.text);
        int? costPrice = int.tryParse(costPriceController.text);
        int? unitPrice = int.tryParse(unitPriceController.text);
        int? quantity = int.tryParse(quantityController.text);
        int? minQuantity = int.tryParse(minQuantityController.text);

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
          price: costPrice,
          quantity: quantity,
          unitPrice: unitPrice,
          minQuantity: minQuantity,
          size: sizeController.text,
          brands: brandController.text,
          stock: stock,
        );

        if (isEditing && existingProduct != null) {
          await updateProduct(productData.copyWith(id: existingProduct.id));
          showCustomToast("Product updated successfully");
        } else {
          await scanAndAddProduct(productData, scannedCode!, context);
        }

        stopLoader();
        Navigator.pop(context);
      } catch (e) {
        stopLoader();
        print("Error saving/updating product: $e");
        showCustomToast("Failed to save/update product. Please try again.");
      }
    }
  }

  Future<bool> checkIfProductExists(
      String barcode, BuildContext context) async {
    try {
      startLoader();

      final barcodeInt = int.tryParse(barcode);
      if (barcodeInt == null) {
        showCustomToast('Invalid barcode format.');
        return false;
      }

      // Fetch response from salesRepository
      final response = await salesRepository.getScanProduct(code: barcodeInt);
      final productData = response?.data?.product;

      if (response?.success != true || productData == null) {
        showCustomToast('Product not found.');
        return false;
      }

      // Here, productData is already a ScanProduct, no need to decode
      final scannedProduct = productData;

      if ((scannedProduct.quantity ?? 0) <= 0) {
        showCustomToast('Product is out of stock.');
        return false;
      }

      final existingIndex =
          cartItems.indexWhere((item) => item.code == scannedProduct.code);

      if (existingIndex != -1) {
        // Update existing cart item if found
        cartItems[existingIndex].quantity += 1;
        cartItems[existingIndex].subtotal =
            cartItems[existingIndex].quantity * cartItems[existingIndex].price;
      } else {
        // Add new product to the cart
        cartItems.add(Cart(
          id: scannedProduct.id ?? '',
          name: scannedProduct.name ?? 'Unknown Product',
          price: scannedProduct.price ?? 0,
          code: scannedProduct.code ?? '',
          quantity: 1,
          subtotal: scannedProduct.price ?? 0,
        ));
      }

      // Notify listeners to update UI
      notifyListeners();
      return true;
    } catch (e) {
      print("Error in checkIfProductExists: $e");
      showCustomToast('Error checking product.');
      return false;
    } finally {
      stopLoader();
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


}
