import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../core/constants.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 9)
class ShoppingItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? recipeId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double? quantity;

  @HiveField(4)
  final String? unit;

  @HiveField(5)
  final bool checked;

  @HiveField(6)
  final String category;

  @HiveField(7)
  final DateTime addedAt;

  @HiveField(8)
  final String? notes;

  ShoppingItem({
    required this.id,
    this.recipeId,
    required this.name,
    this.quantity,
    this.unit,
    this.checked = false,
    this.category = IngredientCategory.other,
    required this.addedAt,
    this.notes,
  });

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] ?? '',
      recipeId: map['recipeId'],
      name: map['name'] ?? '',
      quantity: map['qty']?.toDouble(),
      unit: map['unit'],
      checked: map['checked'] ?? false,
      category: map['category'] ?? IngredientCategory.other,
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipeId': recipeId,
      'name': name,
      'qty': quantity,
      'unit': unit,
      'checked': checked,
      'category': category,
      'addedAt': Timestamp.fromDate(addedAt),
      'notes': notes,
    };
  }

  factory ShoppingItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingItem.fromMap({...data, 'id': doc.id});
  }

  factory ShoppingItem.create({
    required String name,
    double? quantity,
    String? unit,
    String? category,
    String? recipeId,
    String? notes,
  }) {
    return ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipeId: recipeId,
      name: name,
      quantity: quantity,
      unit: unit,
      category: category ?? IngredientCategory.other,
      addedAt: DateTime.now(),
      notes: notes,
    );
  }

  ShoppingItem copyWith({
    String? id,
    String? recipeId,
    String? name,
    double? quantity,
    String? unit,
    bool? checked,
    String? category,
    DateTime? addedAt,
    String? notes,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      checked: checked ?? this.checked,
      category: category ?? this.category,
      addedAt: addedAt ?? this.addedAt,
      notes: notes ?? this.notes,
    );
  }

  String get displayText {
    final qty = quantity != null ? '$quantity ' : '';
    final unitStr = unit != null ? '$unit ' : '';
    return '$qty$unitStr$name';
  }

  String get categoryLabel {
    return IngredientCategory.labels[category] ?? category;
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
    return 'ShoppingItem(id: $id, name: $name, checked: $checked)';
  }
}
