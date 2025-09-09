import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user_recipe.g.dart';

@HiveType(typeId: 13)
class UserRecipe extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String creatorHandle;

  @HiveField(3)
  final String? coverImageUrl;

  @HiveField(4)
  final DateTime savedAt;

  @HiveField(5)
  final String? notes;

  UserRecipe({
    required this.id,
    required this.title,
    required this.creatorHandle,
    this.coverImageUrl,
    required this.savedAt,
    this.notes,
  });

  factory UserRecipe.fromMap(Map<String, dynamic> map) {
    return UserRecipe(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      creatorHandle: map['creatorHandle'] ?? '',
      coverImageUrl: map['coverImageUrl'],
      savedAt: (map['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'creatorHandle': creatorHandle,
      'coverImageUrl': coverImageUrl,
      'savedAt': Timestamp.fromDate(savedAt),
      'notes': notes,
    };
  }

  factory UserRecipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserRecipe.fromMap({...data, 'id': doc.id});
  }

  factory UserRecipe.create({
    required String id,
    required String title,
    required String creatorHandle,
    String? coverImageUrl,
    String? notes,
  }) {
    return UserRecipe(
      id: id,
      title: title,
      creatorHandle: creatorHandle,
      coverImageUrl: coverImageUrl,
      savedAt: DateTime.now(),
      notes: notes,
    );
  }

  UserRecipe copyWith({
    String? id,
    String? title,
    String? creatorHandle,
    String? coverImageUrl,
    DateTime? savedAt,
    String? notes,
  }) {
    return UserRecipe(
      id: id ?? this.id,
      title: title ?? this.title,
      creatorHandle: creatorHandle ?? this.creatorHandle,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      savedAt: savedAt ?? this.savedAt,
      notes: notes ?? this.notes,
    );
  }

  bool get hasImage => coverImageUrl != null && coverImageUrl!.isNotEmpty;
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserRecipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserRecipe(id: $id, title: $title, creatorHandle: $creatorHandle)';
  }
}
