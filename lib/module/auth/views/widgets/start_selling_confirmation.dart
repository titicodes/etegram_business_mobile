import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StartSellingConfirmation extends StatelessWidget {
  const StartSellingConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Note here is an animation
            SvgPicture.asset(SvgAssets.noRecord),
            20.0.sbH,
            AppText("Udyson ng is Ready to start selling"),
            AppButton(
              text: "Continue",
              onTap: (){
                _showAddPaymentMethod(context);
              },
            )
          ],
        ),
      ),
    );
  }

  void _showAddPaymentMethod(BuildContext context) {

  }
}
