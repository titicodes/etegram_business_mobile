import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:etegram_business/constants/app_url.dart';
import 'package:etegram_business/core/model/delivery_response.dart';
import 'package:etegram_business/service/web/base_api.dart';

class DeliveryApiService {
  Future<DeliveryData?> createDeliveryAgent(DeliveryData deliveryData) async {
    try {
      Response response = await connect().post(
        '${AppUrls.createDeliveryUrl}/agent',
        data: deliveryData.toCreateJson(),
      );
      return DeliveryData.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<DeliveryTransactionData?> createDeliveryTransaction(DeliveryTransactionData transactionData) async {
    try {
      Response response = await connect().post(
        '${AppUrls.createDeliveryUrl}/transaction',
        data: transactionData.toJson(),
      );
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
      return (response.data as List).map((json) => DeliveryData.fromJson(json)).toList();
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<DeliveryTransactionData>?> getAllDeliveryTransactions({String? storeId}) async {
    try {
      Response response = await connect().get(
        '${AppUrls.createDeliveryUrl}/transactions',
        queryParameters: storeId != null ? {'storeId': storeId} : {},
      );
      return (response.data as List).map((json) => DeliveryTransactionData.fromJson(json)).toList();
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
      Response response = await connect().get('${AppUrls.createDeliveryUrl}/agent/$id');
      return DeliveryData.fromJson(response.data);
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
      Response response = await connect().get('${AppUrls.createDeliveryUrl}/transaction/$id');
      return DeliveryTransactionData.fromJson(response.data);
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
      return DeliveryData.fromJson(response.data);
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<bool> deleteDeliveryAgent(String id) async {
    try {
      Response response = await connect().delete('${AppUrls.createDeliveryUrl}/agent/$id');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}