// import 'dart:async';
// import 'dart:math';
//
// import 'package:confetti/confetti.dart';
// import 'package:etegram_business/app_widget/app_button.dart';
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/utils/widget_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class BlastSuccessWidget extends StatefulWidget {
//   final String message;
//   final VoidCallback? onContinue;
//   final String continueButtonText;
//
//   const BlastSuccessWidget({
//     super.key,
//     required this.message,
//     this.onContinue,
//     this.continueButtonText = 'Continue',
//   });
//
//   @override
//   State<BlastSuccessWidget> createState() => _BlastSuccessWidgetState();
// }
//
// class _BlastSuccessWidgetState extends State<BlastSuccessWidget> {
//   late ConfettiController _controllerTopCenter;
//   Timer? _timer;
//
//   List<Path Function(Size)> _getConfettiShapes() {
//     return [
//       drawCircle,
//       drawStar,
//           (size) => drawPolygon(size, sides: 3), // Triangle
//           (size) => drawPolygon(size, sides: 6), // Hexagon
//     ];
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _controllerTopCenter =
//         ConfettiController(duration: const Duration(seconds: 3));
//     _playConfetti();
//     _timer = Timer(const Duration(seconds: 4), () {
//       if (_controllerTopCenter.state == ConfettiControllerState.playing) {
//         _controllerTopCenter.stop();
//       }
//     });
//   }
//
//   void _playConfetti() {
//     _controllerTopCenter.play();
//   }
//
//   @override
//   void dispose() {
//     _controllerTopCenter.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorValues.backgroundColor,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () {
//             navigationService.goBack();
//           },
//         ),
//         title: const Text('Success'),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//       body: Stack(
//         children: [
//           Align(
//             alignment: Alignment.topCenter,
//             child: ConfettiWidget(
//               confettiController: _controllerTopCenter,
//               blastDirection: pi / 2, // shoot downward
//               maxBlastForce: 100,
//               minBlastForce: 80,
//               emissionFrequency: 0.05,
//               numberOfParticles: 50,
//               gravity: 0.1,
//               shouldLoop: false,
//               colors: const [
//                 Colors.green,
//                 Colors.blue,
//                 Colors.pink,
//                 Colors.orange,
//                 Colors.purple,
//               ],
//               createParticlePath: (size) => _getConfettiShapes()[
//               Random().nextInt(_getConfettiShapes().length)](size),
//             ),
//           ),
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Icon(
//                   Icons.check_circle_outline,
//                   color: Colors.green,
//                   size: 80.sp,
//                 ),
//                 SizedBox(height: 24.sp),
//                 Text(
//                   widget.message,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 48.sp),
//                 AppButton(
//                   text: widget.continueButtonText,
//                   onTap: widget.onContinue ?? () {
//                     navigationService.goBack();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
