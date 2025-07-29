//
//
// import 'package:etegram_business/module/auth/views/signin_view.dart';
// import 'package:etegram_business/module/auth/views/signup_view.dart';
// import 'package:etegram_business/module/auth/views/verify_email_view.dart';
// import 'package:etegram_business/module/auth/views/widgets/payment_method_view.dart';
// import 'package:etegram_business/module/home/views/home_view.dart';
// import 'package:etegram_business/module/home/views/how_it_works_view.dart';
// import 'package:etegram_business/module/home/views/main_nav.dart';
// import 'package:etegram_business/module/product/view/add_product.dart';
// import 'package:etegram_business/module/product/view/product_view.dart';
// import 'package:etegram_business/module/product/view/product_list_view.dart';
// import 'package:etegram_business/module/product/view/product_details_view.dart';
// import 'package:etegram_business/module/profile/view/profile_view.dart';
// import 'package:etegram_business/module/sales/view/owning_records.dart';
// import 'package:etegram_business/module/sales/view/sales_list.dart';
// import 'package:etegram_business/module/splash/splash_view.dart';
// import 'package:etegram_business/module/stores/views/new_stores.dart';
// import 'package:etegram_business/module/supply/view/new_supplier.dart';
// import 'package:etegram_business/module/auth/views/forget_password_view.dart';
// import 'package:etegram_business/module/onboarding/onboarding_view.dart';
// import 'package:etegram_business/module/sales/view/scan_to_checkout.dart';
// import 'package:etegram_business/core/model/product_model.dart';
// import 'package:etegram_business/module/welcome/welcome_view.dart';
// import 'package:etegram_business/routes/routes.dart';
// import 'package:flutter/material.dart';
// import '../app_widget/add_product_scanner.dart';
// import '../app_widget/new.dart';
// import '../core/model/customer_response.dart';
// import '../core/model/get_scan_response.dart';
// import '../module/customer/views/birth_day_view.dart';
// import '../module/customer/views/customer_list_view.dart';
// import '../module/customer/views/new_customer.dart';
// import '../module/sales/view/widgets/payment_screen.dart';
// import '../module/sales/vm/review_screen.dart';
// import '../module/subscription/view/subscription_view.dart';
// import '../module/account/views/notification_view.dart';
//
// class Routers {
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     print(
//         'Router: Navigating to ${settings.name} with arguments: ${settings.arguments}');
//     switch (settings.name) {
//       case splashscreenRoute:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
//       case homeViewRoute:
//         return MaterialPageRoute(builder: (_) => const HomeView());
//       case loginScreenRoute:
//         return MaterialPageRoute(builder: (_) => const SigninView());
//       case welcomeScreenRoute:
//         return MaterialPageRoute(builder: (_) => const WelcomeView());
//       case onBoardingScreenRoute:
//         return MaterialPageRoute(builder: (_) => const OnBoardingScreen());
//       case signUpScreenRoute:
//         return MaterialPageRoute(
//           builder: (_) => SignupView(
//               arguments: settings.arguments as Map<String, dynamic>?),
//         );
//       case mainNavViewRoute:
//         return MaterialPageRoute(builder: (_) => MainNav());
//       case productViewRoute:
//         return MaterialPageRoute(builder: (_) => ProductView());
//       case supplyScreen:
//         return MaterialPageRoute(builder: (_) => NewSupplierView());
//       case profile:
//         return MaterialPageRoute(builder: (_) => ProfileView());
//       case addProductListView:
//         return MaterialPageRoute(builder: (_) => AddProductListView());
//       case verifyEmailView:
//         return MaterialPageRoute(builder: (_) => VerifyEmailView());
//       case dashboardRoute:
//         return MaterialPageRoute(builder: (_) => MainNav());
//       case addPaymentMethodRoute:
//         return MaterialPageRoute(builder: (_) => AddPaymentMethodView());
//       case forgetPasswordRoute:
//         return MaterialPageRoute(builder: (_) => ForgetPasswordView());
//       case subscriptionRoute:
//         return MaterialPageRoute(builder: (_) => const SubscriptionView());
//       case createStoreRoute:
//         return MaterialPageRoute(builder: (_) => NewStores());
//       case addProductViewRoute:
//         final args = settings.arguments as Map<String, dynamic>?;
//         return MaterialPageRoute(
//           builder: (_) => AddProductView(
//             isEditing: args?['isEditing'] as bool? ?? false,
//             scannedCode: args?['scannedCode'] as String?,
//             product: args?['product'] as Product?,
//             storeId: args?['storeId'] as String?,
//             ownerId: args?['ownerId'] as String?,
//           ),
//         );
//       case addProductScannerRoute:
//         return MaterialPageRoute(builder: (_) => const AddProductScannerView());
//       case productDetailsViewRoute:
//         final args = settings.arguments as Map<String, dynamic>?;
//         return MaterialPageRoute(
//           builder: (_) => ProductDetailsView(
//             product: args?['product'] as Product,
//           ),
//         );
//       case scanToCheckoutRoute:
//         return MaterialPageRoute(builder: (_) => ScanToCheckoutView());
//       case reviewScreenRoute:
//         final args = settings.arguments as Map<String, dynamic>?;
//         return MaterialPageRoute(
//           builder: (_) => ReviewScreen(
//             cartItems: args?['cartItems'] as List<Cart>? ?? [],
//           ),
//         );
//       case paymentScreenRoute:
//         final args = settings.arguments as Map<String, dynamic>?;
//         return MaterialPageRoute(
//           builder: (_) => PaymentScreen(
//             totalAmount: args?['totalAmount'] as double,
//             cartItems: args?['cartItems'] as List<Cart>,
//           ),
//         );
//       case customersListRoute:
//         return MaterialPageRoute(builder: (_) => CustomersListView());
//       case newCustomersRoute:
//         final args = settings.arguments as Map<String, dynamic>?;
//         return MaterialPageRoute(
//           builder: (_) =>
//               NewCustomers(customer: args?['customer'] as CustomerData?),
//         );
//       case birthdaysRoute:
//         return MaterialPageRoute(builder: (_) => BirthdaysView());
//       case salesListRoute:
//         return MaterialPageRoute(builder: (_) => SalesList());
//       case owningRecordsRoute:
//         return MaterialPageRoute(builder: (_) => OwningRecords());
//       case howItWorksRoute:
//         return MaterialPageRoute(builder: (_) => HowItWorksView());
//       case notificationViewRoute:
//         return MaterialPageRoute(builder: (_) => const NotificationView());
//       default:
//         return MaterialPageRoute(
//           builder: (_) => Scaffold(
//             body: Center(
//               child: Text('No route defined for ${settings.name}'),
//             ),
//           ),
//         );
//     }
//   }
// }

import 'package:etegram_business/module/auth/views/signin_view.dart';
import 'package:etegram_business/module/auth/views/signup_view.dart';
import 'package:etegram_business/module/auth/views/verify_email_view.dart';
import 'package:etegram_business/module/auth/views/widgets/payment_method_view.dart';
import 'package:etegram_business/module/home/views/home_view.dart';
import 'package:etegram_business/module/home/views/how_it_works_view.dart';
import 'package:etegram_business/module/home/views/main_nav.dart';
import 'package:etegram_business/module/product/view/add_product.dart'; // This is your AddProductView
import 'package:etegram_business/module/product/view/product_view.dart';
import 'package:etegram_business/module/product/view/product_list_view.dart';
import 'package:etegram_business/module/product/view/product_details_view.dart';
import 'package:etegram_business/module/profile/view/profile_view.dart';
import 'package:etegram_business/module/sales/view/owning_records.dart';
import 'package:etegram_business/module/sales/view/sales_list.dart';
import 'package:etegram_business/module/splash/splash_view.dart';
import 'package:etegram_business/module/stores/views/new_stores.dart';
import 'package:etegram_business/module/supply/view/new_supplier.dart';
import 'package:etegram_business/module/auth/views/forget_password_view.dart';
import 'package:etegram_business/module/onboarding/onboarding_view.dart';
import 'package:etegram_business/module/sales/view/scan_to_checkout.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/module/welcome/welcome_view.dart';
import 'package:etegram_business/routes/routes.dart'; // Assuming your route constants are here
import 'package:flutter/material.dart';
import '../app_widget/add_product_scanner.dart'; // Assuming AddProductScannerView is here
import '../app_widget/new.dart'; // Unused import?
import '../core/model/customer_response.dart';
import '../core/model/get_scan_response.dart'; // For Cart model
import '../module/customer/views/birth_day_view.dart';
import '../module/customer/views/customer_list_view.dart';
import '../module/customer/views/new_customer.dart';
import '../module/sales/view/widgets/payment_screen.dart';
import '../module/sales/vm/review_screen.dart';
import '../module/subscription/view/subscription_view.dart';
import 'package:etegram_business/module/account/views/notification_view.dart';

class Routers {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print(
        'Router: Navigating to ${settings.name} with arguments: ${settings.arguments}');
    switch (settings.name) {
      case splashscreenRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case homeViewRoute:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case loginScreenRoute:
        return MaterialPageRoute(builder: (_) => const SigninView());
      case welcomeScreenRoute:
        return MaterialPageRoute(builder: (_) => const WelcomeView());
      case onBoardingScreenRoute:
        return MaterialPageRoute(builder: (_) => const OnBoardingScreen());
      case signUpScreenRoute:
        return MaterialPageRoute(
          builder: (_) => SignupView(
              arguments: settings.arguments as Map<String, dynamic>?),
        );
      case mainNavViewRoute:
        return MaterialPageRoute(builder: (_) => MainNav());
      case productViewRoute:
        return MaterialPageRoute(builder: (_) => ProductView());
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
      case forgetPasswordRoute:
        return MaterialPageRoute(builder: (_) => ForgetPasswordView());
      case subscriptionRoute:
        return MaterialPageRoute(builder: (_) => const SubscriptionView());
      case createStoreRoute:
        return MaterialPageRoute(builder: (_) => NewStores());

      // *** THIS IS THE CORRECTED BLOCK ***
      case addProductViewRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddProductView(
            isEditing: args?['isEditing'] as bool? ?? false,
            scannedCode: args?['scannedCode'] as String?,
            product:
                args?['product'] as Product?, // For editing an existing product
            storeId: args?['storeId'] as String?,
            ownerId: args?['ownerId'] as String?,
            externalProduct:
                args?['externalProduct'] as Product?, // <-- ADDED THIS LINE
            needsImageSelection: args?['needsImageSelection'] as bool? ??
                false, // <-- ADDED THIS LINE
          ),
        );
      // *** END OF CORRECTED BLOCK ***

      case addProductScannerRoute:
        // Ensure this import points to your new scanner view if it's different
        return MaterialPageRoute(builder: (_) => const AddProductScannerView());
      case productDetailsViewRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        // Added null check for 'product' key and fallback
        if (args != null && args.containsKey('product')) {
          return MaterialPageRoute(
            builder: (_) => ProductDetailsView(
              product: args['product'] as Product,
            ),
          );
        }
        return MaterialPageRoute(
            builder: (_) =>
                const Text('Error: Product not provided for details view'));
      case scanToCheckoutRoute:
        return MaterialPageRoute(builder: (_) => ScanToCheckoutView());
      case reviewScreenRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ReviewScreen(
            cartItems: args?['cartItems'] as List<Cart>? ??
                [], // Ensure Cart is imported
          ),
        );
      case paymentScreenRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        // Added null checks and default for double
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            totalAmount:
                args?['totalAmount'] as double? ?? 0.0, // Added null coalescing
            cartItems: args?['cartItems'] as List<Cart>? ??
                [], // Added null coalescing
          ),
        );
      case customersListRoute:
        return MaterialPageRoute(builder: (_) => CustomersListView());
      case newCustomersRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              NewCustomers(customer: args?['customer'] as CustomerData?),
        );
      case birthdaysRoute:
        return MaterialPageRoute(builder: (_) => BirthdaysView());
      case salesListRoute:
        return MaterialPageRoute(builder: (_) => SalesList());
      case owningRecordsRoute:
        return MaterialPageRoute(builder: (_) => OwningRecords());
      case howItWorksRoute:
        return MaterialPageRoute(builder: (_) => HowItWorksView());
      case notificationViewRoute:
        return MaterialPageRoute(builder: (_) => const NotificationView());
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
