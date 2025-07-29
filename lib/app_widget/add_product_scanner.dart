// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/service/local/user_service.dart';
// import 'package:etegram_business/utils/snack_message.dart';
// import 'package:etegram_business/app_widget/scanner_control_bar.dart';
// import 'package:etegram_business/core/model/product_model.dart';
// import 'package:etegram_business/routes/routes.dart';
// import 'dart:io';
//
// import '../base/base_ui.dart';
// import '../module/product/vm/product_viewmodel.dart';
//
// class AddProductScannerView extends StatefulWidget {
//   const AddProductScannerView({super.key});
//
//   @override
//   State<AddProductScannerView> createState() => _AddProductScannerViewState();
// }
//
// class _AddProductScannerViewState extends State<AddProductScannerView>
//     with WidgetsBindingObserver {
//   final Set<String> _scannedBarcodes = {};
//   final CustomerService _customerService = locator<CustomerService>();
//   bool _isProcessing = false;
//   bool _isScannerPaused = false;
//   MobileScannerController? _scannerController;
//   bool _isStarting = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initializeController();
//     print('AddProductScannerView: Initialized');
//   }
//
//   void _initializeController() {
//     _scannerController = MobileScannerController(
//       facing: CameraFacing.back,
//       detectionSpeed: DetectionSpeed.normal,
//       detectionTimeoutMs: 1000,
//       formats: [
//         BarcodeFormat.ean13,
//         BarcodeFormat.ean8,
//         BarcodeFormat.upcA,
//         BarcodeFormat.upcE
//       ],
//     );
//     _startScanner();
//   }
//
//   Future<void> _startScanner() async {
//     if (_isStarting || _scannerController == null) return;
//     setState(() => _isStarting = true);
//     try {
//       await _scannerController!.start();
//       print('AddProductScannerView: Scanner started');
//     } catch (e, stackTrace) {
//       print('AddProductScannerView: Error starting scanner: $e\n$stackTrace');
//       showCustomToast('Error starting scanner: $e', success: false);
//     } finally {
//       if (mounted) {
//         setState(() => _isStarting = false);
//       }
//     }
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       print('AddProductScannerView: App resumed, restarting scanner');
//       if (_scannerController != null && !_isScannerPaused && !_isProcessing) {
//         _startScanner();
//       }
//     } else if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.inactive) {
//       print('AddProductScannerView: App paused, stopping scanner');
//       _scannerController?.stop();
//     }
//   }
//
//   @override
//   void dispose() {
//     print('AddProductScannerView: Disposing');
//     WidgetsBinding.instance.removeObserver(this);
//     _scannerController?.dispose();
//     _scannerController = null;
//     super.dispose();
//   }
//
//   Future<String?> _getStoreId() async {
//     final storeId = await _customerService.getActiveStoreId();
//     if (storeId == null) {
//       showCustomToast('Store information missing.', success: false);
//       print(
//           'AddProductScannerView: CustomerService.getActiveStoreId returned null');
//       Navigator.pushReplacementNamed(context, createStoreRoute);
//       return null;
//     }
//     print('AddProductScannerView: Fetched storeId: $storeId');
//     return storeId;
//   }
//
//   Future<String?> _getOwnerId() async {
//     final ownerId = await _customerService.getOwnerId();
//     if (ownerId == null) {
//       showCustomToast('Owner information missing.', success: false);
//       print('AddProductScannerView: CustomerService.getOwnerId returned null');
//       return null;
//     }
//     print('AddProductScannerView: Fetched ownerId: $ownerId');
//     return ownerId;
//   }
//
//   void _handleScan(BarcodeCapture capture, ProductViewModel model) async {
//     if (_isProcessing || _isScannerPaused || capture.barcodes.isEmpty) return;
//
//     final barcodeValue = capture.barcodes.first.rawValue;
//     if (barcodeValue == null ||
//         barcodeValue.isEmpty ||
//         _scannedBarcodes.contains(barcodeValue)) {
//       print(
//           'AddProductScannerView: Invalid or duplicate barcode: $barcodeValue');
//       return;
//     }
//
//     if (!_isValidBarcode(barcodeValue)) {
//       print('AddProductScannerView: Invalid barcode format: $barcodeValue');
//       showCustomToast('Invalid barcode format. Please scan a valid barcode.',
//           success: false);
//       return;
//     }
//
//     _scannedBarcodes.add(barcodeValue);
//     setState(() => _isProcessing = true);
//     if (_scannerController != null) {
//       await _scannerController!.stop();
//       print('AddProductScannerView: Scanner stopped for processing');
//     }
//
//     try {
//       final storeId = await _getStoreId();
//       final ownerId = await _getOwnerId();
//       if (!mounted) return;
//       if (storeId == null || ownerId == null) {
//         _scannedBarcodes.remove(barcodeValue);
//         setState(() => _isProcessing = false);
//         await _startScanner();
//         return;
//       }
//
//       // Check if product already exists
//       print(
//           'AddProductScannerView: Checking product existence for barcode: $barcodeValue');
//       final product = await model.checkProductExistence(barcodeValue, context);
//       if (!mounted) return;
//
//       if (product != null) {
//         print(
//             'AddProductScannerView: Found product: ${product.name}, code: ${product.code}');
//         setState(() => _isScannerPaused = true);
//         await model.showDuplicateDialog(context, product, fromSave: false);
//         _scannedBarcodes.remove(barcodeValue);
//         setState(() {
//           _isProcessing = false;
//           _isScannerPaused = false;
//         });
//         await _startScanner();
//         return;
//       }
//
//       print(
//           'AddProductScannerView: No existing product found for barcode: $barcodeValue');
//       await model.fetchProductDetailsFromAPI(barcodeValue);
//       if (!mounted) return;
//
//       // Proceed to AddProductView if no duplicate is found
//       final Map<String, dynamic> arguments = {
//         'scannedCode': barcodeValue,
//         'isEditing': false,
//         'storeId': storeId,
//         'ownerId': ownerId,
//         'externalProduct': Product(
//           name: model.nameController.text,
//           code: barcodeValue,
//           category: model.categoryController.text,
//           brands: model.brandsController.text,
//           size: model.sizeController.text,
//           description: model.descriptionController.text,
//           imageUrl: model.productImageUrl,
//         ),
//         'needsImageSelection':
//             (model.productImageUrl == null || model.productImageUrl!.isEmpty),
//       };
//
//       print(
//           'AddProductScannerView: Navigating to AddProductView with arguments: $arguments');
//       await Navigator.pushNamed(context, addProductViewRoute,
//           arguments: arguments);
//       _scannedBarcodes.remove(barcodeValue);
//       setState(() => _isProcessing = false);
//       await _startScanner();
//     } catch (e, stackTrace) {
//       showCustomToast('Error scanning product: $e', success: false);
//       print('AddProductScannerView: Error scanning product: $e\n$stackTrace');
//       _scannedBarcodes.remove(barcodeValue);
//       setState(() => _isProcessing = false);
//       await _startScanner();
//     }
//   }
//
//   bool _isValidBarcode(String barcode) {
//     final regex = RegExp(r'^\d{8,13}$');
//     return regex.hasMatch(barcode);
//   }
//
//   Widget _buildOverlay() {
//     return Align(
//       alignment: Alignment.center,
//       child: Container(
//         width: 250,
//         height: 250,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.white, width: 2),
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseView<ProductViewModel>(
//       onModelReady: (model) => model.init(),
//       builder: (context, model, child) => WillPopScope(
//         onWillPop: () async {
//           print('AddProductScannerView: WillPopScope triggered');
//           if (_scannerController != null) {
//             await _scannerController!.stop();
//           }
//           return true;
//         },
//         child: Scaffold(
//           appBar: AppBar(title: const Text("Scan Product")),
//           body: Stack(
//             children: [
//               MobileScanner(
//                 controller: _scannerController,
//                 onDetect: (capture) => _handleScan(capture, model),
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, child) {
//                   return Center(child: Text('Camera error: $error'));
//                 },
//               ),
//               Column(
//                 children: [
//                   Expanded(child: _buildOverlay()),
//                   const SizedBox(height: 16),
//                   if (!_isProcessing &&
//                       !model.isFetchingExternalData.value &&
//                       _scannerController != null)
//                     ScannerControlBar(scannerController: _scannerController!),
//                 ],
//               ),
//               if (_isProcessing || model.isFetchingExternalData.value)
//                 Container(
//                   color: Colors.black.withOpacity(0.3),
//                   child: Center(
//                     child: SpinKitWave(
//                       size: 50.0,
//                       color: ColorValues.primaryColor,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/app_widget/scanner_control_bar.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/routes/routes.dart';
import '../base/base_ui.dart';
import '../module/product/vm/product_viewmodel.dart';

class AddProductScannerView extends StatefulWidget {
  const AddProductScannerView({super.key});

  @override
  State<AddProductScannerView> createState() => _AddProductScannerViewState();
}

class _AddProductScannerViewState extends State<AddProductScannerView>
    with WidgetsBindingObserver, RouteAware {
  final Set<String> _scannedBarcodes = {};
  final CustomerService _customerService = locator<CustomerService>();
  bool _isProcessing = false;
  bool _isDisposed = false;
  bool _shouldResumeOnReturn = false;
  MobileScannerController? _scannerController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
    print('AddProductScannerView: Initialized');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanner();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register route observer to detect when returning from other screens
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      // This helps detect when we return to this screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_shouldResumeOnReturn && !_isProcessing && !_isDisposed) {
          print('AddProductScannerView: Resuming scanner after return');
          _shouldResumeOnReturn = false;
          _restartScanner();
        }
      });
    }
  }

  void _initializeController() {
    if (_isDisposed) return;

    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 1000,
      formats: [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
      autoStart: false,
    );
  }

  Future<void> _startScanner() async {
    if (_scannerController == null ||
        _isProcessing ||
        _isDisposed ||
        !mounted) {
      return;
    }

    try {
      await _scannerController!.start();
      print('AddProductScannerView: Scanner started successfully');
    } catch (e, stackTrace) {
      print('AddProductScannerView: Error starting scanner: $e\n$stackTrace');
      if (mounted && !_isDisposed) {
        showCustomToast('Error starting scanner. Please try again.',
            success: false);
        // Retry after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && !_isDisposed) {
          _retryStartScanner();
        }
      }
    }
  }

  Future<void> _retryStartScanner() async {
    if (_isDisposed || !mounted) return;

    try {
      await _scannerController!.start();
      print('AddProductScannerView: Scanner retry successful');
    } catch (retryError) {
      print('AddProductScannerView: Retry failed: $retryError');
      if (mounted && !_isDisposed) {
        showCustomToast('Scanner initialization failed', success: false);
      }
    }
  }

  Future<void> _stopScanner() async {
    if (_scannerController == null || _isDisposed) return;

    try {
      await _scannerController!.stop();
      print('AddProductScannerView: Scanner stopped');
    } catch (e) {
      print('AddProductScannerView: Error stopping scanner: $e');
    }
  }

  Future<void> _restartScanner() async {
    if (_isDisposed || !mounted) return;

    print('AddProductScannerView: Restarting scanner...');
    await _stopScanner();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted && !_isDisposed) {
      await _startScanner();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_isDisposed) return;

    switch (state) {
      case AppLifecycleState.resumed:
        print('AddProductScannerView: App resumed');
        if (!_isProcessing) {
          if (_shouldResumeOnReturn) {
            _shouldResumeOnReturn = false;
            _restartScanner();
          } else {
            _startScanner();
          }
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        print('AddProductScannerView: App paused/inactive, stopping scanner');
        _stopScanner();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    print('AddProductScannerView: Disposing');
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _scannerController?.stop();
    _scannerController?.dispose();
    _scannerController = null;
    _scannedBarcodes.clear();
    super.dispose();
  }

  Future<String?> _getStoreId() async {
    final storeId = await _customerService.getActiveStoreId();
    if (storeId == null) {
      showCustomToast('Store information missing. Please create a store.',
          success: false);
      print(
          'AddProductScannerView: CustomerService.getActiveStoreId returned null');
      await Navigator.pushReplacementNamed(context, createStoreRoute);
      return null;
    }
    print('AddProductScannerView: Fetched storeId: $storeId');
    return storeId;
  }

  Future<String?> _getOwnerId() async {
    final ownerId = await _customerService.getOwnerId();
    if (ownerId == null) {
      showCustomToast('Owner information missing.', success: false);
      print('AddProductScannerView: CustomerService.getOwnerId returned null');
      return null;
    }
    print('AddProductScannerView: Fetched ownerId: $ownerId');
    return ownerId;
  }

  void _handleScan(BarcodeCapture capture, ProductViewModel model) async {
    if (_isProcessing || capture.barcodes.isEmpty || _isDisposed) return;

    final barcodeValue = capture.barcodes.first.rawValue;
    if (barcodeValue == null || barcodeValue.isEmpty) {
      print('AddProductScannerView: Invalid or empty barcode');
      return;
    }

    // Enhanced debounce mechanism
    if (_scannedBarcodes.contains(barcodeValue)) {
      print(
          'AddProductScannerView: Debouncing duplicate barcode: $barcodeValue');
      return;
    }

    // Cancel existing debounce timer
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 2000), () {
      _scannedBarcodes.remove(barcodeValue);
    });

    if (!_isValidBarcode(barcodeValue)) {
      print('AddProductScannerView: Invalid barcode format: $barcodeValue');
      showCustomToast('Invalid barcode format. Please scan a valid barcode.',
          success: false);
      return;
    }

    _scannedBarcodes.add(barcodeValue);
    setState(() => _isProcessing = true);
    await _stopScanner();
    print('AddProductScannerView: Scanner stopped for processing');

    try {
      final storeId = await _getStoreId();
      final ownerId = await _getOwnerId();
      if (!mounted || storeId == null || ownerId == null || _isDisposed) {
        _scannedBarcodes.remove(barcodeValue);
        if (mounted && !_isDisposed) {
          setState(() => _isProcessing = false);
          await _restartScanner();
        }
        return;
      }

      // Check if product already exists
      print(
          'AddProductScannerView: Checking product existence for barcode: $barcodeValue');
      final exists = await model.checkProductExistence(barcodeValue, context);
      if (!mounted || _isDisposed) return;

      if (exists) {
        print(
            'AddProductScannerView: Product exists for barcode: $barcodeValue');
        await _showProductExistsDialog(barcodeValue);
        _scannedBarcodes.remove(barcodeValue);
        if (mounted && !_isDisposed) {
          setState(() => _isProcessing = false);
          await _restartScanner();
        }
        return;
      }

      print(
          'AddProductScannerView: No existing product found for barcode: $barcodeValue');
      // Fetch product details silently
      await model.fetchProductDetailsFromAPI(barcodeValue, silent: true);
      if (!mounted || _isDisposed) return;

      // Navigate to AddProductView
      await _navigateToAddProduct(barcodeValue, storeId, ownerId, model);
    } catch (e, stackTrace) {
      showCustomToast('Error scanning product. Please try again.',
          success: false);
      print('AddProductScannerView: Error scanning product: $e\n$stackTrace');
    } finally {
      _scannedBarcodes.remove(barcodeValue);
      if (mounted && !_isDisposed) {
        setState(() => _isProcessing = false);
        // Don't restart scanner here as we're navigating away
      }
    }
  }

  Future<void> _showProductExistsDialog(String barcodeValue) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Product Already Exists'),
        content: Text(
            'A product with barcode "$barcodeValue" is already in the database.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Scan Another'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, mainNavViewRoute);
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddProduct(String barcodeValue, String storeId,
      String ownerId, ProductViewModel model) async {
    final Map<String, dynamic> arguments = {
      'scannedCode': barcodeValue,
      'isEditing': false,
      'storeId': storeId,
      'ownerId': ownerId,
      'externalProduct': Product(
        name: model.nameController.text,
        code: barcodeValue,
        category: model.categoryController.text,
        brands: model.brandsController.text,
        size: model.sizeController.text,
        description: model.descriptionController.text,
        imageUrl: model.productImageUrl,
      ),
      'needsImageSelection': false,
    };

    print(
        'AddProductScannerView: Navigating to AddProductView with arguments: $arguments');
    _shouldResumeOnReturn = true;

    final result = await Navigator.pushNamed(context, addProductViewRoute,
        arguments: arguments);

    // Handle return from AddProductView
    if (mounted && !_isDisposed) {
      print(
          'AddProductScannerView: Returned from AddProductView with result: $result');
      setState(() => _isProcessing = false);

      // Small delay to ensure the screen is fully visible
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted && !_isDisposed) {
        await _restartScanner();
      }
    }
  }

  bool _isValidBarcode(String barcode) {
    final regex = RegExp(r'^\d{6,13}$');
    return regex.hasMatch(barcode);
  }

  Widget _buildOverlay() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Position barcode here',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<ProductViewModel>(
      onModelReady: (model) => model.init(),
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          print('AddProductScannerView: WillPopScope triggered');
          await _stopScanner();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Scan Product"),
            backgroundColor: ColorValues.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: Stack(
            children: [
              if (_scannerController != null && !_isDisposed)
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) => _handleScan(capture, model),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, child) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Camera error: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await _restartScanner();
                            },
                            child: const Text('Retry Camera'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              Column(
                children: [
                  Expanded(child: _buildOverlay()),
                  const SizedBox(height: 16),
                  if (!_isProcessing &&
                      !model.isFetchingExternalData.value &&
                      _scannerController != null &&
                      !_isDisposed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: ScannerControlBar(
                          scannerController: _scannerController!),
                    ),
                ],
              ),
              if (_isProcessing || model.isFetchingExternalData.value)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitWave(
                          size: 50.0,
                          color: ColorValues.primaryColor,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Processing barcode...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
