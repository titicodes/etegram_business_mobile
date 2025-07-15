import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/model/sales_records.dart';

class OwedWidget extends StatelessWidget {
  final ValueListenable<List<SalesRecord>> records;

  const OwedWidget({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SalesRecord>>(
      valueListenable: records,
      builder: (context, records, _) {
        if (records.isEmpty) {
          return Center(
            child: Column(
              children: [
                SvgPicture.asset(SvgAssets.noRecord),
                20.0.sbH,
                AppText(
                  StringValues.noRecordFord,
                  style: normalTextStyle.copyWith(color: ColorValues.appTextColor),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: AppText(
                  'Customer: ${record.customerId ?? 'Unknown'}',
                  style: normalTextStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Amount: ₦${record.totalPriceWithTax.toStringAsFixed(2)}'),
                    AppText('Status: ${record.status}'),
                    AppText('Date: ${record.createdAt.toString().substring(0, 10)}'),
                    AppText('Products: ${record.cartItems.map((item) => item.product.name).join(', ')}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}