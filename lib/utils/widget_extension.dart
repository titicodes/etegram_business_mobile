import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//TODO: uncomment if using a pdf functionality
// import 'package:pdf/pdf.dart';

const ext = 0;

double screenHeight(BuildContext context, double height) {
  return MediaQuery.of(context).size.height / height;
}

double screenWidth(BuildContext context, double width) {
  return MediaQuery.of(context).size.width / width;
}
double screenSize(BuildContext context, double pixel){
  double xHeight = pixel / MediaQuery.of(context).size.width * 100;
  return MediaQuery.of(context).size.width * xHeight /100;
}

extension WidgetExtensions on double {
  Widget get sbH => SizedBox(
    height: h,
  );

  Widget get sbW => SizedBox(
    width: w,
  );

  Widget get sbHW => SizedBox(
    width: w,
    height: h,
  );

  EdgeInsetsGeometry get padA => EdgeInsets.all(this);

  EdgeInsetsGeometry get padV => EdgeInsets.symmetric(vertical: h);
  EdgeInsetsGeometry get padT => EdgeInsets.only(top: h);
  EdgeInsetsGeometry get padL => EdgeInsets.only(left: h);
  EdgeInsetsGeometry get padR => EdgeInsets.only(right: h);
  EdgeInsetsGeometry get padB => EdgeInsets.only(bottom: h);

  EdgeInsetsGeometry get padH => EdgeInsets.symmetric(horizontal: w);
}

class SpaceH extends StatelessWidget {
  final double h;
  const SpaceH(this.h,{super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: h/MediaQuery.of(context).devicePixelRatio,
    );
  }
}

class SpaceW extends StatelessWidget {
  final double w;
  const SpaceW(this.w,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w/MediaQuery.of(context).devicePixelRatio,
    );
  }
}


double width(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double height(BuildContext context) {
  return MediaQuery.of(context).size.height;
}
