//Loading State
import 'package:etegram_business/service/local/user_service.dart';
import 'package:flutter/material.dart';

import '../locator.dart';
import '../service/local/navigation_service.dart';

enum ViewState { idle, busy }

NavigationService navigationService = locator<NavigationService>();
CustomerService userService = locator<CustomerService>();

class DbTable {
  static const String customerTableName = 'customer';
  static const String otp = 'otp';
  static const String tokenTableName = 'token';
  static const String appFirstTimeTableName = 'isFirstTime';
  static const String onboardingTableName = 'onboarding';
  static const String loginTableName = 'login';
  static const String pinTableName = 'savePin';
  static const String passwordTableName = 'password';
  static const String emailTableName = 'email';
  static const String firstNameTableName = 'firstName';
  static const String paymentMethodTable = 'paymentMethod';
  static const String productTableName = "productTable";
  static const String storeTableName = "storesTable";
  static const String supplierTableName = "supplyTable";
  static const String activeStoreId = "activeStoreId";
}

class Sized16Container extends StatelessWidget {
  final Widget? child;
  final Decoration? decoration;

  const Sized16Container({super.key, this.child, this.decoration});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: child,
    );
  }
}
