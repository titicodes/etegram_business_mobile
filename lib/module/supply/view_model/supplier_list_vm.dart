import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/core/model/supply_response.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/model/get_search_response.dart';
import '../../../core/model/product_model.dart';
import '../../../core/model/supplier.dart';
import '../../../utils/widget_extension.dart';
import '../../product/view/add_product.dart';

enum SupplierSortOption { nameAsc, nameDesc, recent }

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
  List<SupplyResponse> _filteredSuppliers = [];

  List<SupplyResponse> get filteredSuppliers => _filteredSuppliers;
  bool _isLoading = false;
  List<String> availableStates = [];
  String _searchKeyword = '';
  String? _selectedState;
  SupplierSortOption _selectedSort = SupplierSortOption.recent;

  String get selectedLocation => _selectedState ?? 'All';
  SupplierSortOption get selectedSort => _selectedSort;

  Future<void> loadSuppliers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final suppliers = await supplyRepository.getAllSuppliers();
      _suppliers = suppliers ?? [];

      // Collect available states
      availableStates = _suppliers
          .map((e) => e.data?.state ?? '')
          .where((state) => state.isNotEmpty)
          .toSet()
          .toList();

      _applyFilters();
    } catch (e) {
      print("Error loading suppliers: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchSuppliers(String keyword) {
    _searchKeyword = keyword.toLowerCase();
    _applyFilters();
  }

  void filterByState(String? state) {
    _selectedState = state == 'All' ? null : state;
    _applyFilters();
  }

  void sortSuppliers(SupplierSortOption sortOption) {
    _selectedSort = sortOption;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredSuppliers = _suppliers.where((supplier) {
      final data = supplier.data;
      final name = data?.businessName?.toLowerCase() ?? '';
      final email = data?.email?.toLowerCase() ?? '';
      final state = data?.state ?? '';

      final matchesSearch = name.contains(_searchKeyword) || email.contains(_searchKeyword);
      final matchesState = _selectedState == null || state == _selectedState;

      return matchesSearch && matchesState;
    }).toList();

    switch (_selectedSort) {
      case SupplierSortOption.nameAsc:
        _filteredSuppliers.sort((a, b) =>
            (a.data?.businessName ?? '').compareTo(b.data?.businessName ?? ''));
        break;
      case SupplierSortOption.nameDesc:
        _filteredSuppliers.sort((a, b) =>
            (b.data?.businessName ?? '').compareTo(a.data?.businessName ?? ''));
        break;
      case SupplierSortOption.recent:
        _filteredSuppliers.sort((a, b) =>
            (b.data?.createdAt ?? DateTime.now()).compareTo(a.data?.createdAt ?? DateTime.now()));
        break;
    }

    notifyListeners();
  }

  // void searchSuppliers(String keyword) {
  //   _searchKeyword = keyword.toLowerCase();
  //   _filteredSuppliers = _suppliers.where((supplier) {
  //     final name = supplier.data?.businessName?.toLowerCase() ?? '';
  //     final email = supplier.data?.email?.toLowerCase() ?? '';
  //     return name.contains(_searchKeyword) || email.contains(_searchKeyword);
  //   }).toList();
  //   notifyListeners();
  // }

  Future<void> searchProducts(String query) async {
    isSearching = true;
    notifyListeners();
    try {
      final response = await productRepository.getFilteredProducts(query);
      if (response != null && response.data != null) {
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
                Navigator.pop(context);
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
