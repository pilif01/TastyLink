import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';

// State providers
final recipeProvider = FutureProvider<Recipe?>((ref) async {
  final recipeId = ref.watch(recipeIdProvider);
  return await DataService.instance.getRecipe(recipeId);
});

final recipeIdProvider = StateProvider<String>((ref) => '');

class RecipeDetailPage extends ConsumerWidget {
  final String recipeId;
  
  const RecipeDetailPage({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    // Set the recipe ID in the provider
    ref.read(recipeIdProvider.notifier).state = recipeId;
    
    final recipeAsync = ref.watch(recipeProvider);
    
    return Scaffold(
      body: recipeAsync.when(
        data: (recipe) {
          if (recipe == null) {
            return _buildErrorState(context, 'Rețeta nu a fost găsită');
          }
          return _buildRecipeContent(context, ref, recipe);
        },
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, 'Eroare la încărcarea rețetei: $error'),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eroare'),
      ),
      body: Center(
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
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Înapoi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeContent(BuildContext context, WidgetRef ref, Recipe recipe) {
    
    return Scaffold(
      body: CustomScrollView(
      slivers: [
        // App bar with image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (recipe.media.coverImageUrl != null)
                  Image.network(
                    recipe.media.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  )
                else
                  Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.restaurant,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Title overlay
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareRecipe(context, recipe),
              tooltip: 'Partajează rețeta',
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, ref, value, recipe),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit),
                      const SizedBox(width: 8),
                      const Text('Editează rețeta'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'save',
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark_add),
                      const SizedBox(width: 8),
                      const Text('Salvează'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'shopping',
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart),
                      const SizedBox(width: 8),
                      const Text('Adaugă la lista de cumpărături'),
                    ],
                  ),
                ),
                if (recipe.sourceLink.isNotEmpty)
                  PopupMenuItem(
                    value: 'source',
                    child: Row(
                      children: [
                        const Icon(Icons.link),
                        const SizedBox(width: 8),
                        const Text('Vezi sursa originală'),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        
        // Recipe content
        SliverPadding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Recipe info
              _buildRecipeInfo(context, recipe),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Ingredients section
              _buildIngredientsSection(context, recipe),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Steps section
              _buildStepsSection(context, recipe),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Tags
              if (recipe.tags.isNotEmpty) _buildTagsSection(context, recipe),
              
              const SizedBox(height: 100), // Space for FAB
            ]),
          ),
        ),
      ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/cooking/${recipe.id}'),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Începe gătitul'),
      ),
    );
  }

  Widget _buildRecipeInfo(BuildContext context, Recipe recipe) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'De la ${recipe.creatorHandle}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Timp total: ${_calculateTotalTime(recipe)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            if (recipe.ingredients.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${recipe.ingredients.length} ingrediente',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
            if (recipe.steps.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.list_alt,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${recipe.steps.length} pași',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection(BuildContext context, Recipe recipe) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingrediente',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        ...recipe.ingredients.map((ingredient) => _buildIngredientItem(context, ingredient)),
      ],
    );
  }

  Widget _buildIngredientItem(BuildContext context, Ingredient ingredient) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient.name,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (ingredient.quantity != null && ingredient.unit != null)
            Text(
              '${ingredient.quantity} ${ingredient.unit}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepsSection(BuildContext context, Recipe recipe) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pași de preparare',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        ...recipe.steps.map((step) => _buildStepItem(context, step)),
      ],
    );
  }

  Widget _buildStepItem(BuildContext context, StepItem step) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  step.index.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.text,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (step.durationSec != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(step.durationSec!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context, Recipe recipe) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etichete',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recipe.tags.map((tag) => Chip(
            label: Text(tag),
            backgroundColor: theme.colorScheme.primaryContainer,
            labelStyle: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          )).toList(),
        ),
      ],
    );
  }

  String _calculateTotalTime(Recipe recipe) {
    final totalSeconds = recipe.steps.fold<int>(0, (sum, step) => sum + (step.durationSec ?? 0));
    return _formatDuration(totalSeconds);
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  void _shareRecipe(BuildContext context, Recipe recipe) {
    final text = 'Verifică această rețetă delicioasă: ${recipe.title}';
    Share.share(text);
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action, Recipe recipe) {
    switch (action) {
      case 'edit':
        context.go('/recipe/${recipe.id}/edit');
        break;
      case 'save':
        _saveRecipe(context, ref, recipe);
        break;
      case 'shopping':
        _addToShoppingList(context, ref, recipe);
        break;
      case 'source':
        _openSourceLink(context, recipe);
        break;
    }
  }

  void _saveRecipe(BuildContext context, WidgetRef ref, Recipe recipe) {
    // TODO: Implement save recipe functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rețeta "${recipe.title}" a fost salvată!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _addToShoppingList(BuildContext context, WidgetRef ref, Recipe recipe) {
    // TODO: Implement add to shopping list functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ingredientele au fost adăugate la lista de cumpărături!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _openSourceLink(BuildContext context, Recipe recipe) async {
    final uri = Uri.parse(recipe.sourceLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nu s-a putut deschide linkul'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
