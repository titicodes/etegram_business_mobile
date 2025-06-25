// Modified OnBoardingView
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_widget/app_button.dart';
import '../../app_widget/app_text.dart';
import '../../base/base_ui.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import 'onboarding_vm.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<OnBoardingViewModel>(
      onModelReady: (con) => con.init(),
      builder: (_, con, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
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
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        children: [
                          Expanded(
                            child: SvgPicture.asset(
                              con.onBoardingObjects[index].image,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: AppText(
                              con.onBoardingObjects[index].details,
                              style: titleLarge,
                            ),
                          ),
                          10.0.sbH,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              con.onBoardingObjects.length,
                              (i) => buildDot(i, context, con),
                            ),
                          ),
                          32.0.sbH,
                          AppButton(
                            height: 40,
                            width: width(context)! * 0.8,
                            text: con.sliderIndex ==
                                    con.onBoardingObjects.length - 1
                                ? StringValues.continues
                                : StringValues.next,
                            onTap: () {
                              if (con.sliderIndex ==
                                  con.onBoardingObjects.length - 1) {
                                con.goToWelcomeScreen();
                              } else {
                                con.controller?.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              20.0.sbH,
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context, OnBoardingViewModel vm) {
    return Container(
      height: 8,
      width: vm.sliderIndex == index ? 24 : 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: vm.sliderIndex == index ? ColorValues.primaryColor : Colors.grey,
      ),
    );
  }
}
