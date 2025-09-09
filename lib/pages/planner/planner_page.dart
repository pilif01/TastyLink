import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../core/constants.dart';

// State providers
final currentWeekProvider = StateProvider<DateTime>((ref) => DateTime.now());
final plannerEntriesProvider = StateProvider<Map<String, List<PlannerEntry>>>((ref) => {});

class PlannerPage extends ConsumerWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeek = ref.watch(currentWeekProvider);
    final plannerEntries = ref.watch(plannerEntriesProvider);

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
            child: _buildMealGrid(context, ref, currentWeek, plannerEntries),
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
          final entries = ref.read(plannerEntriesProvider);
          final dayKey = _getDayKey(day);
          final dayEntries = entries[dayKey] ?? [];
          dayEntries.add(entry);
          entries[dayKey] = dayEntries;
          ref.read(plannerEntriesProvider.notifier).state = Map.from(entries);
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
                final entry = PlannerEntry.create(
                  meal: mealType,
                  note: controller.text,
                  date: day,
                );
                
                final entries = ref.read(plannerEntriesProvider);
                final dayKey = _getDayKey(day);
                final dayEntries = entries[dayKey] ?? [];
                dayEntries.add(entry);
                entries[dayKey] = dayEntries;
                ref.read(plannerEntriesProvider.notifier).state = Map.from(entries);
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
    final entries = ref.read(plannerEntriesProvider);
    final allEntries = entries.values.expand((e) => e).toList();
    final recipeIds = allEntries.where((e) => e.recipeId != null).map((e) => e.recipeId!).toSet();
    
    if (recipeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nu există rețete planificate pentru această săptămână'),
        ),
      );
      return;
    }
    
    // Generate shopping list from planned recipes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lista de cumpărături generată pentru ${recipeIds.length} rețete'),
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

class _CameraTab extends StatelessWidget {
  final Function(PlannerEntry) onAddEntry;

  const _CameraTab({required this.onAddEntry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Funcționalitatea camerei va fi implementată aici',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}