import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../core/constants.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 5)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String displayName;

  @HiveField(2)
  final String? photoURL;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String plan;

  @HiveField(5)
  final UserStats stats;

  @HiveField(6)
  final UserSocial social;

  @HiveField(7)
  final UserReferrals referrals;

  UserProfile({
    required this.uid,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    this.plan = UserPlan.free,
    required this.stats,
    required this.social,
    required this.referrals,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      plan: map['plan'] ?? UserPlan.free,
      stats: UserStats.fromMap(map['stats'] ?? {}),
      social: UserSocial.fromMap(map['social'] ?? {}),
      referrals: UserReferrals.fromMap(map['referrals'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'plan': plan,
      'stats': stats.toMap(),
      'social': social.toMap(),
      'referrals': referrals.toMap(),
    };
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile.fromMap({...data, 'uid': doc.id});
  }

  factory UserProfile.create({
    required String uid,
    required String displayName,
    String? photoURL,
    String? referralCode,
  }) {
    final now = DateTime.now();
    return UserProfile(
      uid: uid,
      displayName: displayName,
      photoURL: photoURL,
      createdAt: now,
      plan: UserPlan.free,
      stats: UserStats.empty(),
      social: UserSocial.empty(),
      referrals: UserReferrals.create(referralCode),
    );
  }

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    String? plan,
    UserStats? stats,
    UserSocial? social,
    UserReferrals? referrals,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      plan: plan ?? this.plan,
      stats: stats ?? this.stats,
      social: social ?? this.social,
      referrals: referrals ?? this.referrals,
    );
  }

  bool get isPremium => plan == UserPlan.premium;
  bool get isPublic => social.visibility == UserVisibility.public;
  bool get isPrivate => social.visibility == UserVisibility.private;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserProfile(uid: $uid, displayName: $displayName, plan: $plan)';
  }
}

@HiveType(typeId: 6)
class UserStats extends HiveObject {
  @HiveField(0)
  final int recipesSaved;

  @HiveField(1)
  final int recipesCooked;

  @HiveField(2)
  final int streak;

  @HiveField(3)
  final List<String> badges;

  UserStats({
    this.recipesSaved = 0,
    this.recipesCooked = 0,
    this.streak = 0,
    this.badges = const [],
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      recipesSaved: map['recipesSaved'] ?? 0,
      recipesCooked: map['recipesCooked'] ?? 0,
      streak: map['streak'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipesSaved': recipesSaved,
      'recipesCooked': recipesCooked,
      'streak': streak,
      'badges': badges,
    };
  }

  factory UserStats.empty() {
    return UserStats();
  }

  UserStats copyWith({
    int? recipesSaved,
    int? recipesCooked,
    int? streak,
    List<String>? badges,
  }) {
    return UserStats(
      recipesSaved: recipesSaved ?? this.recipesSaved,
      recipesCooked: recipesCooked ?? this.recipesCooked,
      streak: streak ?? this.streak,
      badges: badges ?? this.badges,
    );
  }

  bool hasBadge(String badge) => badges.contains(badge);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStats &&
        other.recipesSaved == recipesSaved &&
        other.recipesCooked == recipesCooked &&
        other.streak == streak &&
        other.badges.toString() == badges.toString();
  }

  @override
  int get hashCode {
    return recipesSaved.hashCode ^
        recipesCooked.hashCode ^
        streak.hashCode ^
        badges.hashCode;
  }
}

@HiveType(typeId: 7)
class UserSocial extends HiveObject {
  @HiveField(0)
  final int followers;

  @HiveField(1)
  final int following;

  @HiveField(2)
  final String? bio;

  @HiveField(3)
  final String visibility;

  UserSocial({
    this.followers = 0,
    this.following = 0,
    this.bio,
    this.visibility = UserVisibility.private,
  });

  factory UserSocial.fromMap(Map<String, dynamic> map) {
    return UserSocial(
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
      bio: map['bio'],
      visibility: map['visibility'] ?? UserVisibility.private,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'followers': followers,
      'following': following,
      'bio': bio,
      'visibility': visibility,
    };
  }

  factory UserSocial.empty() {
    return UserSocial();
  }

  UserSocial copyWith({
    int? followers,
    int? following,
    String? bio,
    String? visibility,
  }) {
    return UserSocial(
      followers: followers ?? this.followers,
      following: following ?? this.following,
      bio: bio ?? this.bio,
      visibility: visibility ?? this.visibility,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSocial &&
        other.followers == followers &&
        other.following == following &&
        other.bio == bio &&
        other.visibility == visibility;
  }

  @override
  int get hashCode {
    return followers.hashCode ^
        following.hashCode ^
        bio.hashCode ^
        visibility.hashCode;
  }
}

@HiveType(typeId: 8)
class UserReferrals extends HiveObject {
  @HiveField(0)
  final String code;

  @HiveField(1)
  final int referredCount;

  UserReferrals({
    required this.code,
    this.referredCount = 0,
  });

  factory UserReferrals.fromMap(Map<String, dynamic> map) {
    return UserReferrals(
      code: map['code'] ?? '',
      referredCount: map['referredCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'referredCount': referredCount,
    };
  }

  factory UserReferrals.create(String? existingCode) {
    return UserReferrals(
      code: existingCode ?? _generateReferralCode(),
      referredCount: 0,
    );
  }

  static String _generateReferralCode() {
    // Generate a 6-character alphanumeric code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i) % chars.length];
    }
    return code;
  }

  UserReferrals copyWith({
    String? code,
    int? referredCount,
  }) {
    return UserReferrals(
      code: code ?? this.code,
      referredCount: referredCount ?? this.referredCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserReferrals &&
        other.code == code &&
        other.referredCount == referredCount;
  }

  @override
  int get hashCode => code.hashCode ^ referredCount.hashCode;
}
