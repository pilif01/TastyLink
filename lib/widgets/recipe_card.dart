import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback? onSave;
  final VoidCallback? onAddToShoppingList;
  final VoidCallback? onOpenCookingMode;
  final bool showLanguageToggle;
  final bool isProcessing;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onSave,
    this.onAddToShoppingList,
    this.onOpenCookingMode,
    this.showLanguageToggle = true,
    this.isProcessing = false,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard>
    with TickerProviderStateMixin {
  bool _showRomanian = false;
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: AppTheme.confettiDuration,
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onSave() {
    HapticFeedback.lightImpact();
    _confettiController.forward().then((_) {
      _confettiController.reset();
    });
    widget.onSave?.call();
  }

  void _onAddToShoppingList() {
    HapticFeedback.lightImpact();
    widget.onAddToShoppingList?.call();
  }

  void _onOpenCookingMode() {
    HapticFeedback.lightImpact();
    widget.onOpenCookingMode?.call();
  }

  void _onWatchVideo() async {
    if (widget.recipe.media.videoUrl != null) {
      final uri = Uri.parse(widget.recipe.media.videoUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            margin: const EdgeInsets.all(AppTheme.spacingM),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.recipe.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontFamily: 'Poppins',
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      if (widget.isProcessing)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingS),
                  
                  // Creator
                  Text(
                    'Rețetă de la @${widget.recipe.creatorHandle}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Language Toggle
                  if (widget.showLanguageToggle && widget.recipe.hasRomanianTranslation)
                    Row(
                      children: [
                        Expanded(
                          child: _LanguageToggle(
                            showRomanian: _showRomanian,
                            onChanged: (value) {
                              setState(() {
                                _showRomanian = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  
                  if (widget.showLanguageToggle && widget.recipe.hasRomanianTranslation)
                    const SizedBox(height: AppTheme.spacingL),
                  
                  // Action Buttons
                  Row(
                    children: [
                      if (widget.recipe.media.hasVideo)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _onWatchVideo,
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('Vezi video'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.successColor,
                              side: const BorderSide(color: AppTheme.successColor),
                            ),
                          ),
                        ),
                      if (widget.recipe.media.hasVideo)
                        const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _onSave,
                          icon: const Icon(Icons.bookmark_add, size: 18),
                          label: const Text('Salvează'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _onAddToShoppingList,
                          icon: const Icon(Icons.shopping_cart, size: 18),
                          label: const Text('Listă cumpărături'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Ingredients Section
                  _IngredientsSection(
                    ingredients: _showRomanian && widget.recipe.ingredientsRo.isNotEmpty
                        ? widget.recipe.ingredientsRo
                        : widget.recipe.ingredients,
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Steps Section
                  _StepsSection(
                    steps: _showRomanian && widget.recipe.stepsRo.isNotEmpty
                        ? widget.recipe.stepsRo
                        : widget.recipe.steps,
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Cooking Mode CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _onOpenCookingMode,
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('Deschide în Mod Gătit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final bool showRomanian;
  final ValueChanged<bool> onChanged;

  const _LanguageToggle({
    required this.showRomanian,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingS,
                  horizontal: AppTheme.spacingM,
                ),
                decoration: BoxDecoration(
                  color: !showRomanian ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Text(
                  'Original',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: !showRomanian 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingS,
                  horizontal: AppTheme.spacingM,
                ),
                decoration: BoxDecoration(
                  color: showRomanian ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Text(
                  'Română',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: showRomanian 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  final List<Ingredient> ingredients;

  const _IngredientsSection({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingrediente',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        ...ingredients.map((ingredient) => Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingXS),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  ingredient.toString(),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _StepsSection extends StatelessWidget {
  final List<StepItem> steps;

  const _StepsSection({required this.steps});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pași',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        ...steps.map((step) => Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    step.index.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Text(
                  step.text,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
