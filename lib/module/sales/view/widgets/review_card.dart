import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ Import intl

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.productName,
    required this.quantity,
    required this.amount,
    required this.total,
    required this.size,
  });

  final String productName;
  final int quantity;
  final double amount;
  final double total;
  final String size;

  @override
  Widget build(BuildContext context) {
    final nairaFormat =
        NumberFormat.currency(locale: 'en_NG', symbol: '₦'); // ✅ Formatter

    return Container(
      width: width(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: 16.0.padA,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  productName,
                  style: bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppText(
                'x$quantity',
                style: bodyLarge,
              ),
            ],
          ),
          6.0.sbH,
          if (double.tryParse(size) != null && double.parse(size) > 0)
            AppText(
              'Size: ${size}ml',
              style: normalTextStyle12,
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Amount: ${nairaFormat.format(amount)}',
                style: normalTextStyle12,
              ),
              AppText(
                'Total: ${nairaFormat.format(total)}',
                style: bodyTextStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
