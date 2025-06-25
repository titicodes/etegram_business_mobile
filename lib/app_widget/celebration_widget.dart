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
  final Widget? child;

  const CelebrationWidget({
    super.key,
    required this.title,
    required this.onTap,
    this.child,
  });

  @override
  State<CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<CelebrationWidget> {
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 5));
    _controllerCenter.play();
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
        showMenuIcon: false,
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirection: pi / 2, // Upward direction for floating bubbles
              emissionFrequency: 0.05, // Frequent bubble emission
              numberOfParticles: 20, // Moderate number of bubbles
              minBlastForce: 2, // Gentle force for floating effect
              maxBlastForce: 5, // Controlled burst
              gravity: 0.05, // Low gravity for slow floating
              colors: const [
                Colors.lightBlueAccent,
                Colors.white70,
                Colors.blueAccent,
                Colors.cyanAccent,
              ], // Bubble-like colors
              createParticlePath: (size) {
                // Circular path for bubble shape
                final path = Path()
                  ..addOval(Rect.fromCircle(center: Offset.zero, radius: 5));
                return path;
              },
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.child != null)
                  widget.child!,
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