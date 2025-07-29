import 'package:flutter/material.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/get_scan_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/sales/vm/new_sales_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:intl/intl.dart';

class ReviewCard extends StatelessWidget {
  final String productName;
  final String code;
  final int quantity;
  final double amount;
  final double total;
  final String size;
  final int availableStock;

  const ReviewCard({
    super.key,
    required this.productName,
    required this.code,
    required this.quantity,
    required this.amount,
    required this.total,
    required this.size,
    required this.availableStock,
  });

  @override
  Widget build(BuildContext context) {
    final nairaFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦');
    return Card(
      elevation: 2,
      margin: 8.0.padV,
      child: Padding(
        padding: 16.0.padA,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              productName,
              style: bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            8.0.sbH,
            AppText('Code: $code', style: normalTextStyle12),
            AppText('Size: $size', style: normalTextStyle12),
            AppText('Unit Price: ${nairaFormat.format(amount)}', style: normalTextStyle12),
            AppText('Quantity: $quantity', style: normalTextStyle12),
            AppText('Available Stock: $availableStock', style: normalTextStyle12),
            AppText(
              'Subtotal: ${nairaFormat.format(total)}',
              style: normalTextStyle12.copyWith(color: ColorValues.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

