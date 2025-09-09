import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasty_link/models/recipe.dart';
import 'package:tasty_link/models/ingredient.dart';
import 'package:tasty_link/models/step_item.dart';
import 'package:tasty_link/models/recipe_text.dart';
import 'package:tasty_link/models/recipe_media.dart';
import 'package:tasty_link/widgets/recipe_card.dart';

void main() {
  group('RecipeCard', () {
    late Recipe testRecipe;

    setUp(() {
      testRecipe = Recipe(
        id: 'test-recipe-1',
        title: 'Test Recipe',
        creatorHandle: 'test_creator',
        sourceLink: 'https://example.com/recipe',
        lang: 'en',
        text: RecipeText(
          original: 'This is a test recipe description.',
          ro: 'Aceasta este o descriere de rețetă de test.',
        ),
        media: RecipeMedia(
          coverImageUrl: 'https://example.com/thumbnail.jpg',
          videoUrl: 'https://example.com/video.mp4',
        ),
        ingredients: [
          Ingredient(
            name: 'flour',
            quantity: 2.0,
            unit: 'cups',
            category: 'Pantry',
          ),
          Ingredient(
            name: 'sugar',
            quantity: 1.0,
            unit: 'cup',
            category: 'Pantry',
          ),
        ],
        steps: [
          StepItem(
            index: 1,
            text: 'Mix dry ingredients',
            durationSec: 300,
          ),
          StepItem(
            index: 2,
            text: 'Add wet ingredients',
            durationSec: 180,
          ),
        ],
        tags: ['dessert', 'easy'],
        likes: 42,
        saves: 15,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
    });

    testWidgets('should display recipe title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Recipe'), findsOneWidget);
    });

    testWidgets('should display creator handle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('test_creator'), findsOneWidget);
    });

    testWidgets('should display ingredient count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('2 ingredients'), findsOneWidget);
    });

    testWidgets('should display step count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('2 steps'), findsOneWidget);
    });

    testWidgets('should display likes count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('should display saves count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('should display tags', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('dessert'), findsOneWidget);
      expect(find.text('easy'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RecipeCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should display estimated cooking time', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {},
            ),
          ),
        ),
      );

      // Total time: 300 + 180 = 480 seconds = 8 minutes
      expect(find.text('8 min'), findsOneWidget);
    });

    testWidgets('should display language indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('EN'), findsOneWidget);
    });

    testWidgets('should display Romanian translation indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('RO'), findsOneWidget);
    });

    testWidgets('should handle recipe without thumbnail', (WidgetTester tester) async {
      final recipeWithoutThumbnail = testRecipe.copyWith(
        media: RecipeMedia(
          coverImageUrl: null,
          videoUrl: 'https://example.com/video.mp4',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipeWithoutThumbnail,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(RecipeCard), findsOneWidget);
    });

    testWidgets('should handle recipe without steps', (WidgetTester tester) async {
      final recipeWithoutSteps = testRecipe.copyWith(
        steps: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipeWithoutSteps,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('0 steps'), findsOneWidget);
    });

    testWidgets('should handle recipe without ingredients', (WidgetTester tester) async {
      final recipeWithoutIngredients = testRecipe.copyWith(
        ingredients: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipeWithoutIngredients,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('0 ingredients'), findsOneWidget);
    });

    testWidgets('should handle recipe without tags', (WidgetTester tester) async {
      final recipeWithoutTags = testRecipe.copyWith(
        tags: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipeWithoutTags,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(RecipeCard), findsOneWidget);
    });

    testWidgets('should handle user-created recipe', (WidgetTester tester) async {
      final userCreatedRecipe = testRecipe.copyWith(
        createdByUid: 'user123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: userCreatedRecipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(RecipeCard), findsOneWidget);
    });

    testWidgets('should display correct layout for different screen sizes', (WidgetTester tester) async {
      // Test on small screen
      await tester.binding.setSurfaceSize(const Size(300, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(RecipeCard), findsOneWidget);

      // Test on large screen
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(RecipeCard), findsOneWidget);
    });
  });
}
