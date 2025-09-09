import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

class RecipeDetailPage extends ConsumerWidget {
  final String recipeId;
  
  const RecipeDetailPage({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recipeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.go('/recipe/$recipeId/edit');
            },
            tooltip: l10n.editRecipe,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
            tooltip: l10n.shareRecipe,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Detalii rețetă',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $recipeId',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/cooking/$recipeId');
        },
        icon: const Icon(Icons.play_arrow),
        label: Text(l10n.startCooking),
      ),
    );
  }
}
