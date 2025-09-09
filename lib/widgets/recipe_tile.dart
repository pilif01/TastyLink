import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class RecipeTile extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final bool showCreator;

  const RecipeTile({
    super.key,
    required this.recipe,
    this.onTap,
    this.showCreator = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              // Cover Image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                child: recipe.media.coverImageUrl != null
                    ? Image.network(
                        recipe.media.coverImageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: Icon(
                              Icons.restaurant,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 32,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 32,
                        ),
                      ),
              ),
              
              const SizedBox(width: AppTheme.spacingM),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      recipe.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (showCreator) ...[
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        '@${recipe.creatorHandle}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: AppTheme.spacingS),
                    
                    // Tags
                    if (recipe.tags.isNotEmpty)
                      Wrap(
                        spacing: AppTheme.spacingXS,
                        runSpacing: AppTheme.spacingXS,
                        children: recipe.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingS,
                              vertical: AppTheme.spacingXS,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(AppTheme.radiusS),
                            ),
                            child: Text(
                              tag,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              
              // Stats
              Column(
                children: [
                  Icon(
                    Icons.bookmark,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  Text(
                    recipe.saves.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
