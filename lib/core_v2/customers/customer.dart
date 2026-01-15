import 'customer_id.dart';

class Customer {
  final CustomerId id;
  final String name;
  final String? phone;
  final String? email;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.createdAt,
  });

  Customer copyWith({
    String? name,
    String? phone,
    String? email,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'name': name,
      'phone': phone,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: CustomerId(json['id']),
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

