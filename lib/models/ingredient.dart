import 'package:hive/hive.dart';

part 'ingredient.g.dart';

@HiveType(typeId: 0)
class Ingredient extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double? quantity;

  @HiveField(2)
  final String? unit;

  @HiveField(3)
  final String? category;

  @HiveField(4)
  final String? notes;

  Ingredient({
    required this.name,
    this.quantity,
    this.unit,
    this.category,
    this.notes,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] ?? '',
      quantity: map['qty']?.toDouble(),
      unit: map['unit'],
      category: map['category'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'qty': quantity,
      'unit': unit,
      'category': category,
      'notes': notes,
    };
  }

  Ingredient copyWith({
    String? name,
    double? quantity,
    String? unit,
    String? category,
    String? notes,
  }) {
    return Ingredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient &&
        other.name == name &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.category == category &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        quantity.hashCode ^
        unit.hashCode ^
        category.hashCode ^
        notes.hashCode;
  }

  @override
  String toString() {
    final qty = quantity != null ? '$quantity ' : '';
    final unitStr = unit != null ? '$unit ' : '';
    return '$qty$unitStr$name';
  }
}
