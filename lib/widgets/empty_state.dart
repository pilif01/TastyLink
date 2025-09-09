import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.imagePath,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Image.asset(
              imagePath,
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.spacingM),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            if (action != null) ...[
              const SizedBox(height: AppTheme.spacingXL),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
