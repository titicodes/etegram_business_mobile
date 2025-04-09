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

connect() {
  BaseOptions options = BaseOptions(
      baseUrl: AppUrls.baseUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
      responseType: ResponseType.plain);
  Dio dio = Dio(options);
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        print("Request URL: ${options.uri.path}");
        print("Request Data: ${options.data.toString()}");
        final box = GetStorage();
        String? token = box.read(DbTable.tokenTableName);
        if (token != null && token.isNotEmpty && options.uri.path != AppUrls.registerUrl) {
          options.headers['Authorization'] = "Bearer $token"; // Use "Bearer" instead of "Token"
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
          try{
            final errorData = jsonDecode(e.response?.data);
            showCustomToast(errorData['detail'] ?? errorData['message'] ?? "An error occurred.");
          }catch(err){
            showCustomToast("An error occurred");
          }
        } else {
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

privateConnect() {
  BaseOptions options = BaseOptions(
      baseUrl: AppUrls.baseUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
      responseType: ResponseType.plain);
  Dio dio = Dio(options);
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // print(options.uri.path);
        // print(options.data.toString());
        final box = GetStorage();
        String? value = box.read(DbTable.tokenTableName);
        // print("ACCESS TOKEN::: $value");
        if (value != null && value.isNotEmpty) {
          options.headers['Authorization'] = "Token $value";
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        // print("SERVER RESPONSE::: ${response.data}");
        return handler.next(response);
      },
      onError: (DioError e, handler) async {
        if(e.response == null){
          showCustomToast("Connect Internet to proceed");
          return handler.next(e);
        }else{
          Map<String, dynamic> jsonMap = {};
          print(e.response?.statusCode);
          print(e.response?.data);
          // print(jsonDecode(jsonEncode(e.response?.data))['detail']);
          print(e.response?.statusMessage);

          // handleError(e);
          jsonMap = jsonDecode(e.response?.data);
          print(jsonMap['detail']);
          if (jsonMap['detail'] == null) {
            showCustomToast(displayFirstMessages(jsonMap));
          } else {
            handleError(e);
          }
          return handler.next(e);
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
}


String displayFirstMessages(Map<String, dynamic> jsonMap) {
  String errorMessage = "";
  List<String> list = [];

  // Extract and display the first message from each list
  jsonMap.forEach((key, value) {
    if (value is List && value.isNotEmpty) {
      list = [...list, "${value[0]}"];
    }
  });

  for (int i = 0; i < list.length; i++) {
    errorMessage += '• ${list[i]}';

    if (i < list.length - 1) {
      // Add line break unless it's the last item
      errorMessage += '\n';
    }
  }

  return errorMessage;
}


void handleError(dynamic error) {
  var errorString = error.response.toString();
  if (error is DioException) {
    switch (error.type) {
      case DioErrorType.cancel:
      // showCustomToast("Request to API server was cancelled");
        break;
      case DioErrorType.connectionError:
      // showCustomToast("Connection timeout with API server");
        break;
      case DioExceptionType.unknown:
        showCustomToast(
            "Please enable internet connection to use ${StringValues.appName} App ");
        break;
      case DioExceptionType.receiveTimeout:
      // showCustomToast("Receive timeout in connection with API server");
        break;
      case DioExceptionType.badResponse:
        final errorMessage = jsonDecode(error.response?.data)["detail"];
        if (errorMessage != null) {
          if (errorMessage.toString().contains("Invalid token")) {
            // showCustomToast(errorMessage);
            locator<CustomerService>().logout();
          } else {
            if(isJson(errorMessage.toString())){
              showCustomToast(jsonDecode(errorMessage["message"]));
            }else{
              showCustomToast(errorMessage.toString());
            }
            print(errorMessage);
          }
        } else {
          print("FINAL DATA=== ${jsonDecode(error.response?.data)["detail"]}");
          showCustomToast(jsonDecode(error.response?.data)["detail"]);
        }
        break;
      case DioErrorType.sendTimeout:
      // showCustomToast("Send timeout in connection with API server");
        break;
      default:
        showCustomToast("Something went wrong");
        break;
    }
  } else {
    var json = jsonDecode(errorString);
    var nameJson = json['message'];
    showCustomToast(nameJson);
    return;
  }
}
