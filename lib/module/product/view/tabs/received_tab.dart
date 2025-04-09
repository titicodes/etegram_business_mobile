import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

class ReceivedTab extends StatelessWidget {
  const ReceivedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText("Received"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Container(
          alignment: Alignment.center,
          width: width(context) * 0.8,
          height: 50,
          decoration: BoxDecoration(
            color: ColorValues.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: AppText(
            StringValues.moveProducts,
            style: normalTextStyle12.copyWith(color: ColorValues.whiteColor),
          ),
        ),
      ),
    );
  }
}
