import 'package:hive/hive.dart';

part 'recipe_media.g.dart';

@HiveType(typeId: 3)
class RecipeMedia extends HiveObject {
  @HiveField(0)
  final String? coverImageUrl;

  @HiveField(1)
  final List<String> stepPhotos;

  @HiveField(2)
  final String? videoUrl;

  @HiveField(3)
  final String? audioUrl;

  RecipeMedia({
    this.coverImageUrl,
    this.stepPhotos = const [],
    this.videoUrl,
    this.audioUrl,
  });

  factory RecipeMedia.fromMap(Map<String, dynamic> map) {
    return RecipeMedia(
      coverImageUrl: map['coverImageUrl'],
      stepPhotos: List<String>.from(map['stepPhotos'] ?? []),
      videoUrl: map['videoUrl'],
      audioUrl: map['audioUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coverImageUrl': coverImageUrl,
      'stepPhotos': stepPhotos,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
    };
  }

  RecipeMedia copyWith({
    String? coverImageUrl,
    List<String>? stepPhotos,
    String? videoUrl,
    String? audioUrl,
  }) {
    return RecipeMedia(
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      stepPhotos: stepPhotos ?? this.stepPhotos,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  bool get hasImages => coverImageUrl != null || stepPhotos.isNotEmpty;
  bool get hasVideo => videoUrl != null;
  bool get hasAudio => audioUrl != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeMedia &&
        other.coverImageUrl == coverImageUrl &&
        other.stepPhotos.toString() == stepPhotos.toString() &&
        other.videoUrl == videoUrl &&
        other.audioUrl == audioUrl;
  }

  @override
  int get hashCode {
    return coverImageUrl.hashCode ^
        stepPhotos.hashCode ^
        videoUrl.hashCode ^
        audioUrl.hashCode;
  }

  @override
  String toString() {
    return 'RecipeMedia(coverImageUrl: $coverImageUrl, stepPhotos: ${stepPhotos.length}, videoUrl: $videoUrl, audioUrl: $audioUrl)';
  }
}
