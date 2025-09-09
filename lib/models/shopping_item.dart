import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 5)
class ShoppingItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double? quantity;

  @HiveField(3)
  final String? unit;

  @HiveField(4)
  final String? category;

  @HiveField(5)
  final bool checked;

  @HiveField(6)
  final String? recipeId;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  ShoppingItem({
    required this.id,
    required this.name,
    this.quantity,
    this.unit,
    this.category,
    this.checked = false,
    this.recipeId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new shopping item
  factory ShoppingItem.create({
    required String name,
    double? quantity,
    String? unit,
    String? category,
    String? recipeId,
  }) {
    final now = DateTime.now();
    return ShoppingItem(
      id: '${now.millisecondsSinceEpoch}_${name.hashCode}',
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      recipeId: recipeId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Get added at date (alias for createdAt)
  DateTime get addedAt => createdAt;

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity']?.toDouble(),
      unit: map['unit'],
      category: map['category'],
      checked: map['checked'] ?? false,
      recipeId: map['recipeId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'checked': checked,
      'recipeId': recipeId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ShoppingItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingItem.fromMap({...data, 'id': doc.id});
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    bool? checked,
    String? recipeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      checked: checked ?? this.checked,
      recipeId: recipeId ?? this.recipeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShoppingItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    final qty = quantity != null ? '$quantity ' : '';
    final unitStr = unit != null ? '$unit ' : '';
    return '$qty$unitStr$name';
  }
}