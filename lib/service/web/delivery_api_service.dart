import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etegram_business/constants/app_url.dart';
import 'package:etegram_business/service/web/base_api.dart';

import '../../core/model/delivery_response.dart';

class DeliveryApiService {
  Future<DeliveryData?> createDelivery(DeliveryData expense) async {
    try {
      Response response = await connect().post(
        AppUrls.getExpenseUrl,
        data: expense.toJson(),
      );
      return DeliveryData.fromJson(json.decode(response.data));
    } on DioException catch (e) {
      print(e.response);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<DeliveryData>?> getAllDelivery() async {
    try {
      Response response = await connect().get(AppUrls.createDeliveryUrl);

      Map<String, dynamic> decodedData = json.decode(response.data);

      DeliveryData delivery = DeliveryData.fromJson(decodedData);

      return [delivery]; // Return as a list with one item
    } on DioException catch (e) {
      print(e.response);
      return null;
    } catch (e) {
      print('Json Decode Error: $e');
      return null;
    }
  }

  Future<DeliveryData?> getDeliveryById(String id, String userId) async {
    try {
      Response response = await connect().get(
        '${AppUrls.getExpenseUrl}/$id/$userId',
      );
      return DeliveryData.fromJson(json.decode(response.data));
    } on DioException catch (e) {
      print(e.response);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<DeliveryData?> updateDelivery(DeliveryData expense) async {
    try {
      Response response = await connect().put(
        '${AppUrls.getExpenseUrl}/${expense.id}',
        data: expense.toJson(),
      );
      return DeliveryData.fromJson(json.decode(response.data));
    } on DioException catch (e) {
      print(e.response);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> deleteDelivery(String id, String userId) async {
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
