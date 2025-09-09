import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'services/data_service.dart';
import 'core/constants.dart';
import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open basic Hive boxes
  await Hive.openBox(Constants.recipesBox);
  await Hive.openBox(Constants.settingsBox);
  
  // Initialize Data Service
  await DataService.instance.initialize();
  
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
