import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/get_search_response.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../constants/strings.dart';
import '../../../core/model/product_model.dart';
import '../../../core/model/supply_response.dart';
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
  List<Product> get  allProducts => _products;
  List<Product> get expiringProducts => _expiringProducts;
  List<Product> get lowStockProducts => _lowStockProducts;

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
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  AddProductResponse? get addProductResponse => _addProductResponse;

  ProductViewModel({this.tabController});

  int _currentPage = 1;
  int _currentIndex = 0;

  Future<void> initialize() async {
    await fetchAllProducts();
    await fetchExpiringProducts();
    await fetchLowStockProducts();
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

    SearchProductResponse? fetchedProducts =
        await productRepository.getProducts(page: _currentPage);

    if (fetchedProducts != null && fetchedProducts.data != null) {
      List<Product> newProducts = (fetchedProducts.data!.data as List)
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

  Future<void> fetchExpiringProducts() async {
    _isLoading = true;
    notifyListeners();

    // Fetch expiring products with page and limit
    var result = await productRepository.fetchExpiringProducts(_currentExpiringPage, _limit);

    if (result != null) {
      var fetchedProducts = result['data'];
      if (fetchedProducts != null && fetchedProducts is List) {
        _expiringProducts = fetchedProducts.cast<Product>();
      } else {
        _expiringProducts = [];
      }

      // You can also handle pagination metadata if needed, such as total pages
      var metadata = result['metadata'];
      if (metadata != null) {
        // You can use metadata to handle page navigation or other actions
        print("Total Pages for Expiring Products: ${metadata['totalPages']}");
      }
    } else {
      _expiringProducts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllProducts() async {
    _isLoading = true;
    notifyListeners();

    // Fetch the products from the repository
    var response = await productRepository.getProducts();

    // Ensure response is not null and contains products
    allProduct = (response?.data ?? []) as SearchProductResponse?; // Get the products from the response

    _isLoading = false;
    notifyListeners();
  }


  Future<void> fetchLowStockProducts() async {
    _isLoading = true;
    notifyListeners();

    // Fetch low stock products with page and limit
    var result = await productRepository.fetchLowStockProducts(_currentLowStockPage, _limit);

    if (result != null) {
      var fetchedProducts = result['data'];
      if (fetchedProducts != null && fetchedProducts is List) {
        _lowStockProducts = fetchedProducts.cast<Product>();
      } else {
        _lowStockProducts = [];
      }

      // Handle pagination metadata if necessary
      var metadata = result['metadata'];
      if (metadata != null) {
        // You can use metadata for pagination or other handling
        print("Total Pages for Low Stock Products: ${metadata['totalPages']}");
      }
    } else {
      _lowStockProducts = [];
    }

    _isLoading = false;
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

  void updateProductName(String value) {
    productName = value;
    notifyListeners();
  }

  void updateProductSize(String value) {
    productSize = value;
    notifyListeners();
  }

  void updateProductFilter(String? value) {
    productFilter = value ?? '';
    notifyListeners();
  }

  void updateCostPrice(int value) {
    costPrice += value;
    notifyListeners();
  }

  void updateUnitPrice(int value) {
    unitPrice += value;
    notifyListeners();
  }

  void updateQuantity(int value) {
    quantity += value;
    notifyListeners();
  }

  void updateMinQuantity(int value) {
    minQuantity += value;
    notifyListeners();
  }

  void addProduct(Product product) {
    final product = Product(
      name: productName,
      size: productSize,
      price: unitPrice.toInt(),
      quantity: quantity,
    );
    _products.add(product);
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

  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    bool isDeleted = await productRepository.deleteProduct(productId);

    if (isDeleted) {
      _products.removeWhere((product) => product.id == productId);
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProduct(String productId, Product updatedProduct) async {
    _isLoading = true;
    notifyListeners();

    Product? updatedProductResponse =
        await productRepository.updateProduct(productId, updatedProduct);

    if (updatedProductResponse != null) {
      int index = _products.indexWhere((product) => product.id == productId);
      if (index != -1) {
        _products[index] = updatedProductResponse;
        notifyListeners();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _showScannerDialog(BuildContext context) async {
    String? barcodeScanResult;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Scan Barcode"),
        content: SizedBox(
          height: height(context) * .7,
          width: width(context),
          child: MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              if (barcode.rawValue != null) {
                barcodeScanResult = barcode.rawValue!;
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );

    if (barcodeScanResult != null) {
      startLoader();
      //await searchProduct(barcodeScanResult!);
      stopLoader();

      if (selectedProduct != null) {
        Future.delayed(Duration.zero, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductView(
                product: convertSearchDataToProduct(selectedProduct!),
                isEditing: true,
              ),
            ),
          );
        });
      } else {
        Future.delayed(Duration.zero, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductView(
                scannedCode: barcodeScanResult,
                isEditing: false,
              ),
            ),
          );
        });
      }
    }
  }

  void _showQuickTips(BuildContext context, Function onScanConfirmed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quick Tips'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Tap to search", textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text("Tap to pause", textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text("Tap to scan", textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Don't show this again"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (!disposed) {
                  onScanConfirmed();
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }


  void addOrUpdateProduct(Product product) {
    if (selectedProduct != null && selectedProduct!.id == product.id) {
      updateProduct(product.id ?? "", product);
    } else {
      addProduct(product);
    }
    updateProductLists();
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

  /// 🔄 **Convert `SearchData` to `Product`**
  Product convertSearchDataToProduct(ProductData data) {
    return Product(
      id: data.id,
      name: data.name ?? "Unknown Product",
      size: data.size ?? "N/A", // Assuming size is in SearchData
      expiryDate: null,
      price: data.price?.toInt(),
      code: data.code,
      unitPrice: data.unitPrice?.toInt(),
    );
  }

  /// 📝 **Save scanned product to database**
  Future<AddProductResponse?> saveScannedProduct(
      Product product, String scannedCode) async {
    try {
      startLoader();
      final response = await productRepository.scanAndAddProduct(
          data: product, scannedCode: scannedCode);
      stopLoader();
      return response;
    } catch (e) {
      print("Error in scanAndAddProduct: $e");
      stopLoader();
      return null;
    }
  }

  Future<void> scanBarcode(BuildContext context) async {
    await _checkCameraPermission(context);
  }

  Future<void> _checkCameraPermission(BuildContext context) async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      if (await Permission.camera.request().isGranted) {
        _showQuickTips(context, () async {
          await _showScannerDialog(context);
        });
      } else {
        showCustomToast('Camera permission is required to scan barcodes.');
      }
    } else if (status.isPermanentlyDenied) {
      showCustomToast(
          'Camera permission is permanently denied. Please enable it in app settings.');
      openAppSettings();
    } else if (status.isGranted) {
      _showQuickTips(context, () async {
        await _showScannerDialog(context);
      });
    } else {
      showCustomToast('Could not access camera.');
    }
  }
}
