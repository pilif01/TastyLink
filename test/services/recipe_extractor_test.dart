import 'package:flutter_test/flutter_test.dart';
import 'package:tasty_link/services/recipe_extractor.dart';

void main() {
  group('RecipeExtractor', () {
    late RecipeExtractor extractor;

    setUp(() {
      extractor = RecipeExtractor();
    });

    group('Ingredient Extraction', () {
      test('should extract ingredients with quantities and units', () {
        const text = '''
        Ingredients:
        2 cups all-purpose flour
        1 tsp baking soda
        1/2 cup butter, softened
        3/4 cup granulated sugar
        2 large eggs
        2 tsp vanilla extract
        ''';

        final ingredients = extractor.extractIngredients(text);

        expect(ingredients.length, equals(6));
        
        expect(ingredients[0].name, equals('all-purpose flour'));
        expect(ingredients[0].quantity, equals(2.0));
        expect(ingredients[0].unit, equals('cups'));
        
        expect(ingredients[1].name, equals('baking soda'));
        expect(ingredients[1].quantity, equals(1.0));
        expect(ingredients[1].unit, equals('tsp'));
        
        expect(ingredients[2].name, equals('butter, softened'));
        expect(ingredients[2].quantity, equals(0.5));
        expect(ingredients[2].unit, equals('cup'));
      });

      test('should extract ingredients without quantities', () {
        const text = '''
        Ingredients:
        salt
        pepper
        olive oil
        fresh herbs
        ''';

        final ingredients = extractor.extractIngredients(text);

        expect(ingredients.length, equals(4));
        
        expect(ingredients[0].name, equals('salt'));
        expect(ingredients[0].quantity, isNull);
        expect(ingredients[0].unit, isNull);
        
        expect(ingredients[1].name, equals('pepper'));
        expect(ingredients[1].quantity, isNull);
        expect(ingredients[1].unit, isNull);
      });

      test('should handle fractional quantities', () {
        const text = '''
        Ingredients:
        1/2 cup milk
        1/4 tsp salt
        3/4 lb ground beef
        ''';

        final ingredients = extractor.extractIngredients(text);

        expect(ingredients.length, equals(3));
        
        expect(ingredients[0].quantity, equals(0.5));
        expect(ingredients[1].quantity, equals(0.25));
        expect(ingredients[2].quantity, equals(0.75));
      });

      test('should categorize ingredients correctly', () {
        const text = '''
        Ingredients:
        2 cups flour
        1 lb chicken breast
        1 onion, diced
        1 cup milk
        2 tbsp olive oil
        ''';

        final ingredients = extractor.extractIngredients(text);

        expect(ingredients[0].category, equals('Pantry')); // flour
        expect(ingredients[1].category, equals('Meat & Seafood')); // chicken
        expect(ingredients[2].category, equals('Vegetables')); // onion
        expect(ingredients[3].category, equals('Dairy & Eggs')); // milk
        expect(ingredients[4].category, equals('Condiments & Oils')); // olive oil
      });
    });

    group('Step Extraction', () {
      test('should extract numbered steps', () {
        const text = '''
        Instructions:
        1. Preheat oven to 375°F
        2. Mix flour and sugar in a bowl
        3. Add eggs and vanilla
        4. Bake for 12-15 minutes
        ''';

        final steps = extractor.extractSteps(text);

        expect(steps.length, equals(4));
        
        expect(steps[0].index, equals(1));
        expect(steps[0].text, equals('Preheat oven to 375°F'));
        
        expect(steps[1].index, equals(2));
        expect(steps[1].text, equals('Mix flour and sugar in a bowl'));
      });

      test('should extract steps with parentheses', () {
        const text = '''
        Instructions:
        1) Heat oil in a large pan
        2) Add onions and cook until soft
        3) Add garlic and cook for 1 minute
        ''';

        final steps = extractor.extractSteps(text);

        expect(steps.length, equals(3));
        
        expect(steps[0].index, equals(1));
        expect(steps[0].text, equals('Heat oil in a large pan'));
      });

      test('should extract steps with written numbers', () {
        const text = '''
        Instructions:
        First, preheat the oven
        Second, mix the ingredients
        Third, bake for 20 minutes
        ''';

        final steps = extractor.extractSteps(text);

        expect(steps.length, equals(3));
        
        expect(steps[0].index, equals(1));
        expect(steps[0].text, equals('preheat the oven'));
        
        expect(steps[1].index, equals(2));
        expect(steps[1].text, equals('mix the ingredients'));
      });

      test('should extract duration from steps', () {
        const text = '''
        Instructions:
        1. Cook for 5 minutes
        2. Simmer for 30 minutes
        3. Bake for 1 hour
        4. Let rest for 10 seconds
        ''';

        final steps = extractor.extractSteps(text);

        expect(steps[0].durationSec, equals(300)); // 5 minutes
        expect(steps[1].durationSec, equals(1800)); // 30 minutes
        expect(steps[2].durationSec, equals(3600)); // 1 hour
        expect(steps[3].durationSec, equals(10)); // 10 seconds
      });
    });

    group('Title Extraction', () {
      test('should extract title from first line', () {
        const text = '''
        Classic Chocolate Chip Cookies
        
        Ingredients:
        2 cups flour
        ''';

        final title = extractor.extractTitle(text);

        expect(title, equals('Classic Chocolate Chip Cookies'));
      });

      test('should not extract title from ingredient line', () {
        const text = '''
        Ingredients:
        2 cups flour
        1 cup sugar
        ''';

        final title = extractor.extractTitle(text);

        expect(title, isNull);
      });

      test('should not extract title from instruction line', () {
        const text = '''
        Instructions:
        1. Preheat oven
        2. Mix ingredients
        ''';

        final title = extractor.extractTitle(text);

        expect(title, isNull);
      });
    });

    group('Full Recipe Extraction', () {
      test('should extract complete recipe', () {
        const text = '''
        Simple Pancakes
        
        Ingredients:
        1 cup flour
        1 tbsp sugar
        1 tsp baking powder
        1/2 tsp salt
        1 cup milk
        1 egg
        2 tbsp butter, melted
        
        Instructions:
        1. Mix dry ingredients in a bowl
        2. Whisk wet ingredients in another bowl
        3. Combine wet and dry ingredients
        4. Cook on griddle for 2-3 minutes per side
        ''';

        final result = extractor.extractRecipe(text);

        expect(result.title, equals('Simple Pancakes'));
        expect(result.ingredients.length, equals(7));
        expect(result.steps.length, equals(4));
        expect(result.confidence, greaterThan(0.5));
      });

      test('should handle malformed text gracefully', () {
        const text = '''
        Some random text
        without clear structure
        but with some ingredients
        and steps mixed in
        ''';

        final result = extractor.extractRecipe(text);

        expect(result.title, isNull);
        expect(result.ingredients.length, equals(0));
        expect(result.steps.length, equals(0));
        expect(result.confidence, lessThan(0.5));
      });
    });

    group('Edge Cases', () {
      test('should handle empty text', () {
        const text = '';

        final result = extractor.extractRecipe(text);

        expect(result.title, isNull);
        expect(result.ingredients.length, equals(0));
        expect(result.steps.length, equals(0));
        expect(result.confidence, equals(0.0));
      });

      test('should handle text with only whitespace', () {
        const text = '   \n  \t  \n  ';

        final result = extractor.extractRecipe(text);

        expect(result.title, isNull);
        expect(result.ingredients.length, equals(0));
        expect(result.steps.length, equals(0));
        expect(result.confidence, equals(0.0));
      });

      test('should handle very long text', () {
        final text = 'A' * 10000;

        final result = extractor.extractRecipe(text);

        expect(result.title, isNull);
        expect(result.ingredients.length, equals(0));
        expect(result.steps.length, equals(0));
        expect(result.confidence, lessThan(0.5));
      });

      test('should handle text with special characters', () {
        const text = '''
        Spicy Thai Curry 🍛
        
        Ingredients:
        2 tbsp coconut oil
        1 can (14 oz) coconut milk
        2 tbsp red curry paste
        1 lb chicken, cut into pieces
        1 bell pepper, sliced
        2 tbsp fish sauce
        1 tbsp brown sugar
        1/4 cup fresh basil leaves
        
        Instructions:
        1. Heat oil in a large pan over medium heat
        2. Add curry paste and cook for 1 minute
        3. Add coconut milk and bring to a simmer
        4. Add chicken and cook for 10 minutes
        5. Add bell pepper and cook for 5 minutes
        6. Season with fish sauce and brown sugar
        7. Garnish with fresh basil
        ''';

        final result = extractor.extractRecipe(text);

        expect(result.title, equals('Spicy Thai Curry 🍛'));
        expect(result.ingredients.length, equals(8));
        expect(result.steps.length, equals(7));
        expect(result.confidence, greaterThan(0.7));
      });
    });
  });
}
