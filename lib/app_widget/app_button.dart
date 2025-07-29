import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../app_widget/app_text.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool? isTransparent;
  final bool? isGradient;
  final bool? noHeight;
  final bool isSecondary; // New parameter
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
  final bool enabled;

  const AppButton({
    super.key,
    this.enabled = true,
    this.onTap,
    this.isTransparent = false,
    this.isGradient = false,
    this.isSecondary = false, // Default to false
    this.isLoading = false,
    this.noHeight = false,
    this.gradientColors,
    this.child,
    this.width,
    this.borderWidth,
    this.borderRadius,
    this.height,
    this.textSize,
    this.borderColor,
    this.backGroundColor,
    this.textColor,
    this.text,
    this.padding,
    this.isExpanded = true,
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
        onTap: enabled && !isLoading! ? onTap : null,
        borderRadius: BorderRadius.circular(borderRadius ?? 5),
        child: Container(
          height: noHeight == true ? null : height ?? 52,
          width: width,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 5),
            gradient: isGradient == true && !isSecondary
                ? LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: gradientColors ??
                  (enabled && !isLoading!
                      ? [
                    ColorValues.primaryColor,
                    ColorValues.primaryDarkColor,
                  ]
                      : [
                    ColorValues.primaryColor.withValues(alpha: 128),
                    ColorValues.primaryDarkColor.withValues(alpha: 128),
                  ]),
            )
                : null,
            border: Border.all(
              width: borderWidth ?? (isTransparent == true || isSecondary ? 1 : 0),
              color: borderColor ??
                  (isSecondary
                      ? ColorValues.primaryColor // Primary color border for secondary
                      : isTransparent == true
                      ? (enabled && !isLoading!
                      ? ColorValues.primaryColor
                      : ColorValues.primaryColor.withValues(alpha: 128))
                      : Colors.transparent),
            ),
            color: isGradient == true || isSecondary
                ? null
                : isTransparent == true
                ? Colors.transparent
                : backGroundColor != null
                ? (enabled && !isLoading!
                ? backGroundColor
                : backGroundColor!.withValues(alpha: 128))
                : (enabled && !isLoading!
                ? ColorValues.primaryDarkColor
                : ColorValues.primaryDarkColor.withValues(alpha: 128)),
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
                              (isSecondary
                                  ? ColorValues.primaryColor // Primary color text for secondary
                                  : isTransparent == true
                                  ? (enabled && !isLoading!
                                  ? ColorValues.primaryColor
                                  : ColorValues.primaryColor.withOpacity(0.5))
                                  : ColorValues.whiteColor),
                          align: TextAlign.center,
                          size: textSize,
                        ),
                    if (isLoading == true) ...[
                      const SizedBox(width: 10),
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ColorValues.whiteColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
