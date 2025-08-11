import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> snackBarKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    print('NavigationService: navigateTo $routeName, arguments: $arguments');
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateToWidget(Widget route,
      {RouteTransitionsBuilder? transitionBuilder}) {
    print('NavigationService: navigateToWidget ${route.runtimeType}');
    return navigatorKey.currentState!.push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => route,
        transitionsBuilder: transitionBuilder ?? _defaultTransition,
      ),
    );
  }

  Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)
      get _defaultTransition =>
          (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          };

  Future<dynamic> navigateAndReplaceWidget(Widget route) {
    print('NavigationService: navigateAndReplaceWidget ${route.runtimeType}');
    return navigatorKey.currentState!
        .pushReplacement(MaterialPageRoute(builder: (_) => route));
  }

  Future<dynamic> navigateToReplace(String routeName, {dynamic argument}) {
    print(
        'NavigationService: navigateToReplace $routeName, argument: $argument');
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: argument);
  }

  Future<dynamic> navigateToAndRemoveUntil(String routeName,
      {dynamic argument}) {
    print(
        'NavigationService: navigateToAndRemoveUntil $routeName, argument: $argument');
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: argument,
    );
  }

  void goBack({dynamic value}) {
    print('NavigationService: goBack, value: $value');
    return navigatorKey.currentState!.pop(value);
  }

  Future<dynamic> navigateToWidgetAndRemoveUntil(Widget route) {
    print(
        'NavigationService: navigateToWidgetAndRemoveUntil ${route.runtimeType}');
    return navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => route),
      (Route<dynamic> route) => false,
    );
  }
}
