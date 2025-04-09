import 'dart:io';

import 'package:etegram_business/utils/validator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;


const ext = 0;
final formatCurrency =
NumberFormat.simpleCurrency(locale: Platform.localeName, name: 'NGN');

//Formats the amount and returns a formatted amount
String formatPrice(String amount) {
  return formatCurrency.format(num.parse(amount)).toString();
}

extension StringCasingExtension on String {
  String? camelCase() => toBeginningOfSentenceCase(this);

  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');

  String? trimToken() => contains(":") ? split(":")[1].trim() : this;

  String? trimSpaces() => replaceAll(" ", "");
}

extension ImagePath on String {
  String get svg => 'assets/svg/$this.svg';

  String get png => 'assets/images/$this.png';

  String get jpg => 'assets/images/$this.jpg';
}

String decodeErrorMessage(Map map) {
  String? errorMessage = "";
  map.forEach((key, value) {
    errorMessage = "${errorMessage!}- ${map[key].toString().replaceAll("]", "").replaceAll("[", "")}\n";
  });
  return errorMessage!;
}

extension NumExtensions on int {
  num addPercentage(num v) => this + ((v / 100) * this);

  num getPercentage(num v) => ((v / 100) * this);
}

extension NumExtensionss on num {
  num addPercentage(num v) => this + ((v / 100) * this);

  num getPercentage(num v) => ((v / 100) * this);
}

void openUrl({String? url}) {
  launchUrl(Uri.parse("http://$url"));
}

void openMailApp({String? receiver, String? title, String? body}) {
  launchUrl(Uri.parse("mailto:$receiver?subject=$title&body=$body"));
}

String trimPhone(String? phone) {
  if (phone![4] == "0") {
    List v = phone.split("").toList();
    v.removeAt(4);
    return v.join("").toString();
  } else {
    return phone;
  }
}

String formatPhoneNumber(String phoneNumber) {
  // Remove the country code (assuming it's always +234 for Nigeria)
  String withoutCountryCode = phoneNumber.substring(4);

  // If the number starts with '0', remove it
  if (withoutCountryCode.startsWith('0')) {
    withoutCountryCode = withoutCountryCode.substring(1);
  }

  return "0$withoutCountryCode";
}

String? Function(String?)? emailValidator = (String? val) {
  String validate = val!.replaceAll(RegExp(r"\s+"), "");
  if (validate.isEmpty ||
      !RegExp(emailRegex).hasMatch(validate)) {
    return 'Enter valid email';
  }
  return null; // Return null for valid input
};

String? Function(String?)? passwordValidator = (String? val) {
  RegExp regEx = RegExp(r"(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])\w+");
  if(val!.length<6){
    return "Enter a password of more than 6 characters";
  }else if(regEx.hasMatch(val)==false){
    return "Your Password must have a capital letter small letter and number";
  }
  return null;
};

String? Function(String?)? emptyValidator = (String? val) {
  String value = val??"";
  if(value.trim().isEmpty){
    return "value cannot be empty";
  }
  return null;
};

bool validateFullName(String input) {
  // Regular expression pattern
  RegExp regex = RegExp(r'^[A-Za-z]{2,}(?:\s[A-Za-z]{2,})+$');

  // Test the input against the pattern
  return regex.hasMatch(input);
}

bool isEightDigitPhoneNumber(String input) {
  final RegExp regex = RegExp(r'^\d{11}$');
  return regex.hasMatch(input);
}

String? validatePhoneNumber(String? value) {
  if (!isEightDigitPhoneNumber(value!)) {
    return 'Please enter a valid 8-digit phone number';
  }
  return null; // Input is valid
}

String? fullNameValidator(String? value) {
  if(value==null){
    return "Full name cannot be empty";
  }else if(validateFullName(value)){
    return "Full Name not Valid";
  }
  return null;
}


List<String> convertDynamicListToStringList(List<dynamic> dynamicList) {
  List<String> stringList = [];

  for (var item in dynamicList) {
    if (item is String) {
      stringList.add(item);
    } else {
      // Convert the item to a String and add it to the list
      stringList.add(item.toString());
    }
  }

  return stringList;
}

String formatErrorMessageList(List<String> errorMessages) {
  if (errorMessages.isEmpty) {
    return ""; // Return an empty string if the list is empty
  }

  // Use a StringBuffer to efficiently build the formatted string
  StringBuffer formattedString = StringBuffer();

  for (int i = 0; i < errorMessages.length; i++) {
    String errorMessage = errorMessages[i];
    formattedString.write("• "); // Add a bullet point

    if (i == errorMessages.length - 1) {
      formattedString.write(errorMessage); // Add the error message without a new line
    } else {
      formattedString.writeln(errorMessage); // Add the error message with a new line
    }
  }

  return formattedString.toString(); // Convert the StringBuffer to a String
}

extension StringExtensions on String {
  bool isValidEmail() {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(this);
  }
}
