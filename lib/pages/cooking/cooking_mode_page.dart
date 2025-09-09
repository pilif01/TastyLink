import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';

// State providers
final recipeProvider = FutureProvider<Recipe?>((ref) async {
  final recipeId = ref.watch(recipeIdProvider);
  return await DataService.instance.getRecipe(recipeId);
});

final recipeIdProvider = StateProvider<String>((ref) => '');
final currentStepProvider = StateProvider<int>((ref) => 0);
final completedStepsProvider = StateProvider<Set<int>>((ref) => <int>{});
final timerProvider = StateProvider<Timer?>((ref) => null);
final remainingTimeProvider = StateProvider<int>((ref) => 0);
final isCookingProvider = StateProvider<bool>((ref) => false);

class CookingModePage extends ConsumerWidget {
  final String recipeId;
  
  const CookingModePage({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    // Set the recipe ID in the provider
    ref.read(recipeIdProvider.notifier).state = recipeId;
    
    final recipeAsync = ref.watch(recipeProvider);
    final currentStep = ref.watch(currentStepProvider);
    final completedSteps = ref.watch(completedStepsProvider);
    final remainingTime = ref.watch(remainingTimeProvider);
    final isCooking = ref.watch(isCookingProvider);
    
    return Scaffold(
      body: recipeAsync.when(
        data: (recipe) {
          if (recipe == null) {
            return _buildErrorState(context, 'Rețeta nu a fost găsită');
          }
          return _buildCookingContent(context, ref, recipe, currentStep, completedSteps, remainingTime, isCooking);
        },
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, 'Eroare la încărcarea rețetei: $error'),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eroare'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
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
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Înapoi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCookingContent(BuildContext context, WidgetRef ref, Recipe recipe, int currentStep, Set<int> completedSteps, int remainingTime, bool isCooking) {
    final totalSteps = recipe.steps.length;
    final isLastStep = currentStep >= totalSteps - 1;
    final isFirstStep = currentStep == 0;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context, ref),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => _showStepsOverview(context, ref, recipe),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(context, currentStep, totalSteps, completedSteps),
          
          // Timer (if current step has duration)
          if (remainingTime > 0) _buildTimer(context, ref, remainingTime, isCooking),
          
          // Current step content
          Expanded(
            child: currentStep < totalSteps
                ? _buildCurrentStep(context, ref, recipe.steps[currentStep], currentStep)
                : _buildCompletionScreen(context, ref, recipe),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(context, ref, isFirstStep, isLastStep, currentStep, totalSteps),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, int currentStep, int totalSteps, Set<int> completedSteps) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pasul ${currentStep + 1} din $totalSteps',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${completedSteps.length}/$totalSteps completate',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          LinearProgressIndicator(
            value: totalSteps > 0 ? (currentStep + 1) / totalSteps : 0,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(BuildContext context, WidgetRef ref, int remainingTime, bool isCooking) {
    final theme = Theme.of(context);
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => _toggleTimer(context, ref),
            icon: Icon(
              isCooking ? Icons.pause : Icons.play_arrow,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, WidgetRef ref, StepItem step, int stepIndex) {
    final theme = Theme.of(context);
    final completedSteps = ref.watch(completedStepsProvider);
    final isCompleted = completedSteps.contains(stepIndex);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: theme.colorScheme.onPrimary,
                            )
                          : Text(
                              step.index.toString(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pasul ${step.index}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (step.durationSec != null)
                          Text(
                            'Timp estimat: ${_formatDuration(step.durationSec!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Step description
          Text(
            step.text,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Step actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isCompleted 
                      ? () => _uncompleteStep(context, ref, stepIndex)
                      : () => _completeStep(context, ref, stepIndex, step),
                  icon: Icon(
                    isCompleted ? Icons.undo : Icons.check,
                  ),
                  label: Text(
                    isCompleted ? 'Marchează ca necompletat' : 'Marchează ca completat',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context, WidgetRef ref, Recipe recipe) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Felicitări!',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Ai terminat de gătit "${recipe.title}"!',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _restartCooking(context, ref),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Începe din nou'),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.home),
                  label: const Text('Acasă'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, WidgetRef ref, bool isFirstStep, bool isLastStep, int currentStep, int totalSteps) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _previousStep(context, ref),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
              ),
            ),
          if (!isFirstStep) const SizedBox(width: AppTheme.spacingM),
          if (!isLastStep)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _nextStep(context, ref),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Următor'),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleTimer(BuildContext context, WidgetRef ref) {
    final isCooking = ref.read(isCookingProvider);
    final timer = ref.read(timerProvider);
    
    if (isCooking) {
      // Pause timer
      timer?.cancel();
      ref.read(timerProvider.notifier).state = null;
      ref.read(isCookingProvider.notifier).state = false;
    } else {
      // Start timer
      final remainingTime = ref.read(remainingTimeProvider);
      if (remainingTime > 0) {
        final newTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          final currentTime = ref.read(remainingTimeProvider);
          if (currentTime <= 0) {
            timer.cancel();
            ref.read(timerProvider.notifier).state = null;
            ref.read(isCookingProvider.notifier).state = false;
            _showTimerCompleteDialog(context);
          } else {
            ref.read(remainingTimeProvider.notifier).state = currentTime - 1;
          }
        });
        ref.read(timerProvider.notifier).state = newTimer;
        ref.read(isCookingProvider.notifier).state = true;
      }
    }
  }

  void _completeStep(BuildContext context, WidgetRef ref, int stepIndex, StepItem step) {
    final completedSteps = ref.read(completedStepsProvider);
    final newCompletedSteps = Set<int>.from(completedSteps)..add(stepIndex);
    ref.read(completedStepsProvider.notifier).state = newCompletedSteps;
    
    // Start timer if step has duration
    if (step.durationSec != null) {
      ref.read(remainingTimeProvider.notifier).state = step.durationSec!;
    }
  }

  void _uncompleteStep(BuildContext context, WidgetRef ref, int stepIndex) {
    final completedSteps = ref.read(completedStepsProvider);
    final newCompletedSteps = Set<int>.from(completedSteps)..remove(stepIndex);
    ref.read(completedStepsProvider.notifier).state = newCompletedSteps;
  }

  void _nextStep(BuildContext context, WidgetRef ref) {
    final currentStep = ref.read(currentStepProvider);
    final totalSteps = ref.read(recipeProvider).value?.steps.length ?? 0;
    
    if (currentStep < totalSteps - 1) {
      ref.read(currentStepProvider.notifier).state = currentStep + 1;
      
      // Reset timer for new step
      ref.read(remainingTimeProvider.notifier).state = 0;
      ref.read(isCookingProvider.notifier).state = false;
      final timer = ref.read(timerProvider);
      timer?.cancel();
      ref.read(timerProvider.notifier).state = null;
    }
  }

  void _previousStep(BuildContext context, WidgetRef ref) {
    final currentStep = ref.read(currentStepProvider);
    
    if (currentStep > 0) {
      ref.read(currentStepProvider.notifier).state = currentStep - 1;
      
      // Reset timer for new step
      ref.read(remainingTimeProvider.notifier).state = 0;
      ref.read(isCookingProvider.notifier).state = false;
      final timer = ref.read(timerProvider);
      timer?.cancel();
      ref.read(timerProvider.notifier).state = null;
    }
  }

  void _restartCooking(BuildContext context, WidgetRef ref) {
    ref.read(currentStepProvider.notifier).state = 0;
    ref.read(completedStepsProvider.notifier).state = <int>{};
    ref.read(remainingTimeProvider.notifier).state = 0;
    ref.read(isCookingProvider.notifier).state = false;
    final timer = ref.read(timerProvider);
    timer?.cancel();
    ref.read(timerProvider.notifier).state = null;
  }

  void _showStepsOverview(BuildContext context, WidgetRef ref, Recipe recipe) {
    final currentStep = ref.read(currentStepProvider);
    final completedSteps = ref.read(completedStepsProvider);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pași de preparare',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            ...recipe.steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isCompleted = completedSteps.contains(index);
              final isCurrent = index == currentStep;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isCompleted 
                      ? Theme.of(context).colorScheme.primary
                      : isCurrent
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.surfaceVariant,
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : Text(
                          step.index.toString(),
                          style: TextStyle(
                            color: isCurrent
                                ? Theme.of(context).colorScheme.onSecondary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                title: Text(step.text),
                subtitle: step.durationSec != null
                    ? Text('Timp: ${_formatDuration(step.durationSec!)}')
                    : null,
                onTap: () {
                  ref.read(currentStepProvider.notifier).state = index;
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showTimerCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer completat!'),
        content: const Text('Timpul pentru acest pas s-a terminat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ieșire din modul de gătit'),
        content: const Text('Ești sigur că vrei să ieși din modul de gătit? Progresul va fi păstrat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anulează'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Ieșire'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}
