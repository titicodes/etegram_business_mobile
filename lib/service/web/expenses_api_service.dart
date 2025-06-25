import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:etegram_business/constants/app_url.dart';
import 'package:etegram_business/core/model/expense_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/local/storage_service.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/service/web/base_api.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/reuseable.dart';

class ExpensesApiService {
  StorageService storageService = locator<StorageService>();
  CustomerService customerService = locator<CustomerService>();

  Future<String> _getToken() async {
    final box = GetStorage();
    String? accessToken = box.read(DbTable.tokenTableName);

    if (accessToken == null) {
      throw Exception('No token found');
    }
    return accessToken;
  }

  Future<ExpenseData?> createExpense(ExpenseData expense) async {
    final token = await _getToken();
    final storeId = await customerService.getActiveStoreId();

    if (storeId == null) {
      print('Store ID not found.');
      return null;
    }

    try {
      final payload = {
        'description': expense.description,
        'amount': expense.amount,
        'storeId': storeId,
        'category': expense.category,
        'currency': expense.currency,
        'paymentMethod': expense.paymentMethod,
        if (expense.notes != null) 'notes': expense.notes,
        if (expense.date != null) 'date': expense.date!.toIso8601String(),
      };

      print('Create Expense Payload: $payload');
      final response = await connect().post(
        AppUrls.getExpenseUrl,
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('Create Expense Response: ${response.data}');
      return ExpenseData.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('DioException in createExpense: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error in createExpense: $e');
      return null;
    }
  }

  Future<List<ExpenseData>?> getAllExpenses({String? storeId}) async {
    final token = await _getToken();
    final activeStoreId = storeId ?? await customerService.getActiveStoreId();

    if (activeStoreId == null) {
      print('Store ID not found.');
      return null;
    }

    try {
      final queryParameters = {'storeId': activeStoreId};
      print('Get All Expenses Query: $queryParameters');

      final response = await connect().get(
        AppUrls.getExpenseUrl,
        queryParameters: queryParameters,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('Get All Expenses Response: ${response.data}');
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => ExpenseData.fromJson(e)).toList();
    } on DioException catch (e) {
      print('DioException in getAllExpenses: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error in getAllExpenses: $e');
      return null;
    }
  }

  Future<ExpenseData?> getExpenseById(String id) async {
    final token = await _getToken();

    try {
      final response = await connect().get(
        '${AppUrls.getExpenseUrl}/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('Get Expense By ID Response: ${response.data}');
      return ExpenseData.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('DioException in getExpenseById: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error in getExpenseById: $e');
      return null;
    }
  }

  Future<ExpenseData?> updateExpense(ExpenseData expense) async {
    final token = await _getToken();
    final storeId = await customerService.getActiveStoreId();

    if (storeId == null) {
      print('Store ID not found.');
      return null;
    }

    try {
      final payload = {
        if (expense.description != null) 'description': expense.description,
        if (expense.amount != null) 'amount': expense.amount,
        'storeId': storeId,
        if (expense.category != null) 'category': expense.category,
        if (expense.currency != null) 'currency': expense.currency,
        if (expense.paymentMethod != null) 'paymentMethod': expense.paymentMethod,
        if (expense.notes != null) 'notes': expense.notes,
        if (expense.date != null) 'date': expense.date!.toIso8601String(),
      };

      print('Update Expense Payload: $payload');
      final response = await connect().put(
        '${AppUrls.getExpenseUrl}/${expense.id}',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('Update Expense Response: ${response.data}');
      return ExpenseData.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('DioException in updateExpense: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error in updateExpense: $e');
      return null;
    }
  }

  Future<bool> deleteExpense(String id) async {
    final token = await _getToken();

    try {
      final response = await connect().delete(
        '${AppUrls.getExpenseUrl}/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('Delete Expense Response: ${response.statusCode}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('DioException in deleteExpense: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Error in deleteExpense: $e');
      return false;
    }
  }
}