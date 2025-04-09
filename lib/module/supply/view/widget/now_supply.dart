import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app_widget/custom_appbar.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/strings.dart';

class NowSupply extends StatelessWidget {
  const NowSupply({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.backgroundColor,
      appBar: CustomAppBar(
        title: 'Supply Record',
        onBackPressed: () {
          // Handle back action
        },
        onNotificationPressed: () {
          // Handle notification action
        },
        showNotificationIcon: true, // Show notification icon
        onMenuPressed: () {
          // Handle menu action
        },
        showMenuIcon: false, // Hide menu icon
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(SvgAssets.noRecord),
            16.0.sbH,
            AppText(StringValues.noRecordFord, style: titleSmall,)
          ],
        ),
      )
    );
  }
}
