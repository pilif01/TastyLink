import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/empty_state.dart';
import '../../core/constants.dart';

// State providers
final shoppingItemsProvider = StateProvider<List<ShoppingItem>>((ref) => []);
final groupedItemsProvider = Provider<Map<String, List<ShoppingItem>>>((ref) {
  final items = ref.watch(shoppingItemsProvider);
  final grouped = <String, List<ShoppingItem>>{};
  
  for (final item in items) {
    final category = item.category ?? 'Other';
    if (!grouped.containsKey(category)) {
      grouped[category] = [];
    }
    grouped[category]!.add(item);
  }
  
  return grouped;
});

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final shoppingItems = ref.watch(shoppingItemsProvider);
    final groupedItems = ref.watch(groupedItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shopping),
        actions: [
          IconButton(
            icon: const Icon(Icons.merge),
            onPressed: () => _consolidateDuplicates(context, ref),
            tooltip: 'Consolidează duplicatele',
          ),
        ],
      ),
      body: shoppingItems.isEmpty
          ? EmptyState(
              imagePath: 'assets/illustrations/cart_empty.png',
              title: 'Lista de cumpărături este goală',
            )
          : _buildShoppingList(context, ref, groupedItems),
      floatingActionButton: shoppingItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _clearList(context, ref),
              icon: const Icon(Icons.clear_all),
              label: const Text('Golește lista'),
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            )
          : null,
    );
  }

  Widget _buildShoppingList(BuildContext context, WidgetRef ref, Map<String, List<ShoppingItem>> groupedItems) {
    final theme = Theme.of(context);
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final category = groupedItems.keys.elementAt(index);
        final items = groupedItems[category]!;
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: ExpansionTile(
            title: Row(
              children: [
                Icon(
                  _getCategoryIcon(category),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  IngredientCategory.labels[category] ?? category,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${items.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            children: items.map((item) => _buildShoppingItem(context, ref, item)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildShoppingItem(BuildContext context, WidgetRef ref, ShoppingItem item) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Checkbox(
        value: item.checked,
        onChanged: (value) {
          final items = ref.read(shoppingItemsProvider);
          final updatedItems = items.map((i) {
            if (i.id == item.id) {
              return i.copyWith(checked: value ?? false);
            }
            return i;
          }).toList();
          ref.read(shoppingItemsProvider.notifier).state = updatedItems;
        },
      ),
      title: Text(
        item.name,
        style: TextStyle(
          decoration: item.checked ? TextDecoration.lineThrough : null,
          color: item.checked ? theme.colorScheme.onSurfaceVariant : null,
        ),
      ),
      subtitle: item.quantity != null && item.unit != null
          ? Text('${item.quantity} ${item.unit}')
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _editItem(context, ref, item),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => _deleteItem(context, ref, item),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case IngredientCategory.produce:
        return Icons.local_florist;
      case IngredientCategory.dairy:
        return Icons.local_drink;
      case IngredientCategory.meat:
        return Icons.restaurant;
      case IngredientCategory.pantry:
        return Icons.kitchen;
      case IngredientCategory.spices:
        return Icons.spa;
      case IngredientCategory.bakery:
        return Icons.cake;
      case IngredientCategory.beverages:
        return Icons.local_bar;
      default:
        return Icons.shopping_basket;
    }
  }

  void _editItem(BuildContext context, WidgetRef ref, ShoppingItem item) {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(text: item.quantity?.toString() ?? '');
    final unitController = TextEditingController(text: item.unit ?? '');
    String selectedCategory = item.category ?? 'Other';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editează articolul'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nume',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Cantitate',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: TextField(
                    controller: unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unitate',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categorie',
                prefixIcon: Icon(Icons.category),
              ),
              items: IngredientCategory.all.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(IngredientCategory.labels[category] ?? category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedCategory = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              final updatedItem = item.copyWith(
                name: nameController.text,
                quantity: double.tryParse(quantityController.text),
                unit: unitController.text.isEmpty ? null : unitController.text,
                category: selectedCategory,
              );
              
              final items = ref.read(shoppingItemsProvider);
              final updatedItems = items.map((i) {
                if (i.id == item.id) {
                  return updatedItem;
                }
                return i;
              }).toList();
              ref.read(shoppingItemsProvider.notifier).state = updatedItems;
              
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _deleteItem(BuildContext context, WidgetRef ref, ShoppingItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Șterge articolul'),
        content: Text('Ești sigur că vrei să ștergi "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              final items = ref.read(shoppingItemsProvider);
              final updatedItems = items.where((i) => i.id != item.id).toList();
              ref.read(shoppingItemsProvider.notifier).state = updatedItems;
              Navigator.of(context).pop();
            },
            child: const Text('Șterge'),
          ),
        ],
      ),
    );
  }

  void _consolidateDuplicates(BuildContext context, WidgetRef ref) {
    final items = ref.read(shoppingItemsProvider);
    final consolidated = <String, ShoppingItem>{};
    
    for (final item in items) {
      final key = '${item.name.toLowerCase()}_${item.unit ?? ''}';
      if (consolidated.containsKey(key)) {
        final existing = consolidated[key]!;
        final newQuantity = (existing.quantity ?? 0) + (item.quantity ?? 0);
        consolidated[key] = existing.copyWith(quantity: newQuantity);
      } else {
        consolidated[key] = item;
      }
    }
    
    final consolidatedItems = consolidated.values.toList();
    ref.read(shoppingItemsProvider.notifier).state = consolidatedItems;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Consolidate ${items.length - consolidatedItems.length} duplicate items'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _clearList(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Golește lista'),
        content: const Text('Ești sigur că vrei să golești toată lista de cumpărături?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(shoppingItemsProvider.notifier).state = [];
              Navigator.of(context).pop();
            },
            child: const Text('Confirmă'),
          ),
        ],
      ),
    );
  }
}