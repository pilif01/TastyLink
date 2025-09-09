import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/recipe_tile.dart';
import '../../widgets/empty_state.dart';
import '../../models/models.dart';

// State providers
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedTagsProvider = StateProvider<List<String>>((ref) => []);
final savedRecipesProvider = StateProvider<List<Recipe>>((ref) => []);

class SavedRecipesPage extends ConsumerWidget {
  const SavedRecipesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTags = ref.watch(selectedTagsProvider);
    final savedRecipes = ref.watch(savedRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salvate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (selectedTags.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedTags.length,
                itemBuilder: (context, index) {
                  final tag = selectedTags[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacingS),
                    child: FilterChip(
                      label: Text(tag),
                      selected: true,
                      onSelected: (selected) {
                        if (!selected) {
                          ref.read(selectedTagsProvider.notifier).state = 
                              selectedTags.where((t) => t != tag).toList();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          
          // Recipes list
          Expanded(
            child: savedRecipes.isEmpty
            ? EmptyState(
                imagePath: 'assets/illustrations/saved_notebook.png',
                title: 'Încă nu ai salvat rețete.',
              )
                : _buildRecipesList(context, ref, savedRecipes),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesList(BuildContext context, WidgetRef ref, List<Recipe> recipes) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeTile(
          recipe: recipe,
          onTap: () => _openRecipeDetail(context, recipe),
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.read(searchQueryProvider);
    final controller = TextEditingController(text: searchQuery);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Caută rețete'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Caută rețete',
            prefixIcon: const Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state = controller.text;
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _openRecipeDetail(BuildContext context, Recipe recipe) {
    // Navigate to recipe detail page
    // This would be implemented with proper routing
  }
}