import 'package:flutter/material.dart';

import '../constants/style.dart';


class AppText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextOverflow? overflow;
  final double? size;
  final double? height;
  final int? maxLine;
  final String? family;
  final bool? isBold;
  final bool? isHeader;
  final bool? isSubHeader;
  final TextStyle? style;
  final Locale? locale;
  final FontWeight? weight;
  final TextAlign? align;

  const AppText(this.text,
      {super.key,
        this.color,
        this.overflow,
        this.size,
        this.weight,
        this.align,
        this.maxLine,
        this.locale,
        this.height,
        this.family,
        this.style,
        this.isBold, this.isHeader, this.isSubHeader});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? normalTextStyle.copyWith(
          color: isHeader==true? const Color(0xFF585858): isSubHeader==true? const Color(0xFF999999): color,
          fontSize: size,
          height: height,
          fontFamily: family,
          fontWeight: weight ?? (isBold == true ? FontWeight.w600 : isSubHeader==true? FontWeight.w500: null)
      ),
      textAlign: align ?? TextAlign.start,
      selectionColor: Colors.grey.withOpacity(0.5),
      maxLines: maxLine,
    );
  }
}
