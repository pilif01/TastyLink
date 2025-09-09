import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../core/constants.dart';

part 'social_post.g.dart';

@HiveType(typeId: 12)
class SocialPost extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String uid;

  @HiveField(2)
  final String? recipeId;

  @HiveField(3)
  final String text;

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final int likes;

  @HiveField(6)
  final int comments;

  @HiveField(7)
  final String visibility;

  @HiveField(8)
  final DateTime timestamp;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  SocialPost({
    required this.id,
    required this.uid,
    this.recipeId,
    required this.text,
    this.imageUrl,
    this.likes = 0,
    this.comments = 0,
    this.visibility = PostVisibility.public,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SocialPost.fromMap(Map<String, dynamic> map) {
    return SocialPost(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      recipeId: map['recipeId'],
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      visibility: map['visibility'] ?? PostVisibility.public,
      timestamp: (map['ts'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'recipeId': recipeId,
      'text': text,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'visibility': visibility,
      'ts': Timestamp.fromDate(timestamp),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SocialPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialPost.fromMap({...data, 'id': doc.id});
  }

  factory SocialPost.create({
    required String uid,
    required String text,
    String? recipeId,
    String? imageUrl,
    String? visibility,
  }) {
    final now = DateTime.now();
    return SocialPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      uid: uid,
      recipeId: recipeId,
      text: text,
      imageUrl: imageUrl,
      visibility: visibility ?? PostVisibility.public,
      timestamp: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  SocialPost copyWith({
    String? id,
    String? uid,
    String? recipeId,
    String? text,
    String? imageUrl,
    int? likes,
    int? comments,
    String? visibility,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialPost(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      recipeId: recipeId ?? this.recipeId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      visibility: visibility ?? this.visibility,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get visibilityLabel {
    switch (visibility) {
      case PostVisibility.public:
        return 'Public';
      case PostVisibility.friends:
        return 'Prieteni';
      default:
        return visibility;
    }
  }

  String get visibilityLabelEn {
    switch (visibility) {
      case PostVisibility.public:
        return 'Public';
      case PostVisibility.friends:
        return 'Friends';
      default:
        return visibility;
    }
  }

  bool get isPublic => visibility == PostVisibility.public;
  bool get isFriendsOnly => visibility == PostVisibility.friends;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasRecipe => recipeId != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SocialPost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SocialPost(id: $id, uid: $uid, text: $text, likes: $likes)';
  }
}
