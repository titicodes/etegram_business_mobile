// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class SafeMobileScannerView extends StatefulWidget {
//   final Function(BarcodeCapture) onDetect;
//   final Widget Function(MobileScannerController)? overlayBuilder; // Changed to function
//   final Widget? loadingWidget;
//   final CameraFacing cameraFacing;
//   final DetectionSpeed detectionSpeed;
//   final Duration detectionTimeout;
//
//   const SafeMobileScannerView({
//     super.key,
//     required this.onDetect,
//     this.overlayBuilder,
//     this.loadingWidget,
//     this.cameraFacing = CameraFacing.back,
//     this.detectionSpeed = DetectionSpeed.normal,
//     this.detectionTimeout = const Duration(milliseconds: 500),
//   });
//
//   @override
//   State<SafeMobileScannerView> createState() => _SafeMobileScannerViewState();
// }
//
// class _SafeMobileScannerViewState extends State<SafeMobileScannerView>
//     with WidgetsBindingObserver {
//   late MobileScannerController _controller;
//   bool _cameraPermissionGranted = false;
//   final _scannerKey = GlobalKey();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _controller = MobileScannerController(
//       facing: widget.cameraFacing,
//       detectionSpeed: widget.detectionSpeed,
//       detectionTimeoutMs: widget.detectionTimeout.inMilliseconds,
//     );
//     _requestCameraPermission();
//   }
//
//   Future<void> _requestCameraPermission() async {
//     final status = await Permission.camera.request();
//     if (status.isGranted) {
//       setState(() => _cameraPermissionGranted = true);
//       await _controller.start();
//     } else {
//       setState(() => _cameraPermissionGranted = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Camera permission denied')),
//         );
//         Navigator.pop(context);
//       }
//     }
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (!_cameraPermissionGranted) return;
//
//     if (state == AppLifecycleState.resumed) {
//       await _controller.stop();
//       await Future.delayed(const Duration(milliseconds: 300));
//       await _controller.start();
//     } else if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.inactive) {
//       await _controller.stop();
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_cameraPermissionGranted) {
//       return widget.loadingWidget ??
//           const Center(child: CircularProgressIndicator());
//     }
//
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         MobileScanner(
//           key: _scannerKey,
//           controller: _controller,
//           onDetect: widget.onDetect,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, child) {
//             return Center(child: Text('Camera error: $error'));
//           },
//         ),
//         if (widget.overlayBuilder != null) widget.overlayBuilder!(_controller), // Call the builder with controller
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class SafeMobileScannerView extends StatefulWidget {
  final Function(BarcodeCapture) onDetect;
  final Widget Function(MobileScannerController)? overlayBuilder;
  final Widget? loadingWidget;
  final CameraFacing cameraFacing;
  final DetectionSpeed detectionSpeed;
  final Duration detectionTimeout;

  const SafeMobileScannerView({
    super.key,
    required this.onDetect,
    this.overlayBuilder,
    this.loadingWidget,
    this.cameraFacing = CameraFacing.back,
    this.detectionSpeed = DetectionSpeed.normal,
    this.detectionTimeout = const Duration(milliseconds: 500),
  });

  @override
  State<SafeMobileScannerView> createState() => _SafeMobileScannerViewState();
}

class _SafeMobileScannerViewState extends State<SafeMobileScannerView> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  MobileScannerController? _controller;
  bool _cameraPermissionGranted = false;
  bool _isStarting = false;
  bool _isDisposed = false;
  final _scannerKey = GlobalKey();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
    _requestCameraPermission();
  }

  void _initializeController() {
    if (_isDisposed) return;
    _controller?.dispose();
    _controller = MobileScannerController(
      facing: widget.cameraFacing,
      detectionSpeed: widget.detectionSpeed,
      detectionTimeoutMs: widget.detectionTimeout.inMilliseconds,
      formats: [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA, BarcodeFormat.upcE],
      autoStart: false,
    );
    print('SafeMobileScannerView: Controller initialized');
  }

  Future<void> _requestCameraPermission() async {
    if (_isDisposed) return;

    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (mounted && !_isDisposed) {
        setState(() => _cameraPermissionGranted = true);
        await _startScanner();
      }
    } else {
      if (mounted && !_isDisposed) {
        setState(() => _cameraPermissionGranted = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _startScanner() async {
    if (_isStarting || !_cameraPermissionGranted || _isDisposed || !mounted || _controller == null) {
      return;
    }

    setState(() => _isStarting = true);

    try {
      await _controller!.stop();
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted && !_isDisposed && _controller != null) {
        await _controller!.start();
        print('SafeMobileScannerView: Scanner started successfully');
      }
    } catch (e) {
      print('SafeMobileScannerView: Error starting scanner: $e');
      if (mounted && !_isDisposed) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && !_isDisposed && !_isStarting && _controller != null) {
          await _retryStartScanner();
        }
      }
    } finally {
      if (mounted && !_isDisposed) {
        setState(() => _isStarting = false);
      }
    }
  }

  Future<void> _retryStartScanner() async {
    if (_isDisposed || !mounted || _controller == null) return;

    try {
      await _controller!.start();
      print('SafeMobileScannerView: Scanner retry successful');
    } catch (retryError) {
      print('SafeMobileScannerView: Retry failed: $retryError');
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $retryError')),
        );
      }
    }
  }

  Future<void> _stopScanner() async {
    if (_isDisposed || _controller == null) return;

    try {
      await _controller!.stop();
      print('SafeMobileScannerView: Scanner stopped');
    } catch (e) {
      print('SafeMobileScannerView: Error stopping scanner: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDisposed && _cameraPermissionGranted) {
      _initializeController();
      _startScanner();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (!_cameraPermissionGranted || _isDisposed || _controller == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        print('SafeMobileScannerView: App resumed, reinitializing scanner');
        _initializeController();
        await _startScanner();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        print('SafeMobileScannerView: App paused/inactive, stopping scanner');
        await _stopScanner();
        break;
      case AppLifecycleState.hidden:
        await _stopScanner();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    print('SafeMobileScannerView: Disposing scanner');
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_cameraPermissionGranted) {
      return widget.loadingWidget ??
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Requesting camera permission...'),
              ],
            ),
          );
    }

    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          key: _scannerKey,
          controller: _controller!,
          onDetect: widget.onDetect,
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
                      _initializeController();
                      await _startScanner();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
        ),
        if (widget.overlayBuilder != null) widget.overlayBuilder!(_controller!),
        if (_isStarting)
          Container(
            color: Colors.black26,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Starting camera...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}