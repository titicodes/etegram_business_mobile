import 'dart:convert';

import 'package:etegram_business/repository/auth_repository.dart';
import 'package:etegram_business/repository/customer_repository.dart';
import 'package:etegram_business/repository/delivery_repository.dart';
import 'package:etegram_business/repository/expenses_repository.dart';
import 'package:etegram_business/repository/payment_method_repository.dart';
import 'package:etegram_business/repository/product_repository.dart';
import 'package:etegram_business/repository/sales_repository.dart';
import 'package:etegram_business/repository/store_repostory.dart';
import 'package:etegram_business/repository/supply_repository.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../locator.dart';
import '../app_widget/action_buttom_sheet.dart';
import '../app_widget/bottom_sheet.dart';
import '../app_widget/popup_dialog.dart';
import '../app_widget/success_pupup_widget.dart';
import '../constants/reuseable.dart';
import '../service/local/cache.dart';
import '../service/local/navigation_service.dart';
import '../service/local/storage_service.dart';

class BaseViewModel extends ChangeNotifier {
  ViewState _viewState = ViewState.idle;
  NavigationService navigationService = locator<NavigationService>();
  StorageService storageService = locator<StorageService>();
  AppCache appCache = locator<AppCache>();
  CustomerService customerService = locator<CustomerService>();
  AuthRepository authRepository = locator<AuthRepository>();
  ProductRepository productRepository = locator<ProductRepository>();
  StoreRepository storeRepository = locator<StoreRepository>();
  SupplyRepository supplyRepository = locator<SupplyRepository>();
  PaymentMethodRepository paymentMethodRepository =
      locator<PaymentMethodRepository>();
  SalesRepository salesRepository = locator<SalesRepository>();
  CustomerRepository customerRepository = locator<CustomerRepository>();
  ExpensesRepository expenseRepository = locator<ExpensesRepository>();
  DeliveryRepository deliveryRepository = locator<DeliveryRepository>();
  // final FlutterContactPicker contactPicker = FlutterContactPicker();

  ViewState get viewState => _viewState;

  final formKey = GlobalKey<FormState>();

  bool isJson(String str) {
    try {
      json.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  int convertToDays(String? input) {
    // Check if the input is null or empty
    if (input == null || input.isEmpty) {
      return 0;
    }

    // Convert the input string to lowercase for case-insensitive comparison
    String lowerCaseInput = input.toLowerCase();

    // Check if the input string contains keywords and return corresponding days
    if (lowerCaseInput.contains('yearly')) {
      return 365; // Assuming a year has 365 days
    } else if (lowerCaseInput.contains('monthly')) {
      return 30; // Assuming a month has 30 days
    } else if (lowerCaseInput.contains('1 month')) {
      return 30; // Assuming a month has 30 days
    } else if (lowerCaseInput.contains('2 month')) {
      return 60; // Assuming a month has 30 days
    } else if (lowerCaseInput.contains('2 month')) {
      return 60; // Assuming a month has 30 days
    } else if (lowerCaseInput.contains('3 month')) {
      return 90; // Assuming a month has 30 days
    } else if (lowerCaseInput.contains('4 month')) {
      return 120; // Assuming a month has 30 days
    } else if (lowerCaseInput.contains('quarterly')) {
      return 90; // Assuming a quarter has 90 days
    } else if (lowerCaseInput.contains('daily')) {
      return 1; // Daily means 1 day
    } else {
      // Return -1 or any other value to indicate that the input is not recognized
      return 0;
    }
  }

  String calculateTimeAgo(String timestamp) {
    DateTime now = DateTime.now();
    DateTime parsedTime = DateTime.parse(timestamp);
    Duration difference = now.difference(parsedTime);

    // Calculate the number of days ago
    int days = difference.inDays;

    return '$days days ago';
  }

  String formatDate(String timestamp) {
    DateTime parsedTime = DateTime.parse(timestamp);
    DateFormat formatter = DateFormat('dd/MM/yyyy');
    String formattedDate = formatter.format(parsedTime);
    return formattedDate;
  }

  // changePin()async{
  //   cache.comingFromChangePin = true;
  //   showModalBottomSheet(
  //     backgroundColor: Colors.transparent,
  //     context: navigationService.navigatorKey.currentState!.context,
  //     isScrollControlled: true,
  //     isDismissible: false,
  //     builder: (_) => const BottomSheetScreen(child: VerifyPasswordScreen()),
  //   );
  // }

  set viewState(ViewState newState) {
    _viewState = newState;
    _viewState == ViewState.busy ? isLoading = true : isLoading = false;
    notifyListeners();
  }

  goBack() {
    navigationService.goBack();
  }

  // logOuts(BuildContext context) {
  //   popDialog(context: context, onTap: userService.logout, title: "Log out");
  // }

  bool isLoading = false;

  void startLoader() {
    if (!isLoading) {
      isLoading = true;
      viewState = ViewState.busy;
      notifyListeners();
    }
  }

  popUp(String title, Function onTap, {String? subtitle}) async {
    BuildContext context = navigationService.navigatorKey.currentState!.context;
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => BottomSheetScreen(
          child: PopUpDialog(
        title: title,
        onTap: onTap,
        subTitle: subtitle,
      )),
    );
  }

  showSuccess(String title, String subtitle) {
    BuildContext context = navigationService.navigatorKey.currentState!.context;
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => BottomSheetScreen(
          child: SuccessfulPopUpWidget(
        title: title.toTitleCase(),
        subTitle: subtitle,
        onTap: navigationService.goBack,
        buttonText: "OK",
        titleColor: Colors.black,
      )),
    );
  }

