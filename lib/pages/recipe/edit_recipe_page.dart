import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

class EditRecipePage extends ConsumerWidget {
  final String recipeId;
  
  const EditRecipePage({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editRecipe),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement save functionality
              context.pop();
            },
            child: Text(l10n.done),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Editează rețeta',
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
    );
  }
}
