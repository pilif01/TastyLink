import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasty_link/models/shopping_item.dart';
import 'package:tasty_link/widgets/shopping_item_tile.dart';

void main() {
  group('ShoppingItemTile', () {
    late ShoppingItem testItem;

    setUp(() {
      testItem = ShoppingItem(
        id: 'test-item-1',
        name: 'Test Item',
        quantity: 2.0,
        unit: 'cups',
        category: 'Pantry',
        checked: false,
        recipeId: 'test-recipe-1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
    });

    testWidgets('should display item name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: testItem,
              onTap: () {},
              onCheckChanged: (checked) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Item'), findsOneWidget);
    });

    testWidgets('should display quantity and unit', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: testItem,
              onTap: () {},
              onCheckChanged: (checked) {},
            ),
          ),
        ),
      );

      expect(find.text('2.0 cups'), findsOneWidget);
    });

    testWidgets('should display category', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: testItem,
              onTap: () {},
              onCheckChanged: (checked) {},
            ),
          ),
        ),
      );

      expect(find.text('Pantry'), findsOneWidget);
    });

    testWidgets('should show unchecked checkbox by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: testItem,
              onTap: () {},
              onCheckChanged: (checked) {},
            ),
          ),
        ),
      );

      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);
      
      final checkboxWidget = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget.value, isFalse);
    });

    testWidgets('should show checked checkbox when item is checked', (WidgetTester tester) async {
      final checkedItem = testItem.copyWith(checked: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: checkedItem,
              onTap: () {},
              onCheckChanged: (checked) {},
            ),
          ),
        ),
      );

      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);
      
      final checkboxWidget = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget.value, isTrue);
    });

    testWidgets('should call onCheckChanged when checkbox is tapped', (WidgetTester tester) async {
      bool? lastCheckedValue;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: testItem,
              onTap: () {},
              onCheckChanged: (checked) {
                lastCheckedValue = checked;
              },
            ),
          ),
        ),
      );

      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox);
      await tester.pump();

      expect(lastCheckedValue, isTrue);
    });

    testWidgets('should call onTap when item is tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: testItem,
              onTap: () {
                tapped = true;
              },
              onCheckChanged: (checked) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ShoppingItemTile));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should handle item without quantity', (WidgetTester tester) async {
      final itemWithoutQuantity = testItem.copyWith(
        quantity: null,
        unit: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: itemWithoutQuantity,
              onTap: () {},
              onCheckChanged: (checked) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('Pantry'), findsOneWidget);
    });

    testWidgets('should handle item without category', (WidgetTester tester) async {
      final itemWithoutCategory = testItem.copyWith(
        category: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: itemWithoutCategory,
              onTap: () {},
              onCheckChanged: (checked) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('2.0 cups'), findsOneWidget);
    });

    testWidgets('should display correct layout for different screen sizes', (WidgetTester tester) async {
      // Test on small screen
      await tester.binding.setSurfaceSize(const Size(300, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: testItem,
              onTap: () {},
              onCheckChanged: (checked) {},
            ),
          ),
        ),
      );

      expect(find.byType(ShoppingItemTile), findsOneWidget);

      // Test on large screen
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: testItem,
              onTap: () {},
              onCheckChanged: (checked) {},
            ),
          ),
        ),
      );

      expect(find.byType(ShoppingItemTile), findsOneWidget);
    });

    testWidgets('should handle long item names', (WidgetTester tester) async {
      final itemWithLongName = testItem.copyWith(
        name: 'This is a very long item name that should be handled gracefully by the widget',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: itemWithLongName,
              onTap: () {},
              onCheckChanged: (checked) {},
            ),
          ),
        ),
      );

      expect(find.text('This is a very long item name that should be handled gracefully by the widget'), findsOneWidget);
    });

    testWidgets('should handle special characters in item name', (WidgetTester tester) async {
      final itemWithSpecialChars = testItem.copyWith(
        name: 'Item with special chars: @#\$%^&*()',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: itemWithSpecialChars,
              onTap: () {},
              onCheckChanged: (checked) {},
            ),
          ),
        ),
      );

      expect(find.text('Item with special chars: @#\$%^&*()'), findsOneWidget);
    });

    testWidgets('should handle different quantity formats', (WidgetTester tester) async {
      // Test with decimal quantity
      final itemWithDecimal = testItem.copyWith(
        quantity: 1.5,
        unit: 'tablespoons',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: itemWithDecimal,
              onTap: () {},
              onCheckChanged: (checked) {},
            ),
          ),
        ),
      );

      expect(find.text('1.5 tablespoons'), findsOneWidget);
    });

    testWidgets('should handle different categories', (WidgetTester tester) async {
      final categories = ['Pantry', 'Meat & Seafood', 'Vegetables', 'Dairy & Eggs', 'Condiments & Oils', 'Other'];
      
      for (final category in categories) {
        final itemWithCategory = testItem.copyWith(category: category);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShoppingItemTile(
                item: itemWithCategory,
                onTap: () {},
                onCheckChanged: (checked) {},
              ),
            ),
          ),
        );

        expect(find.text(category), findsOneWidget);
      }
    });
  });
}
