import 'package:carousel_slider/carousel_slider.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg

import '../../app_widget/app_button.dart';
import '../../app_widget/app_text.dart';
import '../../base/base_ui.dart';
import '../../constants/colors.dart';
import '../../utils/widget_extension.dart';
import 'onboarding_vm.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<OnBoardingViewModel>(
        builder: (context, model, child) => Scaffold(
          backgroundColor: ColorValues.backgroundColor,
              body: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CarouselSlider.builder(
                        options: CarouselOptions(
                          height: height(context),
                          initialPage: 0,
                          autoPlay: true,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: false,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (
                            index,
                            reason,
                          ) {
                            model.changeCarouselIndexValue(index);
                          },
                        ),
                        itemCount: 3,
                        itemBuilder: (context, index, realIndex) {
                          return Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: model.onBoardingObjects[index].image
                                            .endsWith('.svg')
                                        ? null
                                        : DecorationImage(
                                            image: AssetImage(model
                                                .onBoardingObjects[index]
                                                .image),
                                            fit: BoxFit.fitWidth,
                                          ),
                                  ),
                                  child: model.onBoardingObjects[index].image
                                          .endsWith('.svg')
                                      ? SvgPicture.asset(
                                          model.onBoardingObjects[index].image,
                                          fit: BoxFit.fitWidth,
                                        )
                                      : null,
                                ),
                              ),
                              SizedBox(
                                height: 6,
                                child: AnimatedSmoothIndicator(
                                  activeIndex: model.sliderIndex,
                                  count: 3,
                                  axisDirection: Axis.horizontal,
                                  effect: ScrollingDotsEffect(
                                    spacing: 10,
                                    activeDotColor: ColorValues.primaryColor,
                                    activeDotScale: 1,
                                    dotColor: ColorValues.greyColor,
                                    dotHeight: 6,
                                    dotWidth: index == realIndex ? 22 : 9,
                                  ),
                                ),
                              ),
                              32.0.sbH,
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: AppText(
                                  model.onBoardingObjects[index].details,
                                  isBold: true,
                                  size: 12.sp,
                                  color: ColorValues.appTextColor,
                                  align: TextAlign.center,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          48.0.sbH,
                          AppButton(
                            width: width(context),
                            text: StringValues.getStarted,
                            onTap: model.goToWelcomeScreen,
                          ),
                          20.0.sbH,
                          AppButton(
                            isTransparent: true,
                            onTap: model.goToUserLogin,
                            text: "Log In",
                          ),
                          32.0.sbH
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
}
