import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/module/product/vm/product_vm.dart';
import 'package:etegram_business/module/product/view/add_product.dart'; // Import AddProductView
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProductViewModel>(
      builder: (_, model, child) => Scaffold(
        appBar: AppBar(title: const Text("Scan Barcode")), // Add an AppBar
        body: MobileScanner(
          onDetect: (BarcodeCapture capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              final String? code = barcode.rawValue;
              if (code != null) {
                // Navigate to AddProductView and pass the scanned code
                Navigator.pushReplacement( // Or Navigator.push if you want to keep the scanner open on back
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductView(
                      isEditing: false, // Assuming it's a new product
                      scannedCode: code,
                    ),
                  ),
                );
                break; // Break the loop after the first successful scan
              }
            }
          },
        ),
      ),
    );
  }
}