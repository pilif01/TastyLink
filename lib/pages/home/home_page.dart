import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confetti_widget.dart';
import '../../models/models.dart';

// State providers
final linkControllerProvider = StateProvider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

final isProcessingProvider = StateProvider<bool>((ref) => false);
final currentRecipeProvider = StateProvider<Recipe?>((ref) => null);
final showConfettiProvider = StateProvider<bool>((ref) => false);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkController = ref.watch(linkControllerProvider);
    final isProcessing = ref.watch(isProcessingProvider);
    final currentRecipe = ref.watch(currentRecipeProvider);
    final showConfetti = ref.watch(showConfettiProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/brand/logo_mark.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              'Tasty Link',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: ConfettiWidget(
        isActive: showConfetti,
        duration: AppTheme.confettiDuration,
        child: currentRecipe == null
            ? _EmptyState(
                linkController: linkController,
                isProcessing: isProcessing,
                onProcessRecipe: () => _processRecipe(context, ref),
              )
            : _RecipeDisplay(
                recipe: currentRecipe,
                onSave: () => _saveRecipe(context, ref),
                onAddToShoppingList: () => _addToShoppingList(context, ref),
                onOpenCookingMode: () => _openCookingMode(context, ref),
                onNewRecipe: () => _newRecipe(ref),
              ),
      ),
    );
  }

  Future<void> _processRecipe(BuildContext context, WidgetRef ref) async {
    final linkController = ref.read(linkControllerProvider);
    final link = linkController.text.trim();
    
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vă rugăm să introduceți un link'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    ref.read(isProcessingProvider.notifier).state = true;

    try {
      // Simulate recipe processing
      await Future.delayed(const Duration(seconds: 2));
      
      // Create a mock recipe for demonstration
      final mockRecipe = Recipe.createFromSource(
        sourceLink: link,
        title: 'Rețetă demonstrativă',
        creatorHandle: 'chef_demo',
        lang: 'ro',
        text: RecipeText(
          original: 'O rețetă delicioasă pentru demonstrație',
          ro: 'O rețetă delicioasă pentru demonstrație',
        ),
        media: RecipeMedia(
          coverImageUrl: 'https://picsum.photos/400/300?random=1',
          stepPhotos: [
            'https://picsum.photos/400/300?random=2',
            'https://picsum.photos/400/300?random=3',
          ],
        ),
        ingredients: [
          Ingredient(name: 'făină', quantity: 2, unit: 'căni'),
          Ingredient(name: 'zahăr', quantity: 1, unit: 'cană'),
          Ingredient(name: 'ouă', quantity: 3, unit: 'bucăți'),
        ],
        steps: [
          StepItem(index: 1, text: 'Amestecă ingredientele uscate', durationSec: 300),
          StepItem(index: 2, text: 'Adaugă ingredientele lichide', durationSec: 180),
          StepItem(index: 3, text: 'Coace la 180°C timp de 25 de minute', durationSec: 1500),
        ],
        tags: ['desert', 'coacere', 'dulce'],
      );

      ref.read(currentRecipeProvider.notifier).state = mockRecipe;
      ref.read(isProcessingProvider.notifier).state = false;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rețeta a fost procesată!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ref.read(isProcessingProvider.notifier).state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare la procesarea rețetei: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _saveRecipe(BuildContext context, WidgetRef ref) {
    final currentRecipe = ref.read(currentRecipeProvider);
    if (currentRecipe != null) {
      // Save recipe logic here
      ref.read(showConfettiProvider.notifier).state = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rețeta a fost salvată!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _addToShoppingList(BuildContext context, WidgetRef ref) {
    final currentRecipe = ref.read(currentRecipeProvider);
    if (currentRecipe != null) {
      // Add to shopping list logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Adăugat în lista de cumpărături'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _openCookingMode(BuildContext context, WidgetRef ref) {
    // Navigate to cooking mode
    // This would be implemented with proper routing
  }

  void _newRecipe(WidgetRef ref) {
    ref.read(currentRecipeProvider.notifier).state = null;
    ref.read(linkControllerProvider).clear();
    ref.read(showConfettiProvider.notifier).state = false;
  }
}

class _EmptyState extends StatelessWidget {
  final TextEditingController linkController;
  final bool isProcessing;
  final VoidCallback onProcessRecipe;

  const _EmptyState({
    required this.linkController,
    required this.isProcessing,
    required this.onProcessRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      imagePath: 'assets/illustrations/home_plate_link.png',
      title: 'Adaugă un link de pe TikTok, Reels sau Shorts',
      action: Column(
        children: [
          TextField(
            controller: linkController,
            decoration: const InputDecoration(
              hintText: 'Lipește linkul aici',
              prefixIcon: Icon(Icons.link),
            ),
            enabled: !isProcessing,
          ),
          const SizedBox(height: AppTheme.spacingL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isProcessing ? null : onProcessRecipe,
              icon: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: const Text('Procesează rețeta'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeDisplay extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onSave;
  final VoidCallback onAddToShoppingList;
  final VoidCallback onOpenCookingMode;
  final VoidCallback onNewRecipe;

  const _RecipeDisplay({
    required this.recipe,
    required this.onSave,
    required this.onAddToShoppingList,
    required this.onOpenCookingMode,
    required this.onNewRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          RecipeCard(
            recipe: recipe,
            onSave: onSave,
            onAddToShoppingList: onAddToShoppingList,
            onOpenCookingMode: onOpenCookingMode,
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: OutlinedButton.icon(
              onPressed: onNewRecipe,
              icon: const Icon(Icons.add),
              label: const Text('Procesează altă rețetă'),
            ),
          ),
        ],
      ),
    );
  }
}