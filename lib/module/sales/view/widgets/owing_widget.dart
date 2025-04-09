import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OwingWidget extends StatelessWidget {
  const OwingWidget({super.key});

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
