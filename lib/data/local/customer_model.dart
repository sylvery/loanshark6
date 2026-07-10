import 'package:isar/isar.dart';

import '../../domain/entities/customer.dart';

part 'customer_model.g.dart';

@Collection()
class CustomerModel {
  CustomerModel();

  @Id()
  Id id = '';

  late String name;
  String? phone;
  String? address;
  String? notes;
  late int createdAt;
  String? ownerId;

  Customer toDomain() => Customer(
        id: id,
        name: name,
        phone: phone,
        address: address,
        notes: notes,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
        ownerId: ownerId,
      );

  static CustomerModel fromDomain(Customer customer) => CustomerModel()
    ..id = customer.id
    ..name = customer.name
    ..phone = customer.phone
    ..address = customer.address
    ..notes = customer.notes
    ..createdAt = customer.createdAt.millisecondsSinceEpoch
    ..ownerId = customer.ownerId;
}
