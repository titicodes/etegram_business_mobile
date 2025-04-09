import 'dart:convert';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/core/model/auth_response.dart';
import 'package:etegram_business/core/model/login_response.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends BaseViewModel {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late BuildContext context;

  Customer? customer;
  String name = '';
  String email = "";

  /// Opens the drawer
  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
    notifyListeners();
  }

  /// Closes the drawer
  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
    notifyListeners();
  }

  /// Fetches user data as a stream
  Stream<Customer?> getUserData() async* {
    yield await authRepository.getUser();
  }

  /// Initializes user data
  Future<void> init() async {
    try {
      customer = await authRepository.getUser () ?? await authRepository.getLocalServiceDetail();

      if (customer != null) {
        print("✅ User fetched: ${customer!.firstName} ${customer!.lastName}");
        userService.getStoreUser ();
        updateFullName();
      } else {
        print("⚠️ Failed to fetch user data from API & local storage");
      }
    } catch (err) {
      print("❌ Error during init: $err");
    }

    notifyListeners();
  }

  /// Refreshes user data
  Future<void> refresh() async {
    try {
      Customer? response = await authRepository.getUser();
      if (response != null) {
        customer = response;
        userService.storeUser(response);
        updateFullName();
      } else {
        print("⚠️ Failed to refresh user data from API");
      }
    } catch (err) {
      print("❌ Error during refresh: $err");
    }
    notifyListeners();
  }

  /// Gets stored service provider details
  Future<void> getStoredServiceProviderDetails() async {
    try {
      Customer? response = await authRepository.getUser();
      if (response != null) {
        customer = response;
        userService.storeUser(response);
        updateFullName();
      } else {
        print("⚠️ Failed to get stored service provider details from API");
      }
    } catch (err) {
      print("❌ Error fetching stored provider details: $err");
    }
    notifyListeners();
  }

  /// Updates the full name of the user
  void updateFullName() {
    name = "${customer?.firstName ?? ""} ${customer?.lastName ?? ""}".trim();
    notifyListeners();
  }

  /// Returns the full name of the user
  String getFullName() => name;
}