  Map<String, dynamic> filterNullValues(Map<String, dynamic> data) {
    Map<String, dynamic> filteredData = {};

    data.forEach((key, value) {
      if (value != null) {
        filteredData[key] = value;
      }
    });

    return filteredData;
  }

  Future<bool> checkAndRequestStoragePermission() async {
    PermissionStatus permissionStatus = await Permission.storage.status;
    if (permissionStatus.isGranted) {
      return true;
      // Permission is already granted
    } else if (permissionStatus.isDenied ||
        permissionStatus.isPermanentlyDenied) {
      // Permission is denied, request it
      PermissionStatus requestResult = await Permission.storage.request();
      if (requestResult.isGranted) {
        // Permission granted
        return true;
      } else {
        // Permission denied
        return false;
      }
    } else {
      return false;
    }
  }

  String getFileTypeFromUrl(String url) {
    List<String> parts = url.split('/');
    String fileName = parts.last;
    List<String> fileNameParts = fileName.split('.');

    if (fileNameParts.length > 1) {
      String extension = fileNameParts.last;
      switch (extension.toLowerCase()) {
        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'svg':
        case 'heic':
        case 'webp':
          return 'image.${extension.toLowerCase()}';
        case 'mp4':
        case 'avi':
        case 'mov':
          return 'video.${extension.toLowerCase()}';
        case 'pdf':
          return 'PDF.${extension.toLowerCase()}';
        case 'docx':
        case 'doc':
          return 'Document.${extension.toLowerCase()}';
        default:
          return 'Unknown';
      }
    } else {
      return 'Unknown';
    }
  }

  popDialog({
    required BuildContext context,
    required VoidCallback onTap,
    VoidCallback? otherOnTap,
    required String title,
    String? subTitle,
    String? cancelButtonText,
    String? doItButtonText,
    Widget? prefixIcon1,
    Widget? prefixIcon2,
  }) async {
    showBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        enableDrag: false,
        builder: (BuildContext context) => ActionBottomSheet(
              onTap: onTap,
              title: title,
              subTitle: subTitle,
              cancelButtonText: cancelButtonText,
              doItButtonText: doItButtonText,
              prefixIcon1: prefixIcon1,
              prefixIcon2: prefixIcon2,
              otherOnTap: otherOnTap,
            ));
  }

  void stopLoader() {
    if (isLoading) {
      isLoading = false;
      viewState = ViewState.idle;
      notifyListeners();
    }
  }
}

class NumericTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Use a regular expression to remove non-numeric characters
    final filteredValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    return TextEditingValue(
      text: filteredValue,
      selection: TextSelection.collapsed(offset: filteredValue.length),
    );
  }
}
