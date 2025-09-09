import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/home/home_page.dart';
import '../pages/saved/saved_recipes_page.dart';
import '../pages/shopping/shopping_list_page.dart';
import '../pages/planner/planner_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/recipe/recipe_detail_page.dart';
import '../pages/recipe/edit_recipe_page.dart';
import '../pages/cooking/cooking_mode_page.dart';
import '../pages/social/social_feed_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/onboarding/onboarding_page.dart';
import '../widgets/main_navigation.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      
      // Main app with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/saved',
            name: 'saved',
            builder: (context, state) => const SavedRecipesPage(),
          ),
          GoRoute(
            path: '/shopping',
            name: 'shopping',
            builder: (context, state) => const ShoppingListPage(),
          ),
          GoRoute(
            path: '/planner',
            name: 'planner',
            builder: (context, state) => const PlannerPage(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      
      // Secondary routes
      GoRoute(
        path: '/recipe/:id',
        name: 'recipe-detail',
        builder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          return RecipeDetailPage(recipeId: recipeId);
        },
      ),
      GoRoute(
        path: '/recipe/:id/edit',
        name: 'edit-recipe',
        builder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          return EditRecipePage(recipeId: recipeId);
        },
      ),
      GoRoute(
        path: '/cooking/:id',
        name: 'cooking-mode',
        builder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          return CookingModePage(recipeId: recipeId);
        },
      ),
      GoRoute(
        path: '/social',
        name: 'social-feed',
        builder: (context, state) => const SocialFeedPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});

