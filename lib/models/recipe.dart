import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'ingredient.dart';
import 'step_item.dart';
import 'recipe_text.dart';
import 'recipe_media.dart';
import '../core/constants.dart';

part 'recipe.g.dart';

@HiveType(typeId: 4)
class Recipe extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String creatorHandle;

  @HiveField(3)
  final String sourceLink;

  @HiveField(4)
  final String lang;

  @HiveField(5)
  final RecipeText text;

  @HiveField(6)
  final RecipeMedia media;

  @HiveField(7)
  final List<Ingredient> ingredients;

  @HiveField(8)
  final List<Ingredient> ingredientsRo;

  @HiveField(9)
  final List<StepItem> steps;

  @HiveField(10)
  final List<StepItem> stepsRo;

  @HiveField(11)
  final List<String> tags;

  @HiveField(12)
  final int likes;

  @HiveField(13)
  final int saves;

  @HiveField(14)
  final String? createdByUid;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime updatedAt;

  Recipe({
    required this.id,
    required this.title,
    required this.creatorHandle,
    required this.sourceLink,
    required this.lang,
    required this.text,
    required this.media,
    required this.ingredients,
    this.ingredientsRo = const [],
    required this.steps,
    this.stepsRo = const [],
    this.tags = const [],
    this.likes = 0,
    this.saves = 0,
    this.createdByUid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      creatorHandle: map['creatorHandle'] ?? '',
      sourceLink: map['sourceLink'] ?? '',
      lang: map['lang'] ?? 'en',
      text: RecipeText.fromMap(map['text'] ?? {}),
      media: RecipeMedia.fromMap(map['media'] ?? {}),
      ingredients: (map['ingredients'] as List<dynamic>?)
          ?.map((e) => Ingredient.fromMap(e))
          .toList() ?? [],
      ingredientsRo: (map['ingredients_ro'] as List<dynamic>?)
          ?.map((e) => Ingredient.fromMap(e))
          .toList() ?? [],
      steps: (map['steps'] as List<dynamic>?)
          ?.map((e) => StepItem.fromMap(e))
          .toList() ?? [],
      stepsRo: (map['steps_ro'] as List<dynamic>?)
          ?.map((e) => StepItem.fromMap(e))
          .toList() ?? [],
      tags: List<String>.from(map['tags'] ?? []),
      likes: map['likes'] ?? 0,
      saves: map['saves'] ?? 0,
      createdByUid: map['createdByUid'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'creatorHandle': creatorHandle,
      'sourceLink': sourceLink,
      'lang': lang,
      'text': text.toMap(),
      'media': media.toMap(),
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'ingredients_ro': ingredientsRo.map((e) => e.toMap()).toList(),
      'steps': steps.map((e) => e.toMap()).toList(),
      'steps_ro': stepsRo.map((e) => e.toMap()).toList(),
      'tags': tags,
      'likes': likes,
      'saves': saves,
      'createdByUid': createdByUid,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recipe.fromMap({...data, 'id': doc.id});
  }

  factory Recipe.createFromSource({
    required String sourceLink,
    required String title,
    required String creatorHandle,
    required String lang,
    required RecipeText text,
    required RecipeMedia media,
    required List<Ingredient> ingredients,
    required List<StepItem> steps,
    List<String> tags = const [],
    String? createdByUid,
  }) {
    final id = Constants.generateRecipeId(sourceLink);
    final now = DateTime.now();
    
    return Recipe(
      id: id,
      title: title,
      creatorHandle: creatorHandle,
      sourceLink: sourceLink,
      lang: lang,
      text: text,
      media: media,
      ingredients: ingredients,
      steps: steps,
      tags: tags,
      createdByUid: createdByUid,
      createdAt: now,
      updatedAt: now,
    );
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? creatorHandle,
    String? sourceLink,
    String? lang,
    RecipeText? text,
    RecipeMedia? media,
    List<Ingredient>? ingredients,
    List<Ingredient>? ingredientsRo,
    List<StepItem>? steps,
    List<StepItem>? stepsRo,
    List<String>? tags,
    int? likes,
    int? saves,
    String? createdByUid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      creatorHandle: creatorHandle ?? this.creatorHandle,
      sourceLink: sourceLink ?? this.sourceLink,
      lang: lang ?? this.lang,
      text: text ?? this.text,
      media: media ?? this.media,
      ingredients: ingredients ?? this.ingredients,
      ingredientsRo: ingredientsRo ?? this.ingredientsRo,
      steps: steps ?? this.steps,
      stepsRo: stepsRo ?? this.stepsRo,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      saves: saves ?? this.saves,
      createdByUid: createdByUid ?? this.createdByUid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get ingredients in the specified language
  List<Ingredient> getIngredientsForLanguage(String languageCode) {
    switch (languageCode) {
      case 'ro':
        return ingredientsRo.isNotEmpty ? ingredientsRo : ingredients;
      default:
        return ingredients;
    }
  }

  // Get steps in the specified language
  List<StepItem> getStepsForLanguage(String languageCode) {
    switch (languageCode) {
      case 'ro':
        return stepsRo.isNotEmpty ? stepsRo : steps;
      default:
        return steps;
    }
  }

  // Get text in the specified language
  String getTextForLanguage(String languageCode) {
    return text.getTextForLanguage(languageCode);
  }

  // Check if recipe has translations
  bool get hasRomanianTranslation => 
      ingredientsRo.isNotEmpty || stepsRo.isNotEmpty || text.ro != null;

  // Get estimated cooking time
  Duration? get estimatedCookingTime {
    final totalSeconds = steps
        .where((step) => step.durationSec != null)
        .fold<int>(0, (sum, step) => sum + (step.durationSec ?? 0));
    
    return totalSeconds > 0 ? Duration(seconds: totalSeconds) : null;
  }

  // Check if recipe is user-created
  bool get isUserCreated => createdByUid != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Recipe(id: $id, title: $title, creatorHandle: $creatorHandle)';
  }
}
