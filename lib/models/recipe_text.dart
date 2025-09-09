import 'package:hive/hive.dart';

part 'recipe_text.g.dart';

@HiveType(typeId: 2)
class RecipeText extends HiveObject {
  @HiveField(0)
  final String original;

  @HiveField(1)
  final String? ro;

  @HiveField(2)
  final String? en;

  RecipeText({
    required this.original,
    this.ro,
    this.en,
  });

  factory RecipeText.fromMap(Map<String, dynamic> map) {
    return RecipeText(
      original: map['original'] ?? '',
      ro: map['ro'],
      en: map['en'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'original': original,
      'ro': ro,
      'en': en,
    };
  }

  RecipeText copyWith({
    String? original,
    String? ro,
    String? en,
  }) {
    return RecipeText(
      original: original ?? this.original,
      ro: ro ?? this.ro,
      en: en ?? this.en,
    );
  }

  String getTextForLanguage(String languageCode) {
    switch (languageCode) {
      case 'ro':
        return ro ?? original;
      case 'en':
        return en ?? original;
      default:
        return original;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeText &&
        other.original == original &&
        other.ro == ro &&
        other.en == en;
  }

  @override
  int get hashCode {
    return original.hashCode ^ ro.hashCode ^ en.hashCode;
  }

  @override
  String toString() {
    return 'RecipeText(original: $original, ro: $ro, en: $en)';
  }
}
