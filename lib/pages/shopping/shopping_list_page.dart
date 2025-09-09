import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/empty_state.dart';
import '../../core/constants.dart';

// State providers
final shoppingItemsProvider = FutureProvider<List<ShoppingItem>>((ref) async {
  // For now, return empty list since we don't have user authentication
  // In a real app, this would fetch from DataService
  return [];
});

final groupedItemsProvider = Provider<Map<String, List<ShoppingItem>>>((ref) {
  final itemsAsync = ref.watch(shoppingItemsProvider);
  return itemsAsync.when(
    data: (items) {
      final grouped = <String, List<ShoppingItem>>{};
      
      for (final item in items) {
        final category = item.category ?? 'Other';
        if (!grouped.containsKey(category)) {
          grouped[category] = [];
        }
        grouped[category]!.add(item);
      }
      
      return grouped;
    },
    loading: () => <String, List<ShoppingItem>>{},
    error: (error, stack) => <String, List<ShoppingItem>>{},
  );
});

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final shoppingItemsAsync = ref.watch(shoppingItemsProvider);
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
      body: shoppingItemsAsync.when(
        data: (shoppingItems) {
          if (shoppingItems.isEmpty) {
            return EmptyState(
              imagePath: 'assets/illustrations/cart_empty.png',
              title: 'Lista de cumpărături este goală',
              action: ElevatedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.add),
                label: const Text('Adaugă ingrediente'),
              ),
            );
          }
          return _buildShoppingList(context, ref, groupedItems);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Eroare la încărcarea listei de cumpărături',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(shoppingItemsProvider),
                child: const Text('Încearcă din nou'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: shoppingItemsAsync.when(
        data: (shoppingItems) => shoppingItems.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () => _clearList(context, ref),
                icon: const Icon(Icons.clear_all),
                label: const Text('Golește lista'),
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              )
            : null,
        loading: () => null,
        error: (error, stack) => null,
      ),
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
          // TODO: Implement update shopping item functionality
          // This would update the item in the data service
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
              // TODO: Implement update shopping item functionality
              // This would update the item in the data service
              
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
              // TODO: Implement delete shopping item functionality
              // This would delete the item from the data service
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Articolul a fost șters'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Șterge'),
          ),
        ],
      ),
    );
  }

  void _consolidateDuplicates(BuildContext context, WidgetRef ref) {
    // TODO: Implement consolidate duplicates functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcționalitatea de consolidare va fi implementată'),
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
              // TODO: Implement clear list functionality
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lista a fost golită'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Confirmă'),
          ),
        ],
      ),
    );
  }
}