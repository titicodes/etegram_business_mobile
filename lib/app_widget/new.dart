// Splash Screen
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../base/base_ui.dart';
import '../constants/colors.dart';
import '../module/splash/splash_view_model.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SplashScreenViewModel>(
      onModelReady: (model) => model.checkUserSetup(),
      builder: (context, model, child) => Scaffold(
          backgroundColor: ColorValues.backgroundColor,
          body: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/splash_screen.jpg"),
                      fit: BoxFit.cover)))),
    );
  }
}
