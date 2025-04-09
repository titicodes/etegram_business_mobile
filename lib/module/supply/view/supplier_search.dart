import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app_widget/custom_appbar.dart';
import '../../../constants/colors.dart';
import '../../../constants/strings.dart';

class SupplierSearch extends StatelessWidget {
  const SupplierSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.backgroundColor,
      appBar: CustomAppBar(
        title: StringValues.newSupplier,
        onBackPressed: () {},
        showMenuIcon: true,
        onMenuPressed: () {
          // Handle menu action
        },
        showNotificationIcon: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              60.0.sbH,
              AppText(
                StringValues.totalSupplier,
                style: titleSmall,
              ),
              20.0.sbH,
              InkWell(
                onTap: () {},
                child: Container(
                  height: 44,
                  width: width(context) * .5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: ColorValues.whiteColor),
                  child: AppText(
                    StringValues.tapToSeeSupplier,
                    style: normalTextStyle12,
                  ),
                ),
              ),
              Center(
                child: SvgPicture.asset(SvgAssets.noRecord),
              )
            ],
          ),
        ),
      ),
    );
  }
}
