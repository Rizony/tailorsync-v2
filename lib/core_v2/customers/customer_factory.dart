import 'package:uuid/uuid.dart';
import 'customer.dart';
import 'customer_id.dart';

class CustomerFactory {
  static const _uuid = Uuid();

  static Customer create({
    required String name,
    String? phone,
    String? email,
  }) {
    return Customer(
      id: CustomerId(_uuid.v4()),
      name: name,
      phone: phone,
      email: email,
      createdAt: DateTime.now(),
    );
  }
}
