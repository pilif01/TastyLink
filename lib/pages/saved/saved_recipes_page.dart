import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../models/models.dart';

// State providers
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedTagsProvider = StateProvider<List<String>>((ref) => []);
final savedRecipesProvider = FutureProvider<List<UserRecipe>>((ref) async {
  // For now, return empty list since we don't have user authentication
  // In a real app, this would fetch from DataService
  return [];
});

class SavedRecipesPage extends ConsumerWidget {
  const SavedRecipesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTags = ref.watch(selectedTagsProvider);
    final savedRecipesAsync = ref.watch(savedRecipesProvider);
    final searchQuery = ref.watch(searchQueryProvider);

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
          // Search bar
          if (searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Căutare: "$searchQuery"',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  ),
                ],
              ),
            ),
          
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
            child: savedRecipesAsync.when(
              data: (savedRecipes) {
                if (savedRecipes.isEmpty) {
                  return EmptyState(
                    imagePath: 'assets/illustrations/saved_notebook.png',
                    title: 'Încă nu ai salvat rețete.',
                    action: ElevatedButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.add),
                      label: const Text('Adaugă prima rețetă'),
                    ),
                  );
                }
                return _buildRecipesList(context, ref, savedRecipes);
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
                      'Eroare la încărcarea rețetelor salvate',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(savedRecipesProvider),
                      child: const Text('Încearcă din nou'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesList(BuildContext context, WidgetRef ref, List<UserRecipe> recipes) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final userRecipe = recipes[index];
        return ListTile(
          leading: userRecipe.coverImageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    userRecipe.coverImageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
          title: Text(userRecipe.title),
          subtitle: Text('De la ${userRecipe.creatorHandle}'),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showRecipeOptions(context, userRecipe),
          ),
          onTap: () => _openRecipeDetail(context, userRecipe),
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

  void _openRecipeDetail(BuildContext context, UserRecipe userRecipe) {
    context.go('/recipe/${userRecipe.id}');
  }

  void _showRecipeOptions(BuildContext context, UserRecipe userRecipe) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Vezi rețeta'),
              onTap: () {
                Navigator.of(context).pop();
                _openRecipeDetail(context, userRecipe);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editează'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement edit functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Șterge'),
              onTap: () {
                Navigator.of(context).pop();
                _deleteRecipe(context, userRecipe);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteRecipe(BuildContext context, UserRecipe userRecipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Șterge rețeta'),
        content: Text('Ești sigur că vrei să ștergi "${userRecipe.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anulează'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rețeta a fost ștearsă'),
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
}