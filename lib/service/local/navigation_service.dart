import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> snackBarKey =
  GlobalKey<ScaffoldMessengerState>();

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  // Future<dynamic> navigateToWidget(Widget route) {
  //   return navigatorKey.currentState!
  //       .push(MaterialPageRoute(builder: (_) => route));
  // }

  Future<dynamic> navigateToWidget(Widget route, {RouteTransitionsBuilder? transitionBuilder}) {
    return navigatorKey.currentState!.push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => route,
        transitionsBuilder: transitionBuilder ?? _defaultTransition,
      ),
    );
  }

  Widget Function(BuildContext, Animation<double>, Animation<double>, Widget) get _defaultTransition =>
          (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      };


  Future<dynamic> navigateAndReplaceWidget(Widget route) {
    return navigatorKey.currentState!
        .pushReplacement(MaterialPageRoute(builder: (_) => route));
  }

  Future<dynamic> navigateToReplace(String routeName, {dynamic argument}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: argument);
  }

  Future<dynamic> navigateToAndRemoveUntil(String routeName,
      {dynamic argument}) {
    return navigatorKey.currentState!
        .pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  goBack({dynamic value}) {
    return navigatorKey.currentState!.pop(value);
  }
}
