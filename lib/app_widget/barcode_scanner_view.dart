import 'dart:async';
import 'package:etegram_business/constants/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/module/product/view/add_product.dart';
import 'package:etegram_business/module/sales/vm/new_sales_vm.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/app_widget/scanner_control_bar.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/main.dart';
import 'package:etegram_business/core/model/get_scan_response.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/module/product/vm/product_viewmodel.dart';
import 'package:etegram_business/module/sales/view/scan_to_checkout.dart';
import 'package:etegram_business/module/home/vm/main_nav_vm.dart';
import 'package:etegram_business/service/local/navigation_service.dart';

import '../module/product/view/search_view.dart';
import '../repository/product_repository.dart';

class CheckoutScannerView extends StatelessWidget {
  const CheckoutScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SaleViewModel>(
      onModelReady: (model) {
        print('CheckoutScannerView: Model ready, instance: ${model.hashCode}');
        model.init();
      },
      builder: (context, model, child) =>
          _CheckoutScannerViewContent(model: model),
    );
  }
}

class _CheckoutScannerViewContent extends StatefulWidget {
  final SaleViewModel model;

  const _CheckoutScannerViewContent({required this.model});

  @override
  State<_CheckoutScannerViewContent> createState() =>
      _CheckoutScannerViewContentState();
}

