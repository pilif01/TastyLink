import 'package:flutter/material.dart';
import 'package:tasty_link/models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onAddToShoppingList;
  final VoidCallback? onOpenCookingMode;
  final bool showActions;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onLike,
    this.onSave,
    this.onAddToShoppingList,
    this.onOpenCookingMode,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and language indicators
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildLanguageIndicator(recipe.lang),
                  if (recipe.hasRomanianTranslation) ...[
                    const SizedBox(width: 4),
                    _buildLanguageIndicator('RO'),
                  ],
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Creator handle
              Text(
                recipe.creatorHandle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Recipe stats
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.restaurant,
                    label: '${recipe.ingredients.length} ingredients',
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    icon: Icons.list_alt,
                    label: '${recipe.steps.length} steps',
                  ),
                  if (recipe.estimatedCookingTime != null) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(
                      icon: Icons.timer,
                      label: '${recipe.estimatedCookingTime!.inMinutes} min',
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Tags
              if (recipe.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: recipe.tags.take(3).map((tag) => Chip(
                    label: Text(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
                const SizedBox(height: 12),
              ],
              
              // Actions
              if (showActions) ...[
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.favorite_border,
                      label: '${recipe.likes}',
                      onTap: onLike,
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      icon: Icons.bookmark_border,
                      label: '${recipe.saves}',
                      onTap: onSave,
                    ),
                    const Spacer(),
                    if (recipe.isUserCreated)
                      Chip(
                        label: const Text('Your Recipe'),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageIndicator(String language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(
        language.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}