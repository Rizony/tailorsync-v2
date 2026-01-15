import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'customer.dart';
import 'customer_factory.dart';
import 'customer_id.dart';
import 'customer_repository.dart';

class CustomersController
    extends StateNotifier<Map<CustomerId, Customer>> {
  final CustomerRepository _repo;

  CustomersController(this._repo) : super({});

  Future<void> bootstrap() async {
    final customers = await _repo.loadAll();
    state = {
      for (final c in customers) c.id: c,
    };
  }

  void addCustomer({
    required String name,
    String? phone,
    String? email,
  }) {
    final customer = CustomerFactory.create(
      name: name,
      phone: phone,
      email: email,
    );

    state = {
      ...state,
      customer.id: customer,
    };

    _persist();
  }

  void updateCustomer(Customer customer) {
    state = {
      ...state,
      customer.id: customer,
    };

    _persist();
  }

  Future<void> _persist() async {
    await _repo.saveAll(state.values.toList());
  }
}

final customersControllerProvider =
    StateNotifierProvider<CustomersController,
        Map<CustomerId, Customer>>((ref) {
  final controller =
      CustomersController(CustomerRepository());
  controller.bootstrap();
  return controller;
});