class _CheckoutScannerViewContentState
    extends State<_CheckoutScannerViewContent>
    with WidgetsBindingObserver, RouteAware {
  final CustomerService _customerService = locator<CustomerService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final Set<String> _scannedBarcodes = {};
  bool _isProcessing = false;
  bool _isDisposed = false;
  bool _shouldResumeOnReturn = false;
  MobileScannerController? _scannerController;
  Timer? _debounceTimer;
  bool _cameraFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
    print(
        'CheckoutScannerView: Initialized, model instance: ${widget.model.hashCode}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanner();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      print('CheckoutScannerView: Subscribing to routeObserver');
      routeObserver.subscribe(this, route);
    }
  }

  void _initializeController() {
    if (_isDisposed) {
      print('CheckoutScannerView: Cannot initialize controller, disposed');
      return;
    }

    if (_scannerController == null) {
      _scannerController = MobileScannerController(
        facing: CameraFacing.back,
        detectionSpeed: DetectionSpeed.normal,
        detectionTimeoutMs: 1000,
        formats: [
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE
        ],
        autoStart: false,
      );
      print('CheckoutScannerView: Controller initialized');
    }
  }

  Future<void> _startScanner() async {
    if (_scannerController == null ||
        _isProcessing ||
        _isDisposed ||
        !mounted) {
      print(
          'CheckoutScannerView: Cannot start scanner - controller: $_scannerController, isProcessing: $_isProcessing, isDisposed: $_isDisposed, mounted: $mounted');
      setState(() => _cameraFailed = true);
      return;
    }

    try {
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final requestStatus = await Permission.camera.request();
        if (!requestStatus.isGranted) {
          if (mounted && !_isDisposed) {
            showCustomToast(
                'Camera permission denied. Please enable it in settings.',
                success: false);
            setState(() => _cameraFailed = true);
          }
          return;
        }
      }

      await _scannerController!.stop();
      await _scannerController!.start();
      print('CheckoutScannerView: Scanner started successfully');
      if (mounted && !_isDisposed) {
        setState(() => _cameraFailed = false);
      }
    } catch (e, stackTrace) {
      print('CheckoutScannerView: Error starting scanner: $e\n$stackTrace');
      if (mounted && !_isDisposed) {
        showCustomToast('Error starting scanner. Retrying...', success: false);
        setState(() => _cameraFailed = true);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && !_isDisposed) {
          await _restartScanner();
        }
      }
    }
  }

  Future<void> _stopScanner() async {
    if (_scannerController == null || _isDisposed) {
      print(
          'CheckoutScannerView: Cannot stop scanner - controller: $_scannerController, isDisposed: $_isDisposed');
      return;
    }

    try {
      await _scannerController!.stop();
      print('CheckoutScannerView: Scanner stopped');
    } catch (e, stackTrace) {
      print('CheckoutScannerView: Error stopping scanner: $e\n$stackTrace');
    }
  }

  Future<void> _restartScanner() async {
    if (_isDisposed || !mounted || _isProcessing) {
      print(
          'CheckoutScannerView: Cannot restart scanner - disposed: $_isDisposed, mounted: $mounted, isProcessing: $_isProcessing');
      setState(() => _cameraFailed = true);
      return;
    }

    print('CheckoutScannerView: Restarting scanner...');
    setState(() {
      _isProcessing = false;
      _cameraFailed = false;
    });
    await _stopScanner();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted && !_isDisposed) {
      _initializeController();
      await _startScanner();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    switch (state) {
      case AppLifecycleState.resumed:
        print('CheckoutScannerView: App resumed');
        if (!_isProcessing && !_cameraFailed && _shouldResumeOnReturn) {
          _startScanner();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        print('CheckoutScannerView: App paused/inactive, stopping scanner');
        _stopScanner();
        break;
      default:
        break;
    }
  }

  @override
  void didPopNext() {
    if (!_isProcessing && !_isDisposed && _shouldResumeOnReturn) {
      print('CheckoutScannerView: didPopNext, resuming scanner');
      _shouldResumeOnReturn = false;
      _startScanner();
    }
  }

  @override
  void didPushNext() {
    print('CheckoutScannerView: didPushNext, stopping scanner');
    _shouldResumeOnReturn = true;
    _stopScanner();
  }

  @override
  void dispose() {
    print(
        'CheckoutScannerView: Disposing, model instance: ${widget.model.hashCode}');
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _debounceTimer?.cancel();
    _stopScanner();
    _scannerController?.dispose();
    _scannerController = null;
    _scannedBarcodes.clear();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing || capture.barcodes.isEmpty || _isDisposed) {
      print(
          'CheckoutScannerView: Barcode detection skipped - isProcessing: $_isProcessing, barcodes: ${capture.barcodes.isEmpty}, isDisposed: $_isDisposed');
      return;
    }

    final barcodeValue = capture.barcodes.first.rawValue;
    if (barcodeValue == null || barcodeValue.isEmpty) {
      print('CheckoutScannerView: Invalid or empty barcode');
      return;
    }

    if (_scannedBarcodes.contains(barcodeValue)) {
      print('CheckoutScannerView: Debouncing duplicate barcode: $barcodeValue');
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 2000), () {
      _scannedBarcodes.remove(barcodeValue);
    });

    _scannedBarcodes.add(barcodeValue);
    setState(() => _isProcessing = true);
    await _stopScanner();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _handleScan(barcodeValue);
      } catch (e, stackTrace) {
        print('CheckoutScannerView: Barcode processing error: $e\n$stackTrace');
        if (mounted && !_isDisposed) {
          showCustomToast('Error processing barcode: $e', success: false);
          setState(() => _cameraFailed = true);
        }
      } finally {
        _scannedBarcodes.remove(barcodeValue);
        if (mounted && !_isDisposed) {
          setState(() => _isProcessing = false);
          await _restartScanner();
        }
      }
    });
  }

  Future<void> _handleScan(String barcode) async {
    final activeStoreId = await _customerService.getActiveStoreId();
    if (activeStoreId == null) {
      if (mounted && !_isDisposed) {
        showCustomToast('No active store selected.', success: false);
        await _restartScanner();
      }
      return;
    }

    final existingItem = widget.model.cartItems.value.firstWhere(
      (item) => item.code == barcode,
      orElse: () => Cart(
        id: '',
        name: '',
        price: 0.0,
        code: '',
        quantity: 0,
        subtotal: 0.0,
        availableQuantity: 0,
      ),
    );

    if (existingItem.code.isNotEmpty) {
      if (existingItem.quantity >= existingItem.availableQuantity) {
        if (mounted && !_isDisposed) {
          showCustomToast(
              'Maximum stock reached for ${existingItem.name}. Available: ${existingItem.availableQuantity}',
              success: false);
          await _restartScanner();
        }
        return;
      } else {
        widget.model.updateItemQuantityInReview(
            existingItem, existingItem.quantity + 1);
        if (mounted && !_isDisposed) {
          showCustomToast(
              'Quantity updated for ${existingItem.name}. New quantity: ${existingItem.quantity + 1}',
              success: true);
          await _showSuccessDialog(
            title: 'Quantity Updated for ${existingItem.name}!',
            onScanAnother: () async {
              _navigationService.goBack();
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted && !_isDisposed) {
                await _restartScanner();
              }
            },
            onViewCart: () async {
              _navigationService.goBack();
              _shouldResumeOnReturn = true;
              await _navigationService
                  .navigateToWidget(const ScanToCheckoutView());
            },
          );
        }
        return;
      }
    }

    print(
        'CheckoutScannerView: Handling scan for barcode: $barcode, storeId: $activeStoreId');
    final result = await widget.model.addToCart(barcode, activeStoreId);
    if (result['success'] == true) {
      HapticFeedback.vibrate();
      widget.model.scannedBarcodes.add(barcode);
      if (!mounted || _isDisposed) {
        return;
      }

      await _showSuccessDialog(
        title: 'Product Added to Cart!',
        onScanAnother: () async {
          _navigationService.goBack();
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted && !_isDisposed) {
            await _restartScanner();
          }
        },
        onViewCart: () async {
          _navigationService.goBack();
          _shouldResumeOnReturn = true;
          await _navigationService.navigateToWidget(const ScanToCheckoutView());
        },
      );
    } else {
      final message = result['message']?.toString().toLowerCase() ?? '';
      final product = result['product'] as ScanProduct?;
      final productName = result['name'] as String?;
      if (message.contains('out of stock') || product?.availableQuantity == 0) {
        await _showOutOfStockDialog(barcode, product, productName);
      } else {
        await _showProductNotFoundDialog(barcode);
      }
    }
  }

  Future<void> _showSuccessDialog({
    required String title,
    required VoidCallback onScanAnother,
    required VoidCallback onViewCart,
  }) async {
    if (!mounted || _isDisposed) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/success.json',
              height: 80,
              repeat: false,
              frameRate: FrameRate(15),
            ),
            10.0.sbH,
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            20.0.sbH,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: onScanAnother,
                  child: const Text('Scan Another'),
                ),
                TextButton(
                  onPressed: onViewCart,
                  child: const Text('View Cart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOutOfStockDialog(
      String barcode, ScanProduct? product, String? productName) async {
    final ownerId = await _customerService.getOwnerId();
    final storeId = await _customerService.getActiveStoreId();
    if (!mounted || storeId == null || ownerId == null || _isDisposed) {
      showCustomToast('Missing store or owner information.', success: false);
      return;
    }

    Product? productDetails;
    if (product != null) {
      // Construct Product from ScanProduct with available data
      productDetails = Product(
        id: product.id,
        name: product.name != 'Unknown Product'
            ? product.name
            : productName ?? 'Unknown Product',
        code: product.code ?? barcode,
        price:
            product.price != null && product.price != 0.0 ? product.price : 1.0,
        costPrice: product.costPrice ?? product.price ?? 1.0,
        quantity: product.availableQuantity ?? 0,
        minQuantity: product.minQuantity ?? 1,
        size: product.size,
        category: product.categoryId ?? 'Uncategorized',
        storeId: storeId,
        owner: ownerId,
        imageUrl: product.imageUrl,
        description: product.description,
        brands: product.brands, // Pass List<String>? directly
        expiryDate: product.expiryDate?.toIso8601String(),
      );
      print(
          'CheckoutScannerView: Constructed product from ScanProduct: ${productDetails.toJson()}');
    }

    // Fetch full product details using ProductRepository
    try {
      final productRepository = locator<ProductRepository>();
      productDetails =
          await productRepository.getProductByCode(barcode, storeId);
      if (productDetails != null) {
        print(
            'CheckoutScannerView: Fetched product details: ${productDetails.toJson()}');
      } else {
        print(
            'CheckoutScannerView: No product details found for barcode: $barcode');
        // Use constructed product or fallback
        productDetails ??= Product(
          id: null,
          code: barcode,
          name: productName ?? 'Unknown Product',
          storeId: storeId,
          owner: ownerId,
          quantity: 0,
          price: 1.0,
          costPrice: 1.0,
          minQuantity: 1,
          category: 'Uncategorized',
          size: null,
          brands: null,
          description: null,
          expiryDate: null,
          imageUrl: null,
        );
        print(
            'CheckoutScannerView: Using fallback product: ${productDetails.toJson()}');
      }
    } catch (e, stackTrace) {
      print(
          'CheckoutScannerView: Error fetching product details: $e\n$stackTrace');
      showCustomToast('Failed to fetch product details.', success: false);
      // Use constructed product or fallback
      productDetails ??= Product(
        id: null,
        code: barcode,
        name: productName ?? 'Unknown Product',
        storeId: storeId,
        owner: ownerId,
        quantity: 0,
        price: 1.0,
        costPrice: 1.0,
        minQuantity: 1,
        category: 'Uncategorized',
        size: null,
        brands: null,
        description: null,
        expiryDate: null,
        imageUrl: null,
      );
      print(
          'CheckoutScannerView: Using fallback product after error: ${productDetails.toJson()}');
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Out of Stock'),
        content: RichText(
          text: TextSpan(
            text: 'The product with barcode ',
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                  text: '"$barcode" (${productDetails!.name})',
                  style:
                      normalTextStyle12.copyWith(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      ' is out of stock. Would you like to update its stock? Note: Some product details are missing and need to be filled in.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              _navigationService.goBack();
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted && !_isDisposed) {
                await _restartScanner();
              }
            },
            child: const Text('Scan Another'),
          ),
          TextButton(
            onPressed: () {
              _navigationService.goBack();
              _shouldResumeOnReturn = true;
              _navigationService.navigateTo(addProductViewRoute, arguments: {
                'isEditing': true,
                'scannedCode': barcode,
                'product': productDetails,
                'ownerId': ownerId,
                'storeId': storeId,
                'needsImageSelection': productDetails?.imageUrl == null,
              });
            },
            child: const Text('Update Stock'),
          ),
          TextButton(
            onPressed: () {
              _navigationService.goBack();
              locator<MainNavViewModel>().onNavigationItem(0);
              _navigationService.navigateToAndRemoveUntil(mainNavViewRoute);
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  Future<void> _showProductNotFoundDialog(String barcode) async {
    final ownerId = await _customerService.getOwnerId();
    final storeId = await _customerService.getActiveStoreId();
    if (!mounted || _isDisposed) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Not Found'),
        content: Text(
            'Product with barcode "$barcode" not found in store. Would you like to add it?'),
        actions: [
          TextButton(
            onPressed: () async {
              _navigationService.goBack();
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted && !_isDisposed) {
                await _restartScanner();
              }
            },
            child: const Text('Scan Another'),
          ),
          TextButton(
            onPressed: () {
              _navigationService.goBack();
              if (ownerId != null && storeId != null) {
                _shouldResumeOnReturn = true;
                _navigationService.navigateTo(addProductViewRoute, arguments: {
                  'isEditing': false,
                  'scannedCode': barcode,
                  'ownerId': ownerId,
                  'storeId': storeId,
                  'needsImageSelection': true,
                });
              } else {
                showCustomToast('Missing owner or store ID.', success: false);
              }
            },
            child: const Text('Add Product'),
          ),
          TextButton(
            onPressed: () {
              _navigationService.goBack();
              locator<MainNavViewModel>().onNavigationItem(0);
              _navigationService.navigateToAndRemoveUntil(mainNavViewRoute);
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Cart>>(
      valueListenable: widget.model.cartItems,
      builder: (context, cartItems, child) {
        return WillPopScope(
          onWillPop: () async {
            print(
                'CheckoutScannerView: WillPopScope triggered, model instance: ${widget.model.hashCode}');
            await _stopScanner();
            return true;
          },
          child: Scaffold(
            backgroundColor: ColorValues.backgroundColor,
            appBar: AppBar(
              title: const Text('Scan Products'),
              backgroundColor: ColorValues.whiteColor,
              actions: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shopping_cart,
                        color: cartItems.isEmpty
                            ? Colors.grey
                            : ColorValues.primaryColor,
                      ),
                      onPressed: cartItems.isEmpty
                          ? null
                          : () {
                              _shouldResumeOnReturn = true;
                              _navigationService
                                  .navigateToWidget(const ScanToCheckoutView());
                            },
                    ),
                    if (cartItems.isNotEmpty)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cartItems.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            // In _CheckoutScannerViewContent.build, inside the Stack
            body: Stack(
              children: [
                if (_scannerController != null &&
                    !_isDisposed &&
                    !_cameraFailed)
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onBarcodeDetected,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, child) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error,
                                size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Camera error: $error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                await _restartScanner();
                              },
                              child: const Text('Retry Camera'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                _shouldResumeOnReturn = true;
                                _navigationService.navigateToWidget(
                                    const SearchProductView());
                              },
                              child: const Text('Add Manually'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                if (_cameraFailed)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Camera failed to start. Please try again or add manually.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await _restartScanner();
                          },
                          child: const Text('Retry Camera'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            _shouldResumeOnReturn = true;
                            _navigationService
                                .navigateToWidget(const SearchProductView());
                          },
                          child: const Text('Add Manually'),
                        ),
                      ],
                    ),
                  ),
                if (!_cameraFailed)
                  Column(
                    children: [
                      Expanded(child: _buildOverlay()),
                      const SizedBox(height: 16),
                      if (!_isProcessing &&
                          _scannerController != null &&
                          !_isDisposed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            children: [
                              ScannerControlBar(
                                  scannerController: _scannerController!),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _shouldResumeOnReturn = true;
                                  _navigationService.navigateToWidget(
                                      const SearchProductView());
                                },
                                child: const Text('Add Manually'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                if (_isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
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
        );
      },
    );
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
}
