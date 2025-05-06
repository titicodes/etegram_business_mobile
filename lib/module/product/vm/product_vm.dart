import 'dart:convert';
import 'package:etegram_business/core/model/get_search_response.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../base/base_vm.dart';
import '../../../constants/assets.dart';
import '../../../utils/snack_message.dart';
import '../../../utils/widget_extension.dart';
import '../view/add_product.dart';

class ProductViewModel extends BaseViewModel {
  int currentIndex = 0;
  String productName = '';
  String productSize = '';
  String productFilter = '';
  String suppliedTo = "";
  int costPrice = 0;
  double unitPrice = 0;
  int quantity = 0;
  int minQuantity = 0;
  int _selectedIndex = 0;
  List<Product> _products = [];
  SearchProductResponse? allProduct;
  List<Product> _expiringProducts = [];
  List<Product> _lowStockProducts = [];
  List<Product> get allProducts => _products;
  List<Product> get expiringProducts => _expiringProducts;
  List<Product> get lowStockProducts => _lowStockProducts;
  bool _isLoadingExpiring = false;
  bool _isLoadingLowStock = false;
  bool get isLoadingExpiring => _isLoadingExpiring;
  bool get isLoadingLowStock => _isLoadingExpiring;

  int _currentExpiringPage = 1;
  int _currentLowStockPage = 1;
  final int _limit = 10;
  final TabController? tabController;
  bool _isScanning = false;
  bool _isLoading = false;
  SearchProductResponse? searchProductResponse;
  ProductData? selectedProduct;
  AddProductResponse? _addProductResponse; // ✅ Fixed missing definition

  String? _scannedCode;
  String? get scannedCode => _scannedCode;

  List<Product> get products => _products;
  // bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  AddProductResponse? get addProductResponse => _addProductResponse;

  ProductViewModel({this.tabController}) {
    fetchInventorySummaryData(); // Call it in the constructor
  }

  final ValueNotifier<double> _totalCost = ValueNotifier(0.0);
  ValueNotifier<double> get totalCost => _totalCost;

  final ValueNotifier<double> _totalSellingPrice = ValueNotifier(0.0);
  ValueNotifier<double> get totalSellingPrice => _totalSellingPrice;

  final ValueNotifier<int> _totalStock = ValueNotifier(0);
  ValueNotifier<int> get totalStock => _totalStock;

  int _currentPage = 1;
  int _currentIndex = 0;

  Future<void> initialize() async {
    await fetchProducts();
    await fetchExpiringProducts();
    await fetchLowStockProducts();
    fetchInventorySummaryData();
  }

  void changeIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  int get selectedIndex => _selectedIndex;
  final ValueNotifier<int> tabIndex = ValueNotifier(0);
  final ValueNotifier<int> productTabIndex = ValueNotifier(1);

  List<DataTab> get tabOptions => [
        DataTab(title: "Sent"),
        DataTab(title: "Received"),
      ];

  List<DataTab> get productTabOptions => [
        DataTab(title: "All Product"),
        DataTab(title: "Expiring"),
        DataTab(title: "Low Stock"),
      ];

  List<String> suppliedToSelection = ["Store", "Warehouse"];

  onSuppliedToChanged(String val) {
    suppliedTo = val;
    notifyListeners();
  }

