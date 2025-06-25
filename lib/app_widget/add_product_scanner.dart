import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/app_widget/scanner_control_bar.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/repository/product_repository.dart';
import 'package:etegram_business/routes/routes.dart';

class AddProductScannerView extends StatefulWidget {
  const AddProductScannerView({super.key});

  @override
  State<AddProductScannerView> createState() => _AddProductScannerViewState();
}

class _AddProductScannerViewState extends State<AddProductScannerView> {
  final Set<String> _scannedBarcodes = {};
  final ProductRepository _productRepository = locator<ProductRepository>();
  final CustomerService _customerService = locator<CustomerService>();
  bool _isProcessing = false;
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
    print('AddProductScannerView: Initialized');
  }

  Future<String?> _getStoreId() async {
    final storeId = await _customerService.getActiveStoreId();
    if (storeId == null) {
      showCustomToast('Store information missing.', success: false);
      print(
          'AddProductScannerView: CustomerService.getActiveStoreId returned null');
      Navigator.pushNamed(context, createStoreRoute);
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

  void _handleScan(BarcodeCapture capture) async {
    if (_isProcessing || capture.barcodes.isEmpty) return;

    final barcodeValue = capture.barcodes.first.rawValue;
    if (barcodeValue == null ||
        barcodeValue.isEmpty ||
        _scannedBarcodes.contains(barcodeValue)) return;

    _scannedBarcodes.add(barcodeValue);
    setState(() => _isProcessing = true);
    print('AddProductScannerView: Scanning barcode: $barcodeValue');

    try {
      final storeId = await _getStoreId();
      final ownerId = await _getOwnerId();
      if (storeId == null || ownerId == null) return;

      final product =
          await _productRepository.getProductByCode(barcodeValue, storeId);
      if (!mounted) return;

      if (product != null) {
        print('AddProductScannerView: Found product: ${product.name}');
        Navigator.pop(context, product);
      } else {
        print(
            'AddProductScannerView: Product not found for barcode: $barcodeValue');
        Navigator.pushNamed(
          context,
          addProductViewRoute,
          arguments: {
            'scannedCode': barcodeValue,
            'isEditing': false,
            'storeId': storeId,
            'ownerId': ownerId,
          },
        );
      }
    } catch (e) {
      showCustomToast('Error scanning product: $e', success: false);
      print('AddProductScannerView: Error scanning product: $e');
    } finally {
      if (mounted) {
        _scannedBarcodes.remove(barcodeValue);
        setState(() => _isProcessing = false);
      }
    }
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Product")),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleScan,
            fit: BoxFit.cover,
            overlayBuilder: (context, constraints) {
              return Column(
                children: [
                  Expanded(child: _buildOverlay()),
                  const SizedBox(height: 16),
                  ScannerControlBar(scannerController: _scannerController!),
                ],
              );
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: SpinKitWave(
                  size: 50.0,
                  color: ColorValues.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }
}
