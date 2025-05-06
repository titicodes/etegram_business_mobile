import 'dart:convert';

import 'package:dio/dio.dart';

import '../../constants/app_url.dart';
import '../../core/model/expense_response.dart';
import '../../locator.dart';
import '../local/storage_service.dart';
import '../local/user_service.dart';
import 'base_api.dart';

class ExpensesApiService {
  StorageService storageService = locator<StorageService>();
  CustomerService customerService = locator<CustomerService>();

  Future<ExpenseResponse?> createExpense(ExpenseData expense) async {
    try {
      final Response response = await connect().post(
        AppUrls.getExpenseUrl,
        data: expense.toJsonForCreate(),
      );
      print("Create Expense Response Data: ${response.data}"); // Print the response
      return ExpenseResponse.fromJson(
          json.decode(response.data) as Map<String, dynamic>);
    } on DioException catch (e) {
      print(e.response);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<ExpenseData>?> getAllExpenses() async {
    try {
      final Response response =
          await connect().get(AppUrls.getExpenseUrl); // No userId in URL

      return ExpenseResponse.fromJson(
              json.decode(response.data) as Map<String, dynamic>)
          .data;
    } on DioException catch (e) {
      print('Dio error: ${e.response}');
      return null;
    } catch (e) {
      print('General error: $e');
      return null;
    }
  }

  Future<ExpenseData?> getExpenseById(String id) async {
    final String? userId = await customerService.getOwnerId();
    if (userId == null) {
      print('User ID not found in storage.');
      return null;
    }
    try {
      final Response response = await connect().get(
        '${AppUrls.getExpenseUrl}/$id/$userId',
      );
      final ExpenseResponse responseData = ExpenseResponse.fromJson(
          json.decode(response.data) as Map<String, dynamic>);
      return responseData.data?.isNotEmpty == true
          ? responseData.data!.first
          : null;
    } on DioException catch (e) {
      print(e.response);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<ExpenseResponse?> updateExpense(ExpenseData expense) async {
    try {
      final Response response = await connect().put(
        '${AppUrls.getExpenseUrl}/${expense.id}',
        data: expense.toJson(),
      );
      return ExpenseResponse.fromJson(
          json.decode(response.data) as Map<String, dynamic>);
    } on DioException catch (e) {
      print(e.response);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> deleteExpense(String id) async {
    final String? userId = await customerService.getOwnerId();
    if (userId == null) {
      print('User ID not found in storage.');
      return false;
    }
    try {
      final Response response = await connect().delete(
        '${AppUrls.getExpenseUrl}/$id/$userId',
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.response);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
