class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.notes,
    required this.createdAt,
    this.ownerId,
  });

  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  final String? ownerId;

  Customer copyWith({
    String? name,
    String? phone,
    String? address,
    String? notes,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      ownerId: ownerId,
    );
  }
}
