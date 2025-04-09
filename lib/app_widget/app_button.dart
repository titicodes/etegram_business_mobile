import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'app_text.dart';

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../app_widget/app_text.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool? isTransparent;
  final bool? isGradient;
  final bool? noHeight;
  final double? borderWidth;
  final double? height;
  final double? width;
  final double? borderRadius;
  final double? textSize;
  final Color? borderColor;
  final Color? backGroundColor;
  final Color? textColor;
  final String? text;
  final List<Color>? gradientColors;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final bool? isLoading;
  final bool isExpanded;
  final bool enabled; // Modified to be non-nullable and required

  const AppButton({
    super.key,
     this.enabled = true,
    this.onTap,
    this.isTransparent,
    this.isGradient,
    this.isLoading,
    this.gradientColors,
    this.child,
    this.width,
    this.borderWidth,
    this.borderColor,
    this.textColor,
    this.backGroundColor,
    this.text,
    this.borderRadius,
    this.padding,
    this.height,
    this.textSize,
    this.isExpanded = true,
    this.noHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        isExpanded ? Expanded(child: buttonBuild()) : buttonBuild(),
      ],
    );
  }

  Material buttonBuild() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled && (isLoading == true ? false : true)
            ? onTap
            : null, // Control onTap with enabled
        borderRadius: BorderRadius.circular(borderRadius ?? 5),
        child: Container(
          height: noHeight == true ? null : height ?? 52,
          width: width,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 5),
            gradient: isGradient == true
                ? LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: gradientColors ??
                        (enabled && (onTap != null && isLoading != true)
                            ? [
                                ColorValues.primaryColor,
                                ColorValues.primaryDarkColor
                              ]
                            : [
                                ColorValues.primaryColor.withValues(alpha: 128),
                                ColorValues.primaryDarkColor
                                    .withValues(alpha: 128)
                              ]),
                  )
                : null,
            border: Border.all(
                width: borderWidth ?? (isTransparent == true ? 1 : 0),
                color: borderColor ??
                    (isTransparent == true
                        ? textColor ??
                            (enabled && (onTap != null && isLoading != true)
                                ? ColorValues.primaryColor
                                : ColorValues.primaryColor
                                    .withValues(alpha: 128))
                        : Colors.transparent)),
            color: isGradient == true
                ? null
                : isTransparent == true
                    ? Colors.transparent
                    : backGroundColor != null
                        ? (enabled && (onTap != null && isLoading != true)
                            ? backGroundColor
                            : backGroundColor!.withValues(alpha: 128))
                        : (enabled && (onTap != null && isLoading != true)
                            ? ColorValues.primaryDarkColor
                            : ColorValues.primaryDarkColor
                                .withValues(alpha: 128)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              child: Padding(
                  padding: padding ??
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      child ??
                          AppText(
                            text ?? "",
                            family: 'Inter',
                            isBold: true,
                            color: textColor ??
                                (isTransparent == true
                                    ? (enabled &&
                                            (onTap != null && isLoading != true)
                                        ? textColor
                                        : textColor?.withOpacity(0.5))
                                    : ColorValues.whiteColor),
                            align: TextAlign.center,
                            size: textSize,
                          ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

class PrimaryBtn extends StatelessWidget {
  PrimaryBtn({
    super.key,
    this.color,
    this.textColor,
    this.widths,
    this.borderWidth,
    this.height,
    this.textSize,
    this.prefixIcon,
    this.suffixIcon,
    this.label,
    this.borderColor,
    required this.title,
    this.onPress,
  });

  Color? color;
  Color? borderColor;
  double? height;
  double? widths;
  Widget? prefixIcon;
  double? borderWidth;
  double? textSize;
  Widget? suffixIcon;
  Widget? label;
  Color? textColor;
  final String title;
  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onPress,
        child: Container(
          height: height ?? 60,
          width: widths ?? width(context),
          decoration: BoxDecoration(
            color: color ??
                (onPress == null
                    ? ColorValues.primaryColor.withValues(alpha: 76)
                    : ColorValues.primaryColor),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                width: borderWidth ?? 1,
                color: borderColor ?? ColorValues.greyColor),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                prefixIcon == null ? 0.0.sbW : 16.0.sbW,
                prefixIcon == null
                    ? (suffixIcon == null ? 0.0.sbW : 30.0.sbW)
                    : SizedBox(
                        height: 30,
                        width: 30,
                        child: prefixIcon,
                      ),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    label ??
                        AppText(
                          title,
                          size: textSize ?? 15,
                          weight: FontWeight.w700,
                          color: textColor ?? ColorValues.whiteColor,
                        )
                  ],
                )),
                suffixIcon == null
                    ? (prefixIcon == null ? 0.0.sbW : 30.0.sbW)
                    : SizedBox(
                        height: 30,
                        width: 30,
                        child: suffixIcon,
                      ),
                suffixIcon == null ? 0.0.sbW : 16.0.sbW,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
