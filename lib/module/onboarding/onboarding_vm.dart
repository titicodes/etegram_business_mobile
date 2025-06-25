import 'package:etegram_business/base/base_vm.dart';
import 'package:flutter/material.dart';

import '../../constants/assets.dart';
import '../../constants/strings.dart';
import '../../routes/routes.dart';

// Modified OnBoardingViewModel
class OnBoardingViewModel extends BaseViewModel {
  int currentIndex = 0;
  PageController? controller;
  int sliderIndex = 0;
  int totalSize = 3;

  void init() {
    controller = PageController(initialPage: 0);
    notifyListeners();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  List<OnBoardingData> onBoardingObjects = [
    OnBoardingData(
        image: SvgAssets.onboarding1, details: StringValues.onBoarding1),
    OnBoardingData(
        image: SvgAssets.onboarding2, details: StringValues.onBoarding2),
    OnBoardingData(
        image: SvgAssets.onboarding3, details: StringValues.onBoarding3),
  ];

  void changeCarouselIndexValue(int indexValue) {
    sliderIndex = indexValue;
    notifyListeners();
  }

  void goToWelcomeScreen() {
    navigationService.navigateTo(welcomeScreenRoute);
  }

  void goToUserLogin() {
    navigationService.navigateTo(loginScreenRoute);
  }
}

class OnBoardingData {
  String image;
  String details;
  String? value;

  OnBoardingData({
    required this.image,
    required this.details,
    this.value,
  });
}
