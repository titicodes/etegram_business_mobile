import 'package:etegram_business/module/auth/views/signin_view.dart';
import 'package:etegram_business/module/auth/views/signup_view.dart';
import 'package:etegram_business/module/auth/views/verify_email_view.dart';
import 'package:etegram_business/module/auth/views/widgets/payment_method_view.dart';
import 'package:etegram_business/module/customer/view/birthdays_view.dart';
import 'package:etegram_business/module/customer/view/customers_list_view.dart';
import 'package:etegram_business/module/customer/view/new_customers.dart';
import 'package:etegram_business/module/home/views/home_view.dart';
import 'package:etegram_business/module/home/views/main_nav.dart';
import 'package:etegram_business/module/product/view/barcode_screen.dart';
import 'package:etegram_business/module/product/view/product_search_view.dart';
import 'package:etegram_business/module/product/view/product_view.dart';
import 'package:etegram_business/module/profile/view/profile_view.dart';
import 'package:etegram_business/module/splash/splash_view.dart';
import 'package:etegram_business/module/supply/view/new_supplier.dart';
import 'package:etegram_business/module/welcome/welcome_view.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:flutter/material.dart';

import '../module/auth/views/forget_password_view.dart';
import '../module/onboarding/new_onboarding_view.dart';
import '../module/onboarding/onboarding_view.dart';
import '../module/product/view/product_list_view.dart';

class Routers {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashscreenRoute:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case homeViewRoute:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case loginScreenRoute:
        return MaterialPageRoute(builder: (_) => const SigninView());
      case welcomeScreenRoute:
        return MaterialPageRoute(builder: (_) => const WelcomeView());
      case onBoardingScreenRoute:
        return MaterialPageRoute(builder: (_) => const OnBoardingView());
      case signUpScreenRoute:
        return MaterialPageRoute(builder: (_) => SignupView());
      case mainNavViewRoute:
        return MaterialPageRoute(builder: (_) => MainNav());
      case productViewRoute:
        return MaterialPageRoute(builder: (_) => ProductView());
      case productSearchView:
        return MaterialPageRoute(builder: (_) => ProductSearchView());
      case qrScreen:
        return MaterialPageRoute(builder: (_) => BarcodeScannerScreen());
      case supplyScreen:
        return MaterialPageRoute(builder: (_) => NewSupplierView());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileView());
      case addProductListView:
        return MaterialPageRoute(builder: (_) => AddProductListView());
      case verifyEmailView:
        return MaterialPageRoute(builder: (_) => VerifyEmailView());
      case dashboardRoute:
        return MaterialPageRoute(builder: (_) => MainNav());
      case addPaymentMethodRoute:
        return MaterialPageRoute(builder: (_) => AddPaymentMethodView());
      case listOfCustomersRoute:
        return MaterialPageRoute(builder: (_) => CustomersListView());
      case newCustomerRoute:
        return MaterialPageRoute(builder: (_) => NewCustomers());
      case birthDayRoute:
        return MaterialPageRoute(builder: (_) => BirthdaysView());
      case forgetPasswordRoute:
        return MaterialPageRoute(builder: (_) => ForgetPasswordView());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
