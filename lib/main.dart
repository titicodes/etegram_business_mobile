import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/firebase_options.dart';
import 'package:etegram_business/routes/routers.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/service/local/navigation_service.dart';
import 'package:etegram_business/styles/app_styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oktoast/oktoast.dart';
import 'package:etegram_business/core/localization/app_localization.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/splash/splash_view.dart';


final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   // FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    await GetStorage.init();
    setupLocator();
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('Main: Initialization error: $e\n$stackTrace');
    }
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
  FlutterError.onError = (details) {
    if (kDebugMode) {
      print('Main: Flutter error: ${details.exception}\n${details.stack}');
    }
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: ScreenUtilInit(
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
            onGenerateRoute: Routers.generateRoute,
            localizationsDelegates: const [
              AppLocalizationDelegate(),
            ],
            supportedLocales: const [
              Locale('en', ''),
            ],
            navigatorObservers: [
              routeObserver,
              FlutterSmartDialog.observer,
            ],
            builder: FlutterSmartDialog.init(),
            initialRoute: splashscreenRoute,
          );
        },
      ),
    );
  }
}