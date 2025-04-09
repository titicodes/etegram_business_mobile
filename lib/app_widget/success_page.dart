import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/home/views/main_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 184,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 16),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: ColorValues.primaryColor, backgroundColor: ColorValues.backgroundColor, padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  'Your Operations',
                  style: normalTextStyle,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainNav()));
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 18), backgroundColor: ColorValues.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  'Continue Shopping',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18, fontFamily: 'poppins'),
                ),
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 124,
              height: 124,
              margin: EdgeInsets.only(bottom: 32),
              child: SvgPicture.asset('assets/icons/Success.svg'),
            ),
            Text(
              'Order Success! 😆',
              style: TextStyle(
                color: ColorValues.primaryDarkColor,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'poppins',
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Text(
                'We have received your order',
                style: TextStyle(color: ColorValues.backgroundColor.withOpacity(0.8)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
