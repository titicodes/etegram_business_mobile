import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/module/splash/splash_view_model.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SplashScreenViewModel>(
      onModelReady: (model) => model.checkUserSetup(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/splash_screen.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: model.isLoading,
              builder: (context, isLoading, child) {
                if (isLoading) {
                  return const Center(
                    child: SpinKitCircle(
                      color: ColorValues.primaryColor,
                      size: 50.0,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
