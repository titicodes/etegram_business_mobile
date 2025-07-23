import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../constants/style.dart';

class CustomDropDown extends StatelessWidget {
  const CustomDropDown({
    super.key,
    this.alignment,
    this.width,
    this.margin,
    this.focusNode,
    this.icon,
    this.autofocus = true,
    this.textStyle,
    this.items,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = false,
    this.validator,
    this.onChanged,
    this.value, // <--- ADD THIS PARAMETER
  });

  final Alignment? alignment;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final FocusNode? focusNode;
  final Widget? icon;
  final bool? autofocus;
  final TextStyle? textStyle;
  final List<String>? items;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? prefix;
  final BoxConstraints? prefixConstraints;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final EdgeInsets? contentPadding;
  final InputBorder? borderDecoration;
  final Color? fillColor;
  final bool? filled;
  final FormFieldValidator<String>? validator;
  final Function(String)? onChanged;
  final String? value; // <--- ADD THIS FIELD

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment ?? Alignment.center,
      child: dropDownWidget,
    )
        : dropDownWidget;
  }

  Widget get dropDownWidget => Container(
    width: width ?? double.maxFinite,
    margin: margin,
    padding: EdgeInsets.all(3.sp),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.sp)),
    child: DropdownButtonFormField<String>( // <--- Explicitly type DropdownButtonFormField
      isExpanded: true,
      focusNode: focusNode ?? FocusNode(),
      icon: icon,
      autofocus: autofocus!,
      style: textStyle ??
          titleSmall.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
      // Set the value here using the new parameter
      value: value, // <--- PASS THE VALUE HERE
      items: items?.map<DropdownMenuItem<String>>((String itemValue) { // Renamed 'value' to 'itemValue' for clarity within map
        return DropdownMenuItem<String>(
          value: itemValue, // Use itemValue here
          child: Container(
            width: double.infinity,
            child: Text(
              itemValue, // Use itemValue here
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: hintStyle ??
                  titleSmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: ColorValues.greyColor),
            ),
          ),
        );
      }).toList(),
      decoration: decoration,
      validator: validator,
      onChanged: (newValue) { // Renamed 'value' to 'newValue' for clarity
        if (onChanged != null && newValue != null) { // Null check for onChanged
          onChanged!(newValue);
        }
      },
    ),
  );

  InputDecoration get decoration => InputDecoration(
    hintText: hintText != null ? "  $hintText" : "", // Safer null check
    hintStyle:
    hintStyle ?? normalTextStyle.copyWith(fontWeight: FontWeight.w500),
    prefixIcon: prefix,
    prefixIconConstraints: prefixConstraints,
    suffixIcon: suffix,
    suffixIconConstraints: suffixConstraints,
    isDense: true,
    contentPadding: contentPadding ?? EdgeInsets.symmetric(vertical: 10.h),
    fillColor: fillColor,
    filled: filled,
    border: borderDecoration ??
        OutlineInputBorder(
          borderSide: BorderSide(
            color: gray4001e,
            width: 0,
          ),
        ),
    enabledBorder: borderDecoration ??
        OutlineInputBorder(
          borderSide: BorderSide(
            color: gray4001e,
            width: 0,
          ),
        ),
    focusedBorder: borderDecoration ??
        OutlineInputBorder(
          borderSide: BorderSide(
            color: gray4001e,
            width: 0,
          ),
        ),
  );
}

/// Extension on [CustomDropDown] to facilitate inclusion of all types of border style etc
extension DropDownStyleHelper on CustomDropDown {
  static OutlineInputBorder get fillGray => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.h),
    borderSide: BorderSide.none,
  );
}

// var gray4001e = const Color(0X1ECBC8C8);
var gray4001e = ColorValues.backgroundColor;