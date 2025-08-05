import 'package:flutter/material.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:intl/intl.dart';

class ReviewCard extends StatelessWidget {
  final String productName;
  final String code;
  final int quantity;
  final double amount;
  final double total;
  final String size;
  final int availableStock;
  final Function(int)? onQuantityChanged;
  final VoidCallback? onRemove;

  const ReviewCard({
    super.key,
    required this.productName,
    required this.code,
    required this.quantity,
    required this.amount,
    required this.total,
    required this.size,
    required this.availableStock,
    this.onQuantityChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final nairaFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦');
    return Card(
      elevation: 0,
      margin: 8.0.padV,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: 8.0.padA,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppText(
                    productName,
                    style: bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: onRemove,
                ),
              ],
            ),
            8.0.sbH,
            AppText('Code: $code', style: normalTextStyle12),
            AppText('Price: ${nairaFormat.format(amount)}',
                style: normalTextStyle12),
            AppText('Subtotal: ${nairaFormat.format(total)}',
                style: normalTextStyle12),
            AppText('Size: $size', style: normalTextStyle12),
            AppText(
              'Available Stock: $availableStock',
              style: normalTextStyle12.copyWith(
                color: availableStock <= 5 ? Colors.red : Colors.black87,
              ),
            ),
            8.0.sbH,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.red),
                  onPressed: () {
                    if (quantity > 1) {
                      onQuantityChanged?.call(quantity - 1);
                    } else {
                      onRemove?.call();
                    }
                  },
                ),
                AppText('$quantity', style: bodyTextStyle),
                IconButton(
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.green),
                  onPressed: availableStock > quantity
                      ? () => onQuantityChanged?.call(quantity + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
