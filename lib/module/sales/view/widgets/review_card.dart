import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard(
      {super.key,
      required this.productName,
      required this.quantity,
      required this.amount,
      required this.total,
      required this.size});
  final String productName;
  final int quantity;
  final double amount;
  final double total;
  final int size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width(context),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                productName,
                style: bodyLarge,
              ),
              AppText(
                "x${quantity.toString()}",
                style: bodyLarge,
              )
            ],
          ),
          6.0.sbH,
          AppText(
            "Size:${size.toString()}ml",
            style: normalTextStyle12,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Amount:N${amount.toString()}',
                style: normalTextStyle12,
              ),
              AppText(
                'Total:N${total.toString()}',
                style: bodyTextStyle,
              )
            ],
          )
        ],
      ),
    );
  }
}
