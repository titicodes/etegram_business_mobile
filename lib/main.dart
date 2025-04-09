import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/module/splash/splash_view.dart';
import 'package:etegram_business/routes/routers.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/service/local/navigation_service.dart';
import 'package:etegram_business/styles/app_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oktoast/oktoast.dart';

import 'core/localization/app_localization.dart';
import 'locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make app always in portrait
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  // Change status bar theme based on theme of app
  SystemChrome.setSystemUIOverlayStyle( const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await GetStorage.init();

  // set up locator services
  await setupLocator();

  runApp(const MyApp());
      (dynamic error, dynamic stack) {
    if (kDebugMode) {
      print(error);
      print(stack);
    }
  };
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: ScreenUtilInit(
          //setup to fit into bigger screens
          designSize: const Size(390, 844),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (BuildContext context, Widget? child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: Styles.themeData(),
              navigatorKey: locator<NavigationService>().navigatorKey,
              scaffoldMessengerKey: locator<NavigationService>().snackBarKey,
              title: StringValues.appName,
              // theme: Styles.themeData(context),
              onGenerateRoute: Routers.generateRoute,
              localizationsDelegates: const [
                AppLocalizationDelegate(),
                // GlobalMaterialLocalizations.delegate,
                // GlobalWidgetsLocalizations.delegate,
                // GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale(
                  'en',
                  '',
                ),
              ],
              navigatorObservers: [FlutterSmartDialog.observer],
              builder: FlutterSmartDialog.init(),
              initialRoute: splashscreenRoute,
            );
          },
        ));
  }
}
