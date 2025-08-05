import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:etegram_business/constants/app_url.dart';
import 'package:etegram_business/core/model/auth_response.dart';
import 'package:etegram_business/core/model/delivery_response.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/service/web/base_api.dart';

class DeliveryApiService {
  Future<DeliveryData?> createDeliveryAgent(DeliveryData deliveryData) async {
    try {
      Response response = await connect().post(
        '${AppUrls.createDeliveryUrl}/agent',
        data: deliveryData.toCreateJson(),
      );
      print('Request URL: ${AppUrls.createDeliveryUrl}/agent');
      print('Response Status: ${response.statusCode}');
      print('Response Data: ${jsonEncode(response.data)}');
      return DeliveryData.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<DeliveryTransactionData?> createDeliveryTransaction(
      DeliveryTransactionData transactionData) async {
    try {
      Response response = await connect().post(
        '${AppUrls.createDeliveryUrl}/transaction',
        data: transactionData.toJson(),
      );
      print('Request URL: ${AppUrls.createDeliveryUrl}/transaction');
      print('Response Status: ${response.statusCode}');
      print('Response Data: ${jsonEncode(response.data)}');
      return DeliveryTransactionData.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<DeliveryData>?> getAllDeliveryAgents({String? storeId}) async {
    try {
      Response response = await connect().get(
        '${AppUrls.createDeliveryUrl}/agents',
        queryParameters: storeId != null ? {'storeId': storeId} : {},
      );
      print('Request URL: ${AppUrls.createDeliveryUrl}/agents');
      print('Response Status: ${response.statusCode}');
      print('Response Data: ${jsonEncode(response.data)}');

      // Handle response.data directly as the list of delivery agents
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) => DeliveryData.fromJson(json)).toList();
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<DeliveryTransactionData>?> getAllDeliveryTransactions(
      {String? storeId}) async {
    try {
      Response response = await connect().get(
        '${AppUrls.createDeliveryUrl}/transactions',
        queryParameters: storeId != null ? {'storeId': storeId} : {},
      );
      print('Request URL: ${AppUrls.createDeliveryUrl}/transactions');
      print('Response Status: ${response.statusCode}');
      print('Response Data: ${jsonEncode(response.data)}');

      // Handle response.data directly as the list of transactions
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((json) => DeliveryTransactionData.fromJson(json))
          .toList();
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<Product>?> getLowStockProducts(
      {String? storeId, int stockThreshold = 5}) async {
    try {
      Response response = await connect().get(
        '${AppUrls.createDeliveryUrl}/agents', // TODO: Update to correct endpoint
        queryParameters: {
          if (storeId != null) 'storeId': storeId,
          'stockThreshold': stockThreshold,
        },
      );
      print('Request URL: ${AppUrls.createDeliveryUrl}/agents');
      print('Response Status: ${response.statusCode}');
      print('Response Data: ${jsonEncode(response.data)}');

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<DeliveryData?> getDeliveryAgentById(String id) async {
    try {
      Response response =
          await connect().get('${AppUrls.createDeliveryUrl}/agent/$id');
      print('Request URL: ${AppUrls.createDeliveryUrl}/agent/$id');
      print('Response Status: ${response.statusCode}');
      print('Response Data: ${jsonEncode(response.data)}');
      return DeliveryData.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<DeliveryTransactionData?> getDeliveryTransactionById(String id) async {
    try {
      Response response =
          await connect().get('${AppUrls.createDeliveryUrl}/transaction/$id');
      print('Request URL: ${AppUrls.createDeliveryUrl}/transaction/$id');
      print('Response Status: ${response.statusCode}');
      print('Response Data: ${jsonEncode(response.data)}');
      return DeliveryTransactionData.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<DeliveryData?> updateDeliveryAgent(DeliveryData delivery) async {
    try {
      Response response = await connect().put(
        '${AppUrls.createDeliveryUrl}/agent/${delivery.id}',
        data: delivery.toJson(),
      );
      print('Request URL: ${AppUrls.createDeliveryUrl}/agent/${delivery.id}');
      print('Response Status: ${response.statusCode}');
      print('Response Data: ${jsonEncode(response.data)}');
      return DeliveryData.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<bool?> deleteDeliveryAgent(String id) async {
    try {
      Response response =
          await connect().delete('${AppUrls.createDeliveryUrl}/agent/$id');
      print('Request URL: ${AppUrls.createDeliveryUrl}/agent/$id');
      print('Response Status: ${response.statusCode}');
      print('Response Data: ${jsonEncode(response.data)}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }


}
