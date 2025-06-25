import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../constants/colors.dart';

class ScannerControlBar extends StatelessWidget {
  final MobileScannerController scannerController;

  const ScannerControlBar({super.key, required this.scannerController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.black54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.pause,
            label: 'Pause',
            onPressed: () => scannerController.stop(),
          ),
          _buildControlButton(
            icon: Icons.play_arrow,
            label: 'Resume',
            onPressed: () => scannerController.start(),
          ),
          _buildControlButton(
            icon: Icons.flash_on,
            label: 'Torch',
            onPressed: () => scannerController.toggleTorch(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorValues.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
