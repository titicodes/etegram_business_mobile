import 'package:etegram_business/app_widget/safe_mobile_scanner_view.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lottie/lottie.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/product/view/add_product.dart';
import 'package:etegram_business/module/sales/view/scan_to_checkout.dart';
import 'package:etegram_business/module/sales/vm/new_sales_vm.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/app_widget/scanner_control_bar.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import '../../../constants/reuseable.dart';

class CheckoutScannerView extends StatefulWidget {
  const CheckoutScannerView({super.key});

  @override
  State<CheckoutScannerView> createState() => _CheckoutScannerViewState();
}

class _CheckoutScannerViewState extends State<CheckoutScannerView> {
  final Set<String> _scannedBarcodes = {};
  final CustomerService _customerService = locator<CustomerService>();
  bool _isProcessing = false;
  bool _isScannerPaused = false; // Control scanner pause after successful scan
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing || _isScannerPaused || capture.barcodes.isEmpty) return;

    final barcodeValue = capture.barcodes.first.rawValue;
    if (barcodeValue == null || barcodeValue.isEmpty) return;

    // Prevent duplicate scans in the same session
    if (_scannedBarcodes.contains(barcodeValue)) {
      showCustomToast('Product already scanned.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _scannedBarcodes.add(barcodeValue);
    });

    try {
      await _handleScan(barcodeValue);
    } catch (e, stackTrace) {
      print('Barcode processing error: $e\n$stackTrace');
      showCustomToast('Error processing barcode: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handleScan(String barcode) async {
    final model = locator<SaleViewModel>();
    final activeStoreId = await _customerService.getActiveStoreId();
    if (activeStoreId == null) {
      showCustomToast('No active store selected.');
      return;
    }

    print('Handling scan for barcode: $barcode, storeId: $activeStoreId');
    // Use addToCart instead of checkIfProductExists
    final added = await model.addToCart(barcode, activeStoreId);
    if (added) {
      if (!mounted) return;
      setState(() {
        _isScannerPaused = true; // Pause scanner after successful scan
        _scannerController.stop(); // Stop scanner to prevent further scans
      });
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/success.json',
                height: 100,
                repeat: false,
              ),
              10.0.sbH,
              const Text(
                'Product Added to Cart!',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              20.0.sbH,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _isScannerPaused = false; // Resume scanning
                        _scannerController.start(); // Restart scanner
                      });
                    },
                    child: const Text('Scan Another'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _scannedBarcodes
                          .clear(); // Clear scanned barcodes for new session
                      navigationService.navigateToWidget(
                        const ScanToCheckoutView(),
                        transitionBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                                    begin: const Offset(1, 0), end: Offset.zero)
                                .animate(animation),
                            child: child,
                          );
                        },
                      );
                    },
                    child: const Text('View Cart'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      await _showProductNotFoundDialog(barcode);
      if (mounted) {
        setState(() {
          _isScannerPaused = false; // Resume scanning if product not found
          _scannerController.start(); // Restart scanner
        });
      }
    }
  }

  Future<void> _showProductNotFoundDialog(String barcode) async {
    final ownerId = await _customerService.getOwnerId();
    final storeId = await _customerService.getActiveStoreId();
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Not Found'),
        content: Text(
            'Product with barcode "$barcode" not found in store. Would you like to add it?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScannerPaused = false; // Resume scanning
                _scannerController.start(); // Restart scanner
              });
            },
            child: const Text('Scan Another'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (ownerId != null && storeId != null) {
                navigationService.navigateToWidget(
                  AddProductView(
                    scannedCode: barcode,
                    isEditing: false,
                    ownerId: ownerId,
                    storeId: storeId,
                  ),
                  transitionBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(1, 0), end: Offset.zero)
                          .animate(animation),
                      child: child,
                    );
                  },
                );
              } else {
                showCustomToast('Missing owner or store ID.');
              }
            },
            child: const Text('Add Product'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              navigationService.navigateTo(mainNavViewRoute);
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = locator<SaleViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Products'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: model.cartItems.isEmpty
                  ? Colors.grey
                  : ColorValues.primaryColor,
            ),
            onPressed: model.cartItems.isEmpty
                ? null
                : () {
                    _scannedBarcodes
                        .clear(); // Clear scanned barcodes for new session
                    navigationService.navigateToWidget(
                      const ScanToCheckoutView(),
                      transitionBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                                  begin: const Offset(1, 0), end: Offset.zero)
                              .animate(animation),
                          child: child,
                        );
                      },
                    );
                  },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeMobileScannerView(
            onDetect: _onBarcodeDetected, // Pass non-nullable function
            overlayBuilder: (MobileScannerController controller) => Column(
              children: [
                const Spacer(),
                ScannerControlBar(
                  scannerController: controller,
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Lottie.asset(
                  'assets/animations/scan.json',
                  width: 150,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
