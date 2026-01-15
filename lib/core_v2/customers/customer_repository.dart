import '../persistence/session_storage.dart';
import 'customer.dart';

class CustomerRepository {
  static const _key = 'customers';

  Future<List<Customer>> loadAll() async {
    final raw = await SessionStorage.loadMap(_key);

    return raw.values
        .map((e) => Customer.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }

  Future<void> saveAll(List<Customer> customers) async {
    final map = {
      for (final c in customers) c.id.value: c.toJson(),
    };

    await SessionStorage.saveMap(_key, map);
  }
}
