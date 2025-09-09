import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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
      // Extract recipe from link
      final recipe = await _extractRecipeFromLink(link);
      
      if (recipe != null) {
        ref.read(currentRecipeProvider.notifier).state = recipe;
        ref.read(isProcessingProvider.notifier).state = false;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rețeta a fost procesată cu succes!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        throw Exception('Nu s-a putut extrage rețeta din link');
      }
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

  Future<Recipe?> _extractRecipeFromLink(String link) async {
    try {
      // For demonstration, we'll create a mock recipe based on the link
      // In a real implementation, this would:
      // 1. Fetch the content from the URL
      // 2. Extract recipe data using web scraping or APIs
      // 3. Parse the content using the RecipeExtractor
      
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      
      // Create a mock recipe based on the link
      final isTikTok = link.contains('tiktok.com');
      final isInstagram = link.contains('instagram.com');
      final isYouTube = link.contains('youtube.com');
      
      String title;
      String creatorHandle;
      List<Ingredient> ingredients;
      List<StepItem> steps;
      List<String> tags;
      
      if (isTikTok) {
        title = 'Rețetă TikTok - Desert Delicios';
        creatorHandle = 'chef_tiktok';
        ingredients = [
          Ingredient(name: 'făină', quantity: 2, unit: 'căni', category: 'Pantry'),
          Ingredient(name: 'zahăr', quantity: 1, unit: 'cană', category: 'Pantry'),
          Ingredient(name: 'ouă', quantity: 3, unit: 'bucăți', category: 'Dairy & Eggs'),
          Ingredient(name: 'unt', quantity: 100, unit: 'g', category: 'Dairy & Eggs'),
          Ingredient(name: 'ciocolată', quantity: 200, unit: 'g', category: 'Pantry'),
        ];
        steps = [
          StepItem(index: 1, text: 'Amestecă făina cu zahărul într-un bol mare', durationSec: 120),
          StepItem(index: 2, text: 'Adaugă ouăle și untul topit, amestecă bine', durationSec: 180),
          StepItem(index: 3, text: 'Incorporează ciocolata tăiată în bucăți mici', durationSec: 60),
          StepItem(index: 4, text: 'Coace la 180°C timp de 25-30 de minute', durationSec: 1800),
          StepItem(index: 5, text: 'Lasă să se răcească înainte de a servi', durationSec: 600),
        ];
        tags = ['desert', 'ciocolată', 'coacere', 'dulce', 'tiktok'];
      } else if (isInstagram) {
        title = 'Rețetă Instagram - Salată Sănătoasă';
        creatorHandle = 'healthy_chef';
        ingredients = [
          Ingredient(name: 'salată verde', quantity: 1, unit: 'bucată', category: 'Vegetables'),
          Ingredient(name: 'roșii cherry', quantity: 200, unit: 'g', category: 'Vegetables'),
          Ingredient(name: 'castraveți', quantity: 1, unit: 'bucată', category: 'Vegetables'),
          Ingredient(name: 'avocado', quantity: 1, unit: 'bucată', category: 'Vegetables'),
          Ingredient(name: 'ulei de măsline', quantity: 3, unit: 'linguri', category: 'Condiments & Oils'),
          Ingredient(name: 'sare', quantity: 1, unit: 'vârf de cuțit', category: 'Pantry'),
        ];
        steps = [
          StepItem(index: 1, text: 'Spală și taie salata în bucăți mici', durationSec: 120),
          StepItem(index: 2, text: 'Taie roșiile cherry în jumătăți', durationSec: 90),
          StepItem(index: 3, text: 'Tăie castraveții în felii subțiri', durationSec: 60),
          StepItem(index: 4, text: 'Curăță avocado-ul și taie-l în cuburi', durationSec: 120),
          StepItem(index: 5, text: 'Amestecă toate ingredientele într-un bol mare', durationSec: 60),
          StepItem(index: 6, text: 'Condimentează cu ulei de măsline și sare', durationSec: 30),
        ];
        tags = ['salată', 'sănătos', 'vegetarian', 'rapid', 'instagram'];
      } else if (isYouTube) {
        title = 'Rețetă YouTube - Paste Carbonara';
        creatorHandle = 'italian_chef';
        ingredients = [
          Ingredient(name: 'paste', quantity: 400, unit: 'g', category: 'Pantry'),
          Ingredient(name: 'bacon', quantity: 200, unit: 'g', category: 'Meat & Seafood'),
          Ingredient(name: 'ouă', quantity: 4, unit: 'bucăți', category: 'Dairy & Eggs'),
          Ingredient(name: 'parmezan', quantity: 100, unit: 'g', category: 'Dairy & Eggs'),
          Ingredient(name: 'piper negru', quantity: 1, unit: 'vârf de cuțit', category: 'Pantry'),
          Ingredient(name: 'sare', quantity: 1, unit: 'lingură', category: 'Pantry'),
        ];
        steps = [
          StepItem(index: 1, text: 'Fierbe pastele conform instrucțiunilor de pe pachet', durationSec: 600),
          StepItem(index: 2, text: 'Tăie bacon-ul în bucăți mici și prăjește-l', durationSec: 300),
          StepItem(index: 3, text: 'Bate ouăle cu parmezanul și piperul', durationSec: 120),
          StepItem(index: 4, text: 'Amestecă pastele cu bacon-ul prăjit', durationSec: 60),
          StepItem(index: 5, text: 'Adaugă amestecul de ouă și amestecă rapid', durationSec: 30),
          StepItem(index: 6, text: 'Servește imediat cu parmezan suplimentar', durationSec: 30),
        ];
        tags = ['paste', 'italian', 'carbonara', 'rapid', 'youtube'];
      } else {
        // Generic recipe for other links
        title = 'Rețetă Delicioasă';
        creatorHandle = 'chef_online';
        ingredients = [
          Ingredient(name: 'ingredient principal', quantity: 500, unit: 'g', category: 'Other'),
          Ingredient(name: 'condimente', quantity: 1, unit: 'lingură', category: 'Pantry'),
          Ingredient(name: 'sare', quantity: 1, unit: 'vârf de cuțit', category: 'Pantry'),
        ];
        steps = [
          StepItem(index: 1, text: 'Pregătește ingredientele principale', durationSec: 300),
          StepItem(index: 2, text: 'Condimentează după gust', durationSec: 60),
          StepItem(index: 3, text: 'Gătește conform instrucțiunilor', durationSec: 600),
        ];
        tags = ['rețetă', 'gătit', 'delicios'];
      }
      
      return Recipe.createFromSource(
        sourceLink: link,
        title: title,
        creatorHandle: creatorHandle,
        lang: 'ro',
        text: RecipeText(
          original: 'Rețetă extrasă din $link',
          ro: 'Rețetă extrasă din $link',
        ),
        media: RecipeMedia(
          coverImageUrl: 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}',
          stepPhotos: [
            'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch + 1}',
            'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch + 2}',
          ],
        ),
        ingredients: ingredients,
        steps: steps,
        tags: tags,
      );
    } catch (e) {
      throw Exception('Eroare la extragerea rețetei: $e');
    }
  }

  void _saveRecipe(BuildContext context, WidgetRef ref) {
    final currentRecipe = ref.read(currentRecipeProvider);
    if (currentRecipe != null) {
      // TODO: Implement save recipe functionality
      // This would save the recipe to the user's saved recipes
      ref.read(showConfettiProvider.notifier).state = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rețeta "${currentRecipe.title}" a fost salvată!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _addToShoppingList(BuildContext context, WidgetRef ref) {
    final currentRecipe = ref.read(currentRecipeProvider);
    if (currentRecipe != null) {
      // TODO: Implement add to shopping list functionality
      // This would add the recipe's ingredients to the shopping list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingredientele au fost adăugate la lista de cumpărături'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _openCookingMode(BuildContext context, WidgetRef ref) {
    final currentRecipe = ref.read(currentRecipeProvider);
    if (currentRecipe != null) {
      context.go('/cooking/${currentRecipe.id}');
    }
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
            onTap: () => context.go('/recipe/${recipe.id}'),
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