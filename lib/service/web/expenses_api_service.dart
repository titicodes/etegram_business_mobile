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
      Response response = await connect().post(
        AppUrls.getExpenseUrl,
        data: expense.toJson(),
      );
      return ExpenseResponse.fromJson(json.decode(response.data));
    } on DioException catch (e) {
      print(e.response);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<ExpenseData>?> getAllExpenses(String userId) async {
    try {
      Response response = await connect().get(
        '${AppUrls.getExpenseUrl}/$userId',
      );
      return ExpenseResponse.fromJson(json.decode(response.data)).data;
    } on DioException catch (e) {
      print(e.response);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<ExpenseData?> getExpenseById(String id, String userId) async {
    try {
      Response response = await connect().get(
        '${AppUrls.getExpenseUrl}/$id/$userId',
      );
      return ExpenseResponse.fromJson(json.decode(response.data)).data?.first;
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
      Response response = await connect().put(
        '${AppUrls.getExpenseUrl}/${expense.id}',
        data: expense.toJson(),
      );
      return ExpenseResponse.fromJson(json.decode(response.data));
    } on DioException catch (e) {
      print(e.response);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> deleteExpense(String id, String userId) async {
    try {
      Response response = await connect().delete(
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
