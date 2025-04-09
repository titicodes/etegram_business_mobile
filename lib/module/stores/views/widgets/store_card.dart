import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/store_model.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store});
  final Store store;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height(context) * 0.15,
      width: width(context),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: ColorValues.whiteColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                "Store name",
                style: titleLarge,
              ),
              AppText(
                "${store.name}",
                style: normalTextStyle,
              )
            ],
          ),
          10.0.sbH,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                "Location",
                style: titleLarge,
              ),
              RichText(
                text: TextSpan(
                  text: '${store.area} ',
                  style: normalTextStyle,
                  children: <TextSpan>[
                    TextSpan(text: '${store.lga} ', style: normalTextStyle),
                    TextSpan(text: ' ${store.state}', style: normalTextStyle),
                  ],
                ),
              )
            ],
          ),
          10.0.sbH,
          AppText(
            "Store was created by ${store.owner}",
            style: titleLarge,
          )
        ],
      ),
    );
  }
}
