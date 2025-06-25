// import 'dart:async';
//
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/routes/routes.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get_storage/get_storage.dart';
//
// class SplashView extends StatefulWidget {
//   const SplashView({super.key});
//
//   @override
//   State<SplashView> createState() => _SplashViewState();
// }
//
// class _SplashViewState extends State<SplashView> {
//   @override
//   void initState() {
//     super.initState();
//     _navigateToOnboarding();
//   }
//
//   Future<void> _navigateToOnboarding() async {
//     // await Future.delayed(const Duration(seconds: 3)); // Delay for 3 seconds
//     // //context.go('/onboarding');
//     // navigationService.navigateTo(onBoardingScreenRoute);
//     final box = GetStorage();
//     String? userToken = box.read(DbTable.tokenTableName);
//     Timer(const Duration(seconds: 0), () {
//       navigationService.navigateToAndRemoveUntil(
//           userToken == null ? onBoardingScreenRoute : dashboardRoute);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: ColorValues.primaryColor,
//         body: Container(
//             height: MediaQuery.of(context).size.height,
//             decoration: BoxDecoration(
//                 image: DecorationImage(
//                     image: AssetImage("assets/images/splash_screen.jpg"),
//                     fit: BoxFit.cover))));
//   }
// }
