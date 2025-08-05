import 'package:etegram_business/constants/app_url.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/service/web/auth_api.dart';
import 'package:get_storage/get_storage.dart';
import '../../constants/reuseable.dart';
import '../../locator.dart';
import '../../utils/snack_message.dart';
import '../local/storage_service.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

StorageService storageService = locator<StorageService>();
AuthenticationApiService auth = locator<AuthenticationApiService>();
String? newToken;

Dio connect() {
  BaseOptions options = BaseOptions(
    baseUrl: AppUrls.baseUrl,
    connectTimeout: const Duration(seconds: 45),
    receiveTimeout: const Duration(seconds: 45),
    responseType: ResponseType.json,
  );
  Dio dio = Dio(options);
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        print("Request URL: ${options.uri.path}");
        print("Request Data: ${options.data.toString()}");
        final box = GetStorage();
        String? token = box.read(DbTable.tokenTableName);
        if (token != null &&
            token.isNotEmpty &&
            options.uri.path != AppUrls.registerUrl) {
          options.headers['Authorization'] = "Bearer $token";
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        print("Response Status: ${response.statusCode}");
        print("Response Data: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        print("Dio Error: ${e.message}");
        if (e.response != null) {
          print("Error Status: ${e.response?.statusCode}");
          print("Error Data: ${e.response?.data}");
          // Skip toast for 404 and 409 to let view models handle
          if (e.response?.statusCode == 404 || e.response?.statusCode == 409) {
            print("Propagating error to view model: ${e.response?.data}");
            return handler.next(e);
          }
          try {
            final errorData = e.response?.data is String
                ? jsonDecode(e.response?.data)
                : e.response?.data;
            final errorMessage = errorData['detail'] ??
                errorData['message'] ??
                "An error occurred";
            if (errorMessage.toString().contains("Invalid token")) {
              print("Invalid token detected, logging out");
              showCustomToast("Session expired. Please log in again.");
              await locator<CustomerService>().logout();
            } else {
              print("Displaying toast from interceptor: $errorMessage");
              showCustomToast(errorMessage);
            }
          } catch (err) {
            print("Error parsing response in interceptor: $err");
            showCustomToast("An error occurred");
          }
        } else {
          print("Network error detected");
          showCustomToast("Network error. Please check your connection.");
        }
        return handler.next(e);
      },
    ),
  );
  return dio;
}

String getTitleFromHtml(String htmlString) {
  RegExp regex = RegExp(r'<title>(.*?)<\/title>');
  Match? match = regex.firstMatch(htmlString);
  if (match != null) {
    return match.group(1)!;
  } else {
    return 'No title found';
  }
}

bool isHtml(String text) {
  RegExp regex = RegExp(r'<[^>]+>');
  return regex.hasMatch(text);
}

bool isJson(String str) {
  try {
    json.decode(str);
    return true;
  } catch (e) {
    return false;
  }
}

Dio privateConnect() {
  BaseOptions options = BaseOptions(
    baseUrl: AppUrls.baseUrl,
    connectTimeout: const Duration(seconds: 45),
    receiveTimeout: const Duration(seconds: 45),
    responseType: ResponseType.plain,
  );
  Dio dio = Dio(options);
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        print("Request URL: ${options.uri.path}");
        print("Request Data: ${options.data.toString()}");
        final box = GetStorage();
        String? value = box.read(DbTable.tokenTableName);
        if (value != null && value.isNotEmpty) {
          options.headers['Authorization'] = "Token $value";
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        print("Response Data: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        print("Dio Error: ${e.message}");
        if (e.response == null) {
          print("Network error detected");
          showCustomToast("Connect Internet to proceed");
          return handler.next(e);
        } else {
          print("Error Status: ${e.response?.statusCode}");
          print("Error Data: ${e.response?.data}");
          // Skip toast for 404 and 409 to let view models handle
          if (e.response?.statusCode == 404 || e.response?.statusCode == 409) {
            print("Propagating error to view model: ${e.response?.data}");
            return handler.next(e);
          }
          try {
            final errorData = e.response?.data is String
                ? jsonDecode(e.response?.data)
                : e.response?.data;
            final errorMessage = errorData['detail'] ??
                errorData['message'] ??
                "An error occurred";
            print("Displaying toast from interceptor: $errorMessage");
            showCustomToast(errorMessage);
          } catch (e) {
            print("Error parsing response in interceptor: $e");
            showCustomToast("An error occurred");
          }
          return handler.next(e);
        }
      },
    ),
  );
  return dio;
}

String displayFirstMessages(Map<String, dynamic> jsonMap) {
  String errorMessage = "";
  List<String> list = [];

  jsonMap.forEach((key, value) {
    if (value is List && value.isNotEmpty) {
      list = [...list, "${value[0]}"];
    }
  });

  for (int i = 0; i < list.length; i++) {
    errorMessage += '• ${list[i]}';
    if (i < list.length - 1) {
      errorMessage += '\n';
    }
  }

  return errorMessage.isEmpty ? "An error occurred" : errorMessage;
}

void handleError(DioException error) {
  if (error.response == null) {
    print("Network error in handleError");
    showCustomToast("An error occurred");
    return;
  }
  try {
    final errorData = error.response?.data is String
        ? jsonDecode(error.response?.data)
        : error.response?.data;
    final errorMessage =
        errorData['detail'] ?? errorData['message'] ?? "An error occurred";
    if (errorMessage.toString().contains("Invalid token")) {
      print("Invalid token detected in handleError, logging out");
      showCustomToast("Session expired. Please log in again.");
      locator<CustomerService>().logout();
    } else {
      print("Displaying toast from handleError: $errorMessage");
      showCustomToast(errorMessage);
    }
  } catch (e) {
    print("Error in handleError: $e");
    showCustomToast("An error occurred");
  }
}
