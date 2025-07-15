import 'package:etegram_business/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/style.dart';

class Styles {

  static ThemeData themeData() {
    return ThemeData(
        fontFamily: 'NotoSans',
        primaryColor: ColorValues.primaryColor,
        useMaterial3: false,
        primaryColorDark: ColorValues.primaryDarkColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,

        indicatorColor: const Color(0xffCBDCF8),
        // buttonColor:const Color(0xff3B3B3B) : const Color(0xffF1F5FB),

        hintColor: const Color(0xffEECED3),
        splashColor: ColorValues.primaryColor.withOpacity(0.2),
        highlightColor:ColorValues. primaryColor.withOpacity(0.2),
        hoverColor: const Color(0xff4285F4),

        focusColor: const Color(0xffA8DAB5),
        disabledColor: Colors.grey,
        iconTheme: const IconThemeData(
            color: Color.fromRGBO(88, 88, 88, 1)
        ),
        cardColor: Colors.white,
        canvasColor: Colors.grey[50],
        brightness: Brightness.light,
        appBarTheme:  AppBarTheme(
            elevation: 0.0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            color: Colors.white,
            foregroundColor: ColorValues.appTextColor,
            iconTheme: const IconThemeData(color: Colors.black87),
            titleTextStyle: subHeaderTextStyle
        ),
        scaffoldBackgroundColor: Colors.white,
        shadowColor: Colors.grey, colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(background: const Color(0xffF1F5FB))
    );

  }
}