import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/customer_response.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({super.key, required this.customer});
  final CustomerData customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height(context) * 0.15,
      width: width(context),
      decoration: BoxDecoration(
          color: ColorValues.whiteColor,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                "UserName",
                style: bodyTextStyle,
              ),
              AppText(
                customer.firstName ?? "",
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
                "Address",
                style: titleMedium,
              ),
              RichText(
                text: TextSpan(
                    text: "${customer.area},",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      TextSpan(
                          text: '${customer.lga} ', style: normalTextStyle),
                      TextSpan(
                          text: ' ${customer.state}', style: normalTextStyle),
                    ]),
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                "Contact No.",
                style: titleMedium,
              ),
              AppText(
                customer.phoneNumber ?? "",
                style: normalTextStyle,
              )
            ],
          ),
        ],
      ),
    );
  }
}
