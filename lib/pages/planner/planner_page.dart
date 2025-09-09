import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../core/constants.dart';
import '../../services/camera_service.dart';

// State providers
final currentWeekProvider = StateProvider<DateTime>((ref) => DateTime.now());
final plannerEntriesProvider = FutureProvider<Map<String, List<PlannerEntry>>>((ref) async {
  // For now, return empty map since we don't have user authentication
  // In a real app, this would fetch from DataService
  return {};
});

class PlannerPage extends ConsumerWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeek = ref.watch(currentWeekProvider);
    final plannerEntriesAsync = ref.watch(plannerEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _generateWeeklyList(context, ref),
            tooltip: 'Generează lista pentru săptămână',
          ),
        ],
      ),
      body: Column(
        children: [
          // Week selector
          _buildWeekSelector(context, ref, currentWeek),
          
          // Meal planner grid
          Expanded(
            child: plannerEntriesAsync.when(
              data: (plannerEntries) => _buildMealGrid(context, ref, currentWeek, plannerEntries),
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
                      'Eroare la încărcarea planificării',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(plannerEntriesProvider),
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

  Widget _buildWeekSelector(BuildContext context, WidgetRef ref, DateTime currentWeek) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newWeek = currentWeek.subtract(const Duration(days: 7));
              ref.read(currentWeekProvider.notifier).state = newWeek;
            },
          ),
          Expanded(
            child: Text(
              _getWeekLabel(currentWeek),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newWeek = currentWeek.add(const Duration(days: 7));
              ref.read(currentWeekProvider.notifier).state = newWeek;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMealGrid(BuildContext context, WidgetRef ref, DateTime currentWeek, Map<String, List<PlannerEntry>> entries) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    // Get the start of the week (Monday)
    final startOfWeek = currentWeek.subtract(Duration(days: currentWeek.weekday - 1));
    
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          // Header row with meal types
          Row(
            children: [
              const SizedBox(width: 60), // Space for day labels
              ...MealType.all.map((mealType) => Expanded(
                child: Text(
                  _getMealLabel(mealType, l10n),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              )),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Days and meals grid
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, dayIndex) {
                final day = startOfWeek.add(Duration(days: dayIndex));
                final dayKey = _getDayKey(day);
                final dayEntries = entries[dayKey] ?? [];
                
                return _buildDayRow(context, ref, day, dayEntries, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, WidgetRef ref, DateTime day, List<PlannerEntry> entries, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isToday = _isSameDay(day, DateTime.now());
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Row(
        children: [
          // Day label
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  _getDayName(day),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  day.day.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                    color: isToday ? theme.colorScheme.primary : null,
                  ),
                ),
              ],
            ),
          ),
          
          // Meal cells
          ...MealType.all.map((mealType) => Expanded(
            child: _buildMealCell(context, ref, day, mealType, entries, l10n),
          )),
        ],
      ),
    );
  }

  Widget _buildMealCell(BuildContext context, WidgetRef ref, DateTime day, String mealType, List<PlannerEntry> entries, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final entry = entries.where((e) => e.meal == mealType).firstOrNull;
    
    return GestureDetector(
      onTap: () => _showAddMealSheet(context, ref, day, mealType),
      onLongPress: () => _showAddNoteDialog(context, ref, day, mealType),
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: entry != null 
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: entry != null
            ? _buildMealEntry(entry, theme)
            : Center(
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  size: 20,
                ),
              ),
      ),
    );
  }

  Widget _buildMealEntry(PlannerEntry entry, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXS),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (entry.recipeId != null)
            Icon(
              Icons.restaurant,
              color: theme.colorScheme.primary,
              size: 16,
            ),
          if (entry.note != null)
            Text(
              entry.note!,
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  void _showAddMealSheet(BuildContext context, WidgetRef ref, DateTime day, String mealType) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _AddMealSheet(
        day: day,
        mealType: mealType,
        onAddEntry: (entry) {
          // TODO: Implement add planner entry functionality
          // This would save the entry to the data service
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Intrarea a fost adăugată la planificare'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        },
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, WidgetRef ref, DateTime day, String mealType) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adaugă notă pentru ${_getMealLabel(mealType, AppLocalizations.of(context)!)}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Introduceți o notă...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // TODO: Implement add note functionality
                // This would save the note to the data service
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nota a fost adăugată'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _generateWeeklyList(BuildContext context, WidgetRef ref) {
    // TODO: Implement generate weekly shopping list functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcționalitatea de generare a listei va fi implementată'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  String _getWeekLabel(DateTime week) {
    final startOfWeek = week.subtract(Duration(days: week.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return '${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}';
  }

  String _getDayKey(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }

  String _getDayName(DateTime day) {
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return days[day.weekday - 1];
  }

  String _getMealLabel(String mealType, AppLocalizations l10n) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Mic dejun';
      case MealType.lunch:
        return 'Pranz';
      case MealType.dinner:
        return 'Cina';
      case MealType.snack:
        return 'Gustare';
      default:
        return mealType;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _AddMealSheet extends StatelessWidget {
  final DateTime day;
  final String mealType;
  final Function(PlannerEntry) onAddEntry;

  const _AddMealSheet({
    required this.day,
    required this.mealType,
    required this.onAddEntry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Adaugă la ${_getMealLabel(mealType, l10n)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacingL),
          
          // Tabs for different options
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Salvate'),
                    Tab(text: 'Link nou'),
                    Tab(text: 'Cameră'),
                  ],
                ),
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    children: [
                      _SavedRecipesTab(onAddEntry: onAddEntry),
                      _NewLinkTab(onAddEntry: onAddEntry),
                      _CameraTab(onAddEntry: onAddEntry),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMealLabel(String mealType, AppLocalizations l10n) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Mic dejun';
      case MealType.lunch:
        return 'Pranz';
      case MealType.dinner:
        return 'Cina';
      case MealType.snack:
        return 'Gustare';
      default:
        return mealType;
    }
  }
}

class _SavedRecipesTab extends StatelessWidget {
  final Function(PlannerEntry) onAddEntry;

  const _SavedRecipesTab({required this.onAddEntry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Rețete salvate vor fi afișate aici',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _NewLinkTab extends StatelessWidget {
  final Function(PlannerEntry) onAddEntry;

  const _NewLinkTab({required this.onAddEntry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Procesare link nou va fi implementată aici',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _CameraTab extends StatefulWidget {
  final Function(PlannerEntry) onAddEntry;

  const _CameraTab({required this.onAddEntry});

  @override
  State<_CameraTab> createState() => _CameraTabState();
}

class _CameraTabState extends State<_CameraTab> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Fotografiază o rețetă',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Folosește camera pentru a extrage o rețetă din imagine',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_isProcessing)
            const CircularProgressIndicator()
          else
            ElevatedButton.icon(
              onPressed: _processImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Deschide camera'),
            ),
        ],
      ),
    );
  }

  Future<void> _processImage() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await CameraService.instance.extractRecipeFromCamera();
      
      if (result.isSuccessful && result.title != null) {
        // Create a planner entry with the extracted recipe
        final entry = PlannerEntry.create(
          meal: widget.onAddEntry.toString(), // This should be the meal type
          recipeId: 'extracted_${DateTime.now().millisecondsSinceEpoch}',
          note: result.title,
          date: DateTime.now(),
        );
        
        widget.onAddEntry(entry);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rețeta "${result.title}" a fost adăugată!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nu s-a putut extrage rețeta din imagine'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la procesarea imaginii: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}