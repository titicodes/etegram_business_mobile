import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:etegram_business/locator.dart';
import '../module/product/view/add_product.dart';
import '../module/sales/view/scan_to_checkout.dart';
import '../module/sales/vm/new_sales_vm.dart';
import '../module/sales/vm/review_screen.dart';
import '../utils/snack_message.dart';

enum ScanPurpose { add, checkout }

class BarcodeScannerView extends StatefulWidget {
  final ScanPurpose purpose;

  const BarcodeScannerView({super.key, required this.purpose});

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView>
    with WidgetsBindingObserver {
  final Set<String> _scannedBarcodes = {};
  late MobileScannerController _scannerController;
  bool _isProcessing = false;
  bool _cameraPermissionGranted = false;

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
    final checkoutViewModel = locator<SaleViewModel>();

    switch (widget.purpose) {
      case ScanPurpose.add:
        final exists = await checkoutViewModel.getProductByBarcode(barcode);
        if (exists) {
          showCustomToast('Product already exists in the database.');
        } else {
          await _promptToAddProduct(barcode);
        }
        break;

      case ScanPurpose.checkout:
        final added =
        await checkoutViewModel.checkIfProductExists(barcode, context);
        if (added) {
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
          await _promptToAddProduct(barcode);
        }
        break;
    }
  }

  Future<void> _promptToAddProduct(String barcode) async {
    await _scannerController.stop();

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Product Not Found'),
        content: Text('No product found with barcode "$barcode". Add it now?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddProductView(
                    scannedCode: barcode,
                    isEditing: false,
                  ),
                ),
              );
            },
            child: const Text('Add Product'),
          ),
        ],
      ),
    );

    if (mounted) await _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Products"),
        actions: widget.purpose == ScanPurpose.checkout
            ? [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ReviewScreen(cartItems: [],)),
              );
            },
          ),
        ]
            : null,
      ),
      body: _cameraPermissionGranted
          ? MobileScanner(
        controller: _scannerController,
        onDetect: _onBarcodeDetected,
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
