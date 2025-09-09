import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'core/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open Hive boxes
  await Hive.openBox(Constants.userBox);
  await Hive.openBox(Constants.recipesBox);
  await Hive.openBox(Constants.settingsBox);
  
  runApp(const ProviderScope(child: TastyLinkApp()));
}

class TastyLinkApp extends ConsumerWidget {
  const TastyLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'TastyLink',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
