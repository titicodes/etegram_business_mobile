import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/core/model/supply_response.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/model/get_search_response.dart';
import '../../../core/model/product_model.dart';
import '../../../core/model/supplier.dart';
import '../../../utils/widget_extension.dart';
import '../../product/view/add_product.dart';

class SupplierListViewModel extends BaseViewModel {
  List<SupplyResponse> _suppliers = [];
  List<SupplyResponse> get suppliers => _suppliers;
  List<Product> searchedProducts = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  AddProductResponse? addProductResponse;
  SearchProductResponse? searchProductResponse;
  List<Product> products = [];
  ProductData? selectedProduct;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchKeyword = '';

  Future<void> loadSuppliers() async {
    _isLoading = true;
    notifyListeners();
    try {
      List<SupplyResponse>? suppliers =
          await supplyRepository.getAllSuppliers();
      if (suppliers != null) {
        _suppliers = suppliers;
      } else {
        _suppliers = [];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Error loading suppliers: $e");
    }
  }

  void searchSuppliers(String keyword) {
    _searchKeyword = keyword.toLowerCase();
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    isSearching = true;
    notifyListeners();
    try {
      final response = await productRepository.getFilteredProducts(query);
      if (response != null && response.data != null) {
        // Convert List<SearchData> to List<Product>
        searchedProducts = response.data!.data.map((searchData) {
          return Product(
            id: searchData.id,
            name: searchData.name ?? "Unknown Product",
            size: searchData.size ?? "N/A",
            expiryDate: searchData.expiryDate?.isNotEmpty == true
                ? searchData.expiryDate
                : null,
            price: searchData.price?.toInt(),
            code: searchData.code,
            quantity: searchData.quantity,
            categoryId: searchData.categoryId != null
                ? Category.fromJson(
                    searchData.categoryId as Map<String, dynamic>)
                : null,
            stock: searchData.stock,
            createdAt: searchData.createdAt,
            updatedAt: searchData.updatedAt,
            v: searchData.v,
          );
        }).toList();
      } else {
        searchedProducts = [];
      }
    } catch (e) {
      print("Error searching products: $e");
      searchedProducts = [];
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<AddProductResponse?> scanAndAddProduct(
      {required Product data, required String scannedCode}) async {
    try {
      startLoader();
      addProductResponse = await productRepository.scanAndAddProduct(
          data: data, scannedCode: scannedCode);

      if (addProductResponse?.success == true &&
          addProductResponse?.data != null) {
        products.add(addProductResponse!.data!);
      }
    } catch (e) {
      print("Error in scanAndAddProduct: $e");
    } finally {
      stopLoader();
    }
    return addProductResponse;
  }

  /// 📷 Scan a barcode and navigate to `AddProductView`
  Future<void> scanBarcode(BuildContext context) async {
    String? barcodeScanResult;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Scan Barcode"),
        content: Container(
          height: height(context) * .7,
          width: width(context),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
          child: MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              if (barcode.rawValue != null) {
                barcodeScanResult = barcode.rawValue!;
                Navigator.pop(context); // Close scanner after scanning
              }
            },
          ),
        ),
      ),
    );

    if (barcodeScanResult != null) {
      await searchProducts(barcodeScanResult!);

      if (selectedProduct != null && context.mounted) {
        Product convertedProduct = convertSearchDataToProduct(selectedProduct!);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddProductView(
              product: convertedProduct,
              isEditing: true,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddProductView(isEditing: false),
          ),
        );
      }
    }
  }

  /// 🔄 Convert `SearchData` to `Product`
  Product convertSearchDataToProduct(ProductData data) {
    return Product(
      id: data.id,
      name: data.name ?? "Unknown Product",
      size: "N/A",
      expiryDate: null,
      price: data.price?.toInt(),
    );
  }
}
