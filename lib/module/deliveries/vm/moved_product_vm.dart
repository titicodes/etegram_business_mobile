// import 'package:flutter/material.dart';
// import 'package:etegram_business/base/base_vm.dart';
// import 'package:etegram_business/core/model/delivery_response.dart';
// import 'package:etegram_business/core/model/product_model.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/repository/delivery_repository.dart';
// import 'package:etegram_business/repository/product_repository.dart';
// import 'package:etegram_business/routes/routes.dart';
// import 'package:etegram_business/service/local/user_service.dart';
// import 'package:etegram_business/utils/snack_message.dart';
// import 'package:etegram_business/app_widget/celebration_widget.dart';
//
// class MoveProductViewModel extends BaseViewModel {
//   final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);
//   final ValueNotifier<List<DeliveryTransactionData>> deliveryTransactions = ValueNotifier<List<DeliveryTransactionData>>([]);
//   final orderIdController = TextEditingController();
//   final quantityController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//   final CustomerService _customerService = locator<CustomerService>();
//   final ProductRepository _productRepository = locator<ProductRepository>();
//   final DeliveryRepository _deliveryRepository = locator<DeliveryRepository>();
//
//   String _storeId = '';
//   String suppliedTo = '';
//   String? selectedAgentId;
//   List<String> suppliedToSelection = ['Store', 'Warehouse'];
//   List<DeliveryData> deliveryAgents = [];
//   Product? selectedProduct;
//
//   List<String> get tabOptions => ['Supplied', 'Received'];
//
//   MoveProductViewModel() {
//     orderIdController.addListener(notifyListeners);
//     quantityController.addListener(notifyListeners);
//   }
//
//   Future<void> init() async {
//     final storeId = await _customerService.getActiveStoreId();
//     if (storeId == null) {
//       showCustomToast('Store information missing.', success: false);
//       print('Error: CustomerService.getActiveStoreId returned null');
//       return;
//     }
//     _storeId = storeId;
//     print('Initialized _storeId: $_storeId');
//     await _fetchDeliveryAgents();
//     await _fetchDeliveryTransactions();
//     notifyListeners();
//   }
//
//   Future<void> _fetchDeliveryAgents() async {
//     isLoading.value = true;
//     try {
//       final agents = await _deliveryRepository.getAllDeliveryAgents(storeId: _storeId);
//       deliveryAgents = agents ?? [];
//     } catch (e) {
//       print('Error fetching delivery agents: $e');
//       showCustomToast('Error fetching delivery agents.', success: false);
//     } finally {
//       isLoading.value = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> _fetchDeliveryTransactions() async {
//     isLoading.value = true;
//     try {
//       final transactions = await _deliveryRepository.getAllDeliveryTransactions(storeId: _storeId);
//       deliveryTransactions.value = transactions ?? [];
//     } catch (e) {
//       print('Error fetching delivery transactions: $e');
//       showCustomToast('Error fetching delivery transactions.', success: false);
//     } finally {
//       isLoading.value = false;
//       notifyListeners();
//     }
//   }
//
//   void onSuppliedToChanged(String value) {
//     suppliedTo = value;
//     notifyListeners();
//   }
//
//   void onAgentChanged(String agentId) {
//     selectedAgentId = agentId;
//     notifyListeners();
//   }
//
//   Future<void> scanBarcode(BuildContext context) async {
//     try {
//       isLoading.value = true;
//       notifyListeners();
//       print('Navigating to addProductScannerRoute');
//
//       final result = await Navigator.pushNamed(context, addProductScannerRoute);
//       final ownerId = await _customerService.getOwnerId();
//
//       if (result is Product) {
//         selectedProduct = result;
//         showCustomToast('Product found: ${result.name}', success: true);
//         print('Scanned product: ${result.name}');
//       } else if (result is String) {
//         showCustomToast('Product not found. Please add it.', success: false);
//         print('Scanned barcode (not found): $result');
//         if (ownerId != null) {
//           Navigator.pushNamed(
//             context,
//             addProductViewRoute,
//             arguments: {
//               'scannedCode': result,
//               'isEditing': false,
//               'storeId': _storeId,
//               'ownerId': ownerId,
//             },
//           );
//         } else {
//           showCustomToast('Owner information missing.', success: false);
//         }
//       } else {
//         showCustomToast('Product not found or scan cancelled.', success: false);
//       }
//     } catch (e) {
//       print('Error scanning barcode: $e');
//       showCustomToast('Error scanning barcode: $e', success: false);
//     } finally {
//       isLoading.value = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> submitDeliveryTransaction(BuildContext context) async {
//     if (!formKey.currentState!.validate() || isLoading.value || selectedProduct == null) {
//       showCustomToast('Please fill all fields and scan a product.', success: false);
//       return;
//     }
//
//     isLoading.value = true;
//     notifyListeners();
//
//     try {
//       final quantity = int.parse(quantityController.text.trim());
//       final orderId = orderIdController.text.trim();
//       final status = tabIndex.value == 0 ? 'DELIVERED' : 'RECEIVED';
//
//       if (status == 'DELIVERED' && (selectedProduct!.quantity ?? 0) < quantity) {
//         throw Exception('Insufficient stock for product: ${selectedProduct!.name}');
//       }
//
//       final transactionData = DeliveryTransactionData(
//         orderId: orderId,
//         storeId: _storeId,
//         supplierId: selectedAgentId,
//         items: [
//           {
//             'productCode': selectedProduct!.code,
//             'quantity': quantity,
//           }
//         ],
//         status: status,
//       );
//
//       final createdTransaction = await _deliveryRepository.createDeliveryTransaction(transactionData);
//       if (createdTransaction != null) {
//         deliveryTransactions.value = [...deliveryTransactions.value, createdTransaction];
//         showCustomToast('Delivery transaction recorded successfully!', success: true);
//         _resetForm();
//         navigationService.navigateToWidget(
//           CelebrationWidget(
//             title: 'Back to Dashboard',
//             onTap: () {
//               navigationService.navigateTo(dashboardRoute);
//             },
//             child: Text(
//               status == 'DELIVERED' ? 'Product Sent Successfully!' : 'Product Received Successfully!',
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           transitionBuilder: (context, animation, secondaryAnimation, child) {
//             return SlideTransition(
//               position: Tween<Offset>(
//                 begin: const Offset(1.0, 0.0),
//                 end: Offset.zero,
//               ).animate(animation),
//               child: child,
//             );
//           },
//         );
//       } else {
//         throw Exception('Failed to create delivery transaction.');
//       }
//     } catch (e) {
//       print('Error submitting delivery transaction: $e');
//       showCustomToast('Error submitting transaction: $e', success: false);
//     } finally {
//       isLoading.value = false;
//       notifyListeners();
//     }
//   }
//
//   void openDrawer() {
//     print('Open drawer called');
//   }
//
//   void _resetForm() {
//     orderIdController.clear();
//     quantityController.clear();
//     suppliedTo = '';
//     selectedAgentId = null;
//     selectedProduct = null;
//     formKey.currentState?.reset();
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     orderIdController.dispose();
//     quantityController.dispose();
//     tabIndex.dispose();
//     deliveryTransactions.dispose();
//     super.dispose();
//   }
//
//
// }

import 'package:flutter/material.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/core/model/delivery_response.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/core/model/product_history_model.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/repository/product_repository.dart';
import 'package:etegram_business/repository/delivery_repository.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/app_widget/celebration_widget.dart';
import 'package:etegram_business/routes/routes.dart';

class MoveProductViewModel extends BaseViewModel {
  final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);
  final ValueNotifier<List<ProductHistory>> productHistory =
      ValueNotifier<List<ProductHistory>>([]);
  final productCodeController = TextEditingController();
  final quantityController = TextEditingController();
  final notesController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final CustomerService _customerService = locator<CustomerService>();
  final ProductRepository _productRepository = locator<ProductRepository>();
  final DeliveryRepository _deliveryRepository = locator<DeliveryRepository>();

  String _storeId = '';
  String suppliedTo = '';
  String? selectedAgentId;
  List<String> suppliedToSelection = ['Store', 'Warehouse'];
  List<DeliveryData> deliveryAgents = [];
  Product? selectedProduct;

  List<String> get tabOptions => ['Supplied', 'Received'];

  MoveProductViewModel() {
    productCodeController.addListener(notifyListeners);
    quantityController.addListener(notifyListeners);
    notesController.addListener(notifyListeners);
  }

  Future<void> init() async {
    final storeId = await _customerService.getActiveStoreId();
    if (storeId == null) {
      showCustomToast('Store information missing.', success: false);
      print('Error: CustomerService.getActiveStoreId returned null');
      return;
    }
    _storeId = storeId;
    print('Initialized _storeId: $_storeId');
    await _fetchDeliveryAgents();
    await _fetchProductHistory();
    notifyListeners();
  }

  Future<void> _fetchDeliveryAgents() async {
    isLoading.value = true;
    try {
      final agents =
          await _deliveryRepository.getAllDeliveryAgents(storeId: _storeId);
      deliveryAgents = agents ?? [];
    } catch (e) {
      print('Error fetching delivery agents: $e');
      showCustomToast('Error fetching delivery agents.', success: false);
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future<void> _fetchProductHistory() async {
    isLoading.value = true;
    try {
      // Fetch history for the store, not a specific product
      final response = await _productRepository.getProductHistory(
        productId: '', // Empty to fetch all history for the store
        storeId: _storeId,
        page: 1,
        limit: 50,
      );
      productHistory.value = response;
    } catch (e) {
      print('Error fetching product history: $e');
      showCustomToast('Error fetching product history.', success: false);
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  void onSuppliedToChanged(String value) {
    suppliedTo = value;
    notifyListeners();
  }

  void onAgentChanged(String agentId) {
    selectedAgentId = agentId;
    notifyListeners();
  }

  Future<void> scanBarcode(BuildContext context) async {
    try {
      isLoading.value = true;
      notifyListeners();
      print('Navigating to addProductScannerRoute');

      final result = await Navigator.pushNamed(context, addProductScannerRoute);
      final ownerId = await _customerService.getOwnerId();

      if (result is Product) {
        selectedProduct = result;
        productCodeController.text = result.code ?? '';
        showCustomToast('Product found: ${result.name}', success: true);
        print('Scanned product: ${result.name}');
      } else if (result is String) {
        showCustomToast('Product not found. Please add it.', success: false);
        print('Scanned barcode (not found): $result');
        if (ownerId != null) {
          Navigator.pushNamed(
            context,
            addProductViewRoute,
            arguments: {
              'scannedCode': result,
              'isEditing': false,
              'storeId': _storeId,
              'ownerId': ownerId,
            },
          );
        } else {
          showCustomToast('Owner information missing.', success: false);
        }
      } else {
        showCustomToast('Product not found or scan cancelled.', success: false);
      }
    } catch (e) {
      print('Error scanning barcode: $e');
      showCustomToast('Error scanning barcode: $e', success: false);
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future<void> submitMovement(BuildContext context) async {
    if (!formKey.currentState!.validate() ||
        isLoading.value ||
        selectedProduct == null) {
      showCustomToast('Please fill all fields and scan a product.',
          success: false);
      return;
    }

    isLoading.value = true;
    notifyListeners();

    try {
      final quantity = int.parse(quantityController.text.trim());
      final isSentOut = tabIndex.value == 0;

      if (isSentOut && (selectedProduct!.quantity ?? 0) < quantity) {
        throw Exception(
            'Insufficient stock for product: ${selectedProduct!.name}');
      }

      final updatedProduct = await _productRepository.moveProduct(
        productCode: selectedProduct?.code ?? '',
        quantity: quantity,
        storeId: _storeId,
        isSentOut: isSentOut,
        deliveryAgentId: selectedAgentId,
        notes: notesController.text.isNotEmpty
            ? notesController.text.trim()
            : null,
      );

      if (updatedProduct != null) {
        await _fetchProductHistory(); // Refresh history
        showCustomToast(
          isSentOut
              ? 'Product sent out successfully!'
              : 'Product received successfully!',
          success: true,
        );
        _resetForm();
        navigationService.navigateToWidget(
          CelebrationWidget(
            title: 'Back to Dashboard',
            onTap: () {
              navigationService.navigateTo(dashboardRoute);
            },
            child: Text(
              isSentOut
                  ? 'Product Sent Successfully!'
                  : 'Product Received Successfully!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        throw Exception('Failed to record product movement.');
      }
    } catch (e) {
      print('Error submitting product movement: $e');
      showCustomToast('Error submitting transaction: $e', success: false);
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  void openDrawer() {
    print('Open drawer called');
  }

  void _resetForm() {
    productCodeController.clear();
    quantityController.clear();
    notesController.clear();
    suppliedTo = '';
    selectedAgentId = null;
    selectedProduct = null;
    formKey.currentState?.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    productCodeController.dispose();
    quantityController.dispose();
    notesController.dispose();
    tabIndex.dispose();
    productHistory.dispose();
    super.dispose();
  }
}

// class ProductHistory {
//   final String id;
//   final String type;
//   final int quantity;
//   final String productId;
//   final String storeId;
//   final String userId;
//   final String? deliveryAgentId;
//   final String? notes;
//   final DateTime createdAt;
//
//   ProductHistory({
//     required this.id,
//     required this.type,
//     required this.quantity,
//     required this.productId,
//     required this.storeId,
//     required this.userId,
//     this.deliveryAgentId,
//     this.notes,
//     required this.createdAt,
//   });
//
//   factory ProductHistory.fromJson(Map<String, dynamic> json) {
//     return ProductHistory(
//       id: json['_id'],
//       type: json['type'],
//       quantity: json['quantity'],
//       productId: json['product'],
//       storeId: json['store'],
//       userId: json['userId'],
//       deliveryAgentId: json['deliveryAgentId'],
//       notes: json['notes'],
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }
// }
