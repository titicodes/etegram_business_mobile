import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductSearchView extends StatelessWidget {
  const ProductSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: navigationService.goBack,
          child: SvgPicture.asset(SvgAssets.arrowBack),
        ),
        title: AppText(
          StringValues.search,
          style: titleSmall,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(10),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.cancel),
              color: ColorValues.appTextColor,
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          40.0.sbH,
          AppText(
            StringValues.productNotFound,
            style: normalTextStyle12,
          )
        ],
      ),
    );
  }
}
