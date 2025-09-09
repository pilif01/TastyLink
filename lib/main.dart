import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Open Hive boxes
  await Hive.openBox(Constants.userBox);
  await Hive.openBox(Constants.recipesBox);
  await Hive.openBox(Constants.settingsBox);
  
  runApp(
    const ProviderScope(
      child: TastyLinkApp(),
    ),
  );
}
