import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app_widget/app_text.dart';
import '../../../../constants/assets.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/strings.dart';
import '../../../../constants/style.dart';

class OwedWidget extends StatelessWidget {
  const OwedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          SvgPicture.asset(SvgAssets.noRecord),
          20.0.sbH,
          AppText(
            StringValues.noRecordFord,
            style: normalTextStyle.copyWith(color: ColorValues.appTextColor),
          )
        ],
      )),
    );
  }
}
