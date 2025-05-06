import 'package:etegram_business/app_widget/scanner_control_bar.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:etegram_business/locator.dart';
import '../module/home/views/main_nav.dart';
import '../module/product/view/add_product.dart';
import '../module/sales/view/scan_to_checkout.dart';
import '../module/sales/vm/new_sales_vm.dart';
import '../module/sales/vm/review_screen.dart';
import '../service/local/user_service.dart';
import '../utils/snack_message.dart';

class CheckoutScannerView extends StatefulWidget {
  const CheckoutScannerView({super.key});

  @override
  State<CheckoutScannerView> createState() => _CheckoutScannerViewState();
}

class _CheckoutScannerViewState extends State<CheckoutScannerView>
    with WidgetsBindingObserver {
  final Set<String> _scannedBarcodes = {};
  late MobileScannerController _scannerController;
  bool _isProcessing = false;
  bool _cameraPermissionGranted = false;
  final SaleViewModel _salesViewModel = locator<SaleViewModel>();
  final _customerService = locator<CustomerService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerController = MobileScannerController();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => _cameraPermissionGranted = true);
      _scannerController.start();
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

    final barcodeValue = capture.barcodes.first.rawValue;
    if (barcodeValue == null ||
        barcodeValue.isEmpty ||
        _scannedBarcodes.contains(barcodeValue)) return;

    _scannedBarcodes.add(barcodeValue);
    setState(() => _isProcessing = true);

    try {
      await _handleScan(barcodeValue);
    } catch (e) {
      print('Barcode processing error: $e');
      showCustomToast('Error processing barcode. Please try again.');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleScan(String barcode) async {
    // Use the viewModel instance directly instead of creating a new one
    final exists = await _salesViewModel.checkIfProductExists(barcode, context);

    if (exists) {
      showCustomToast('Product added to cart.');
      await _scannerController.stop();

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScanToCheckoutView(scannedCode: barcode),
        ),
      );

      if (mounted) await _scannerController.start();
    } else {
      await _showProductNotFoundDialog(barcode);
    }
  }

  Future<void> _showProductNotFoundDialog(String barcode) async {
    await _scannerController.stop();
    final ownerId = await _customerService.getOwnerId();
    final storeId = await _customerService.getStoreId();
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Product Not Found'),
          content: Text(
              'Product with barcode "$barcode" not found. What would you like to do?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (mounted) {
                  _scannedBarcodes
                      .remove(barcode); // Remove the unsuccessful scan
                  _scannerController.start(); // Resume scanning
                }
              },
              child: const Text('Scan Another Product'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddProductView(
                      scannedCode: barcode,
                      isEditing: false,
                      ownerId: ownerId,
                      storeId: storeId,
                    ),
                  ),
                );
              },
              child: const Text('Add Product'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNav()),
                );
              },
              child: const Text('Go to Home'),
            ),
          ],
        );
      },
    );

    if (mounted) {
      await _scannerController
          .start(); // Resume scanning after dialog is closed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan for Checkout"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Use the cart items from the view model instead of passing an empty list
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewScreen(
                    cartItems: _salesViewModel.cartItems,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _cameraPermissionGranted
          ? Column(
              children: [
                Expanded(
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: _onBarcodeDetected,
                  ),
                ),
                ScannerControlBar(scannerController: _scannerController),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
