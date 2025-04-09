import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  bool isLoggedIn = false;

  storeItem({String? key, String? value}) async {
    await storage.write(key: key!, value: value);
  }

  Future<dynamic> readItem({String? key}) async {
    final value = await storage.read(key: key!);
    return value;
  }

  deleteItem({String? key}) async {
    await storage.delete(key: key!);
  }

  deleteAllItems() async {
    await storage.deleteAll();
  }

  Future<dynamic> hasKey({String? key}) async {
    return await storage.containsKey(key: key!);
  }
}
