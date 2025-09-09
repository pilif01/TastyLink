import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../core/constants.dart';

part 'planner_entry.g.dart';

@HiveType(typeId: 10)
class PlannerEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String meal;

  @HiveField(2)
  final String? recipeId;

  @HiveField(3)
  final String? note;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  PlannerEntry({
    required this.id,
    required this.meal,
    this.recipeId,
    this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlannerEntry.fromMap(Map<String, dynamic> map) {
    return PlannerEntry(
      id: map['id'] ?? '',
      meal: map['meal'] ?? MealType.lunch,
      recipeId: map['recipeId'],
      note: map['note'],
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meal': meal,
      'recipeId': recipeId,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory PlannerEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlannerEntry.fromMap({...data, 'id': doc.id});
  }

  factory PlannerEntry.create({
    required String meal,
    String? recipeId,
    String? note,
    required DateTime date,
  }) {
    final now = DateTime.now();
    return PlannerEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      meal: meal,
      recipeId: recipeId,
      note: note,
      date: date,
      createdAt: now,
      updatedAt: now,
    );
  }

  PlannerEntry copyWith({
    String? id,
    String? meal,
    String? recipeId,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlannerEntry(
      id: id ?? this.id,
      meal: meal ?? this.meal,
      recipeId: recipeId ?? this.recipeId,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get mealLabel {
    switch (meal) {
      case MealType.breakfast:
        return 'Mic dejun';
      case MealType.lunch:
        return 'Pranz';
      case MealType.dinner:
        return 'Cina';
      case MealType.snack:
        return 'Gustare';
      default:
        return meal;
    }
  }

  String get mealLabelEn {
    switch (meal) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
      default:
        return meal;
    }
  }

  bool get hasRecipe => recipeId != null;
  bool get hasNote => note != null && note!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlannerEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PlannerEntry(id: $id, meal: $meal, date: $date, recipeId: $recipeId)';
  }
}
