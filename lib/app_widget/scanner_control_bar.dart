import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerControlBar extends StatelessWidget {
  final MobileScannerController scannerController;

  const ScannerControlBar({super.key, required this.scannerController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () => scannerController.stop(),
            icon: const Icon(Icons.pause),
            label: const Text('Pause'),
          ),
          ElevatedButton.icon(
            onPressed: () => scannerController.start(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume'),
          ),
          ElevatedButton.icon(
            onPressed: () => scannerController.toggleTorch(),
            icon: const Icon(Icons.flash_on),
            label: const Text('Torch'),
          ),
        ],
      ),
    );
  }
}
