// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../module/product/view/add_product.dart';
// import '../utils/snack_message.dart';
// import '../module/product/vm/product_viewmodel.dart';
// import 'package:etegram_business/app_widget/scanner_control_bar.dart';
// import 'package:etegram_business/locator.dart';
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
//   late MobileScannerController _scannerController;
//   bool _isProcessing = false;
//   bool _cameraPermissionGranted = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _scannerController = MobileScannerController(
//       torchEnabled: false,
//       facing: CameraFacing.back,
//       detectionSpeed: DetectionSpeed.normal,
//       detectionTimeoutMs: 500,
//     );
//     _requestCameraPermission();
//   }
//
//   Future<void> _requestCameraPermission() async {
//     final status = await Permission.camera.request();
//     print('Camera permission status: $status');
//     if (status.isGranted) {
//       setState(() => _cameraPermissionGranted = true);
//       await _scannerController.start();
//     } else {
//       showCustomToast('Camera permission denied.');
//       if (mounted) Navigator.pop(context);
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _scannerController.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (!_cameraPermissionGranted) return;
//
//     if (state == AppLifecycleState.paused) {
//       _scannerController.stop();
//     } else if (state == AppLifecycleState.resumed) {
//       _scannerController.start();
//     }
//   }
//
//   void _onBarcodeDetected(BarcodeCapture capture) async {
//     if (_isProcessing || capture.barcodes.isEmpty) return;
//
//     for (final barcode in capture.barcodes) {
//       final barcodeValue = barcode.rawValue;
//
//       if (barcodeValue == null || barcodeValue.isEmpty) continue;
//       if (_scannedBarcodes.contains(barcodeValue)) continue;
//
//       print("Barcode Detected: $barcodeValue");
//       _scannedBarcodes.add(barcodeValue);
//       setState(() => _isProcessing = true);
//
//       try {
//         // Directly navigate to AddProductView with the scanned code
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => AddProductView(
//               scannedCode: barcodeValue,
//               isEditing: false,
//             ),
//           ),
//         );
//       } catch (e) {
//         print('Error navigating to add product: $e');
//         showCustomToast('Error processing barcode. Please try again.');
//       } finally {
//         if (mounted) setState(() => _isProcessing = false);
//       }
//
//       break; // Process only one barcode at a time
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Scan Product to Add"),
//       ),
//       body: _cameraPermissionGranted
//           ? Column(
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 MobileScanner(
//                   controller: _scannerController,
//                   onDetect: _onBarcodeDetected,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, child) {
//                     return Center(child: Text('Camera error: $error'));
//                   },
//                 ),
//                 Center(
//                   child: Container(
//                     width: 250,
//                     height: 250,
//                     decoration: BoxDecoration(
//                       border:
//                       Border.all(color: Colors.greenAccent, width: 2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ScannerControlBar(scannerController: _scannerController),
//         ],
//       )
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/model/product_model.dart';
import '../module/product/view/add_product.dart';
import '../module/product/vm/product_vm.dart';
import '../service/local/user_service.dart';
import '../utils/snack_message.dart';
import '../module/product/vm/product_viewmodel.dart';
import 'package:etegram_business/app_widget/scanner_control_bar.dart';
import 'package:etegram_business/locator.dart';

class AddProductScannerView extends StatefulWidget {
  const AddProductScannerView({Key? key}) : super(key: key);

  @override
  State<AddProductScannerView> createState() => _AddProductScannerViewState();
}

class _AddProductScannerViewState extends State<AddProductScannerView>
    with WidgetsBindingObserver {
  final Set<String> _scannedBarcodes = {};
  late MobileScannerController _scannerController;
  bool _isProcessing = false;
  bool _cameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerController = MobileScannerController(
      torchEnabled: false,
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 500,
    );
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    print('Camera permission status: $status');
    if (status.isGranted) {
      setState(() => _cameraPermissionGranted = true);
      await _scannerController.start();
    } else {
      showCustomToast('Camera permission denied.');
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraPermissionGranted) return;

    if (state == AppLifecycleState.paused) {
      _scannerController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _scannerController.start();
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing || capture.barcodes.isEmpty) return;

    for (final barcode in capture.barcodes) {
      final barcodeValue = barcode.rawValue;

      if (barcodeValue == null || barcodeValue.isEmpty) continue;
      if (_scannedBarcodes.contains(barcodeValue)) continue;

      print("Barcode Detected: $barcodeValue");
      _scannedBarcodes.add(barcodeValue);
      setState(() => _isProcessing = true);

      try {
        final productViewModel = locator<PRoductViewModel>();
        final String? ownerId = await locator<CustomerService>().getOwnerId();
        final String? storeId = await locator<CustomerService>().getStoreId();

        if (ownerId == null || storeId == null) {
          showCustomToast('Could not retrieve user or store information.');
          return;
        }

        final exists =
            await productViewModel.checkProductExistence(barcodeValue, context);

        if (exists) {
          // Product exists, navigate to EditProductView
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddProductView(isEditing: true),
              ),
            );
          }
        } else {
          // Product does not exist, navigate to AddProductView
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddProductView(
                  scannedCode: barcodeValue,
                  isEditing: false,
                  ownerId: ownerId, // Pass the ownerId
                  storeId: storeId,
                ),
              ),
            );
          }
        }
      } catch (e) {
        print('Error processing barcode: $e');
        showCustomToast('Error processing barcode. Please try again.');
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }

      break; // Process only one barcode at a time
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Product"),
      ),
      body: _cameraPermissionGranted
          ? Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onBarcodeDetected,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, child) {
                          return Center(child: Text('Camera error: $error'));
                        },
                      ),
                      Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.greenAccent, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ScannerControlBar(scannerController: _scannerController),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
