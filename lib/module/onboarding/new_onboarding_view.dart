import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/onboarding/onboarding_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_widget/app_text.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<OnBoardingViewModel>(builder: (_, con, child) {
      if (con.controller == null) {
        con.init();
      }
      return Scaffold(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        extendBody: true,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: PageView.builder(
                      controller: con.controller,
                      itemCount: con.onBoardingObjects.length,
                      onPageChanged: con.changeCarouselIndexValue,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(6),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: con.onBoardingObjects[index].image
                                        .endsWith('.svg')
                                        ? null
                                        : DecorationImage(
                                      image: AssetImage(con
                                          .onBoardingObjects[index]
                                          .image),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                  child: con.onBoardingObjects[index].image
                                      .endsWith('.svg')
                                      ? SvgPicture.asset(
                                    con.onBoardingObjects[index].image,
                                    fit: BoxFit.fitWidth,
                                  )
                                      : null,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: AppText(
                                  con.onBoardingObjects[index].details,
                                  style: titleLarge
                                ),
                              ),
                             10.0.sbH,

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    con.onBoardingObjects.length,
                                        (index) => buildDot(index, context, con),
                                  ),
                                ),
                              ),
                             32.0.sbH,
                              AppButton(
                                height: 60,
                                width: width(context) * .9,
                                text: con.sliderIndex == con.onBoardingObjects.length - 1
                                    ? StringValues.continues
                                    : StringValues.next,
                                onTap: () {
                                  if (kDebugMode) {
                                    print("Button tapped. Current index: ${con.sliderIndex}");
                                  }
                                  if (con.sliderIndex == con.onBoardingObjects.length - 1) {
                                    con.goToWelcomeScreen();
                                  } else {
                                    con.controller!.nextPage(
                                      duration: const Duration(milliseconds: 100),
                                      curve: Curves.bounceIn,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      })),
              32.0.sbH

            ],
          ),
        ),
      );
    });
  }

  Container buildDot(
      int index, BuildContext context, OnBoardingViewModel con) {
    return Container(
      height: 10,
      width: con.sliderIndex == index ? 25 : 10,
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ColorValues.primaryColor,
      ),
    );
  }
}
