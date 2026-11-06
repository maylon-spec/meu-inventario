class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String room;
  final String barcode;
  final int quantity;
  final double unitValue;
  final String notes;
  final DateTime updatedAt;
  final bool synced;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.room,
    required this.barcode,
    required this.quantity,
    required this.unitValue,
    required this.notes,
    required this.updatedAt,
    this.synced = false,
  });

  double get totalValue => quantity * unitValue;

  Map<String, Object?> toMap() => {
    'id': id, 'name': name, 'category': category, 'room': room,
    'barcode': barcode, 'quantity': quantity, 'unitValue': unitValue,
    'notes': notes, 'updatedAt': updatedAt.toIso8601String(),
    'synced': synced ? 1 : 0,
  };

  factory InventoryItem.fromMap(Map<String, Object?> map) => InventoryItem(
    id: map['id'] as String,
    name: map['name'] as String,
    category: map['category'] as String,
    room: map['room'] as String,
    barcode: (map['barcode'] as String?) ?? '',
    quantity: map['quantity'] as int,
    unitValue: (map['unitValue'] as num).toDouble(),
    notes: (map['notes'] as String?) ?? '',
    updatedAt: DateTime.parse(map['updatedAt'] as String),
    synced: (map['synced'] as int? ?? 0) == 1,
  );
}