  // Fetch paginated products
  Future<void> fetchProducts({bool loadMore = false}) async {
    if (loadMore) _currentPage++;
    _isLoading = true;
    notifyListeners();

    Product? fetchedProducts =
        await productRepository.getProducts(page: _currentPage);

    if (fetchedProducts != null) {
      List<Product> newProducts = (fetchedProducts as List)
          .map((item) => Product.fromJson(item))
          .toList();

      if (loadMore) {
        _products.addAll(newProducts);
      } else {
        _products = newProducts;
      }

      await productRepository.storeFetchedProduct(fetchedProducts);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔄 Fetch expiring products
  Future<void> fetchExpiringProducts({bool loadMore = false}) async {
    if (_isLoadingExpiring) return;

    _isLoadingExpiring = true;
    notifyListeners();

    final List<Product>? fetchedProductsList =
        await productRepository.fetchExpiringProducts(
      _currentExpiringPage,
      _limit,
    );
    if (fetchedProductsList != null) {
      if (loadMore) {
        _products.addAll(fetchedProductsList);
      } else {
        _products = fetchedProductsList;
      }

      for (final product in fetchedProductsList) {
        await productRepository
            .storeFetchedProduct(product); // Calling for each product
      }
    } else {
      if (!loadMore) {
        _products = [];
      }
      // Optionally handle error (e.g., show a message)
    }
    _isLoadingExpiring = false;
    notifyListeners();
  }

  Future<void> fetchAllProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      var response = await productRepository.getProducts();

      // Fix: Safely parse the nested response
      if (response != null && response is Map<String, dynamic>) {
        final dataMap = response as Map<String, dynamic>;

        if (dataMap['data'] != null && dataMap['data'] is List<dynamic>) {
          allProduct = SearchProductResponse.fromJson(dataMap);
        } else {
          // fallback for unexpected structure
          allProduct = SearchProductResponse();
        }
      }
    } catch (e) {
      print("Error fetching products: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchLowStockProducts({bool loadMore = false}) async {
    if (_isLoadingLowStock) return;

    // Set the page based on whether we are loading more products
    if (loadMore) {
      _currentLowStockPage++;
    } else {
      _currentLowStockPage = 1; // Start from the first page if not loading more
    }

    _isLoadingLowStock = true;
    notifyListeners();

    // Call fetch function to get the low stock products with required arguments
    final fetchedProducts = await productRepository.fetchLowStockProducts(
        _currentLowStockPage, _limit);

    if (fetchedProducts != null) {
      _lowStockProducts = fetchedProducts;
    }

    _isLoadingLowStock = false;
    notifyListeners();
  }

// Method to load the next page for expiring products
  Future<void> loadNextExpiringPage() async {
    _currentExpiringPage++;
    await fetchExpiringProducts();
  }

  // Method to load the next page for low stock products
  Future<void> loadNextLowStockPage() async {
    _currentLowStockPage++;
    await fetchLowStockProducts();
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  void changeTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void updateScannedCode(String code) {
    _scannedCode = code;
    notifyListeners();
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

  void stopScanning() {
    if (!disposed) {
      _isScanning = false;
      notifyListeners();
    }
  }

  void startScanning() {
    if (!disposed) {
      _isScanning = true;
      notifyListeners();
    }
  }

  void updateProductLists() {
    // Logic to update expiring, low stock, and total products
    // This could involve filtering _products based on certain criteria
    fetchExpiringProducts();
    fetchLowStockProducts();
    notifyListeners();
  }

  bool disposed = false;
  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  Future<void> fetchInventorySummaryData() async {
    isLoading.value = true;
    final summary = await productRepository.fetchInventorySummary();
    print("Inventory Summary Response: $summary"); // Check the raw response

    if (summary != null && summary['success'] == true && summary['data'] != null) {
      // Access the nested data field first
      final data = summary['data'];

      // Then extract the values from the data object
      _totalCost.value = (data['totalCost'] as num?)?.toDouble() ?? 0.0;
      _totalSellingPrice.value = (data['totalSellingPrice'] as num?)?.toDouble() ?? 0.0;
      _totalStock.value = (data['totalStock'] as num?)?.toInt() ?? 0;

      print("Total Cost: ${_totalCost.value}");
      print("Total Selling Price: ${_totalSellingPrice.value}");
      print("Total Stock: ${_totalStock.value}");
    } else {
      _totalCost.value = 0.0;
      _totalSellingPrice.value = 0.0;
      _totalStock.value = 0;
      showCustomToast('Failed to fetch inventory summary.');
      print("Failed to fetch inventory summary.");
    }
    isLoading.value = false;
    notifyListeners();
  }
}
