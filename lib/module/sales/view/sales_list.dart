import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

class SalesList extends StatelessWidget {
  const SalesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: StringValues.review,
        onBackPressed: () {},
        showMenuIcon: true,
        showNotificationIcon: false,
        onMenuPressed: () {},
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 224,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        color: Colors.white,
        child: Column(
          children: [
            2.0.sbH,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  StringValues.total,
                  style: subHeaderTextStyle,
                ),
                AppText(
                  "N10000",
                  style: subHeaderTextStyle,
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(context, "Owed", () {}),
                _buildButton(context, StringValues.customer, () {}),
                _buildButton(context, StringValues.discount, () {})
              ],
            )
          ],
        ),
      ),
    );
  }

  _buildButton(BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        width: width(context) * 0.5,
        decoration: BoxDecoration(
            color: ColorValues.whiteColor,
            borderRadius: BorderRadius.circular(16)),
        child: AppText(
          title,
          style: normalTextStyle12,
        ),
      ),
    );
  }
}
