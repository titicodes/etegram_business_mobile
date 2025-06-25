import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class SafeMobileScannerView extends StatefulWidget {
  final Function(BarcodeCapture) onDetect;
  final Widget Function(MobileScannerController)? overlayBuilder; // Changed to function
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

class _SafeMobileScannerViewState extends State<SafeMobileScannerView>
    with WidgetsBindingObserver {
  late MobileScannerController _controller;
  bool _cameraPermissionGranted = false;
  final _scannerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      facing: widget.cameraFacing,
      detectionSpeed: widget.detectionSpeed,
      detectionTimeoutMs: widget.detectionTimeout.inMilliseconds,
    );
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => _cameraPermissionGranted = true);
      await _controller.start();
    } else {
      setState(() => _cameraPermissionGranted = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!_cameraPermissionGranted) return;

    if (state == AppLifecycleState.resumed) {
      await _controller.stop();
      await Future.delayed(const Duration(milliseconds: 300));
      await _controller.start();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      await _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraPermissionGranted) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          key: _scannerKey,
          controller: _controller,
          onDetect: widget.onDetect,
          fit: BoxFit.cover,
          errorBuilder: (context, error, child) {
            return Center(child: Text('Camera error: $error'));
          },
        ),
        if (widget.overlayBuilder != null) widget.overlayBuilder!(_controller), // Call the builder with controller
      ],
    );
  }
}