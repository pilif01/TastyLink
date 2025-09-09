// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 5;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      uid: fields[0] as String,
      displayName: fields[1] as String,
      photoURL: fields[2] as String?,
      createdAt: fields[3] as DateTime,
      plan: fields[4] as String,
      stats: fields[5] as UserStats,
      social: fields[6] as UserSocial,
      referrals: fields[7] as UserReferrals,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.photoURL)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.plan)
      ..writeByte(5)
      ..write(obj.stats)
      ..writeByte(6)
      ..write(obj.social)
      ..writeByte(7)
      ..write(obj.referrals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 6;

  @override
  UserStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStats(
      recipesSaved: fields[0] as int,
      recipesCooked: fields[1] as int,
      streak: fields[2] as int,
      badges: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.recipesSaved)
      ..writeByte(1)
      ..write(obj.recipesCooked)
      ..writeByte(2)
      ..write(obj.streak)
      ..writeByte(3)
      ..write(obj.badges);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserSocialAdapter extends TypeAdapter<UserSocial> {
  @override
  final int typeId = 7;

  @override
  UserSocial read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSocial(
      followers: fields[0] as int,
      following: fields[1] as int,
      bio: fields[2] as String?,
      visibility: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserSocial obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.followers)
      ..writeByte(1)
      ..write(obj.following)
      ..writeByte(2)
      ..write(obj.bio)
      ..writeByte(3)
      ..write(obj.visibility);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSocialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserReferralsAdapter extends TypeAdapter<UserReferrals> {
  @override
  final int typeId = 8;

  @override
  UserReferrals read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserReferrals(
      code: fields[0] as String,
      referredCount: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserReferrals obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.referredCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserReferralsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
