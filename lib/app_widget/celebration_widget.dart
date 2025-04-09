// import 'dart:math';
//
// import 'package:confetti/confetti.dart';
// import 'package:etegram_business/app_widget/app_button.dart';
// import 'package:etegram_business/app_widget/custom_appbar.dart';
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/utils/widget_extension.dart';
// import 'package:flutter/material.dart';
//
// class CelebrationWidget extends StatefulWidget {
//   final String title; // Required title
//   final VoidCallback onTap; // Required callback
//
//   const CelebrationWidget({
//     super.key,
//     required this.title,
//     required this.onTap,
//   });
//
//   @override
//   State<CelebrationWidget> createState() => _CelebrationWidgetState();
// }
//
// class _CelebrationWidgetState extends State<CelebrationWidget> {
//   late ConfettiController _controllerCenter;
//
//   @override
//   void initState() {
//     _controllerCenter = ConfettiController(duration: const Duration(seconds: 10));
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _controllerCenter.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorValues.primaryColor,
//       appBar: CustomAppBar(
//         title: "",
//         onBackPressed: () {},
//         showMenuIcon: true,
//       ),
//       body: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Align(
//             alignment: Alignment.topCenter,
//             child: ConfettiWidget(
//               confettiController: _controllerCenter,
//               blastDirection: pi,
//               minBlastForce: 10,
//               maxBlastForce: 50,
//               blastDirectionality: BlastDirectionality.explosive,
//             ),
//           ),
//           Container(
//             height: height(context),
//             width: width(context),
//             decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 AppButton(
//                   text: widget.title, // Use widget.title here
//                   onTap: widget.onTap, // Use widget.onTap here
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

class CelebrationWidget extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final Widget? child; // Optional child widget

  const CelebrationWidget({
    super.key,
    required this.title,
    required this.onTap,
    this.child, // Make child optional
  });

  @override
  State<CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<CelebrationWidget> {
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 10));
    _controllerCenter.play(); // Start confetti immediately
    super.initState();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.backgroundColor,
      appBar: CustomAppBar(
        title: "",
        onBackPressed: () {
          navigationService.goBack();
        },
        showMenuIcon: false, // Ensure no menu icon if it's a celebration
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirection: pi,
              minBlastForce: 10,
              maxBlastForce: 50,
              blastDirectionality: BlastDirectionality.explosive,
            ),
          ),
          Center( // Center the child content
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              children: [
                if (widget.child != null) widget.child!, // Show child if provided
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AppButton(
                    text: widget.title,
                    onTap: widget.onTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}