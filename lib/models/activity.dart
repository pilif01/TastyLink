import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../core/constants.dart';

part 'activity.g.dart';

@HiveType(typeId: 11)
class Activity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String? recipeId;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final Map<String, dynamic>? metadata;

  Activity({
    required this.id,
    required this.type,
    this.recipeId,
    required this.timestamp,
    this.metadata,
  });

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] ?? '',
      type: map['type'] ?? ActivityType.saved,
      recipeId: map['recipeId'],
      timestamp: (map['ts'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'recipeId': recipeId,
      'ts': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity.fromMap({...data, 'id': doc.id});
  }

  factory Activity.create({
    required String type,
    String? recipeId,
    Map<String, dynamic>? metadata,
  }) {
    return Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      recipeId: recipeId,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }

  Activity copyWith({
    String? id,
    String? type,
    String? recipeId,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return Activity(
      id: id ?? this.id,
      type: type ?? this.type,
      recipeId: recipeId ?? this.recipeId,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  String get typeLabel {
    switch (type) {
      case ActivityType.saved:
        return 'A salvat o rețetă';
      case ActivityType.cooked:
        return 'A gătit o rețetă';
      case ActivityType.completedStep:
        return 'A completat un pas';
      case ActivityType.badge:
        return 'A câștigat un badge';
      default:
        return type;
    }
  }

  String get typeLabelEn {
    switch (type) {
      case ActivityType.saved:
        return 'Saved a recipe';
      case ActivityType.cooked:
        return 'Cooked a recipe';
      case ActivityType.completedStep:
        return 'Completed a step';
      case ActivityType.badge:
        return 'Earned a badge';
      default:
        return type;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Activity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Activity(id: $id, type: $type, recipeId: $recipeId, timestamp: $timestamp)';
  }
}
