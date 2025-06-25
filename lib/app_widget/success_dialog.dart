import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../constants/colors.dart';

class SuccessDialog extends StatelessWidget {
  final String productName;
  final VoidCallback onScanAnother;
  final VoidCallback onGoToDashboard;

  const SuccessDialog({
    super.key,
    required this.productName,
    required this.onScanAnother,
    required this.onGoToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/confetti.json',
                  height: 150,
                  width: 150,
                  repeat: false,
                ),
                const Text(
                  'Product Added Successfully!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorValues.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '"$productName" has been added to your store.',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onGoToDashboard,
                      child: const Text('Go to Dashboard'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorValues.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onScanAnother,
                      child: const Text('Scan Another'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}