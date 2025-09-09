import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ro')
  ];

  /// The title of the application
  ///
  /// In ro, this message translates to:
  /// **'TastyLink'**
  String get appTitle;

  /// Home tab label
  ///
  /// In ro, this message translates to:
  /// **'Acasă'**
  String get home;

  /// Saved recipes tab label
  ///
  /// In ro, this message translates to:
  /// **'Salvate'**
  String get saved;

  /// Shopping list tab label
  ///
  /// In ro, this message translates to:
  /// **'Cumpărături'**
  String get shopping;

  /// Meal planner tab label
  ///
  /// In ro, this message translates to:
  /// **'Planificator'**
  String get planner;

  /// Settings tab label
  ///
  /// In ro, this message translates to:
  /// **'Setări'**
  String get settings;

  /// Button text to add a recipe from a link
  ///
  /// In ro, this message translates to:
  /// **'Adaugă link rețetă'**
  String get addRecipeLink;

  /// Placeholder text for link input field
  ///
  /// In ro, this message translates to:
  /// **'Lipește link-ul aici'**
  String get pasteLink;

  /// Button text to extract recipe from link
  ///
  /// In ro, this message translates to:
  /// **'Extrage rețeta'**
  String get extractRecipe;

  /// Recipe title field label
  ///
  /// In ro, this message translates to:
  /// **'Titlu rețetă'**
  String get recipeTitle;

  /// Ingredients section label
  ///
  /// In ro, this message translates to:
  /// **'Ingrediente'**
  String get ingredients;

  /// Instructions section label
  ///
  /// In ro, this message translates to:
  /// **'Instrucțiuni'**
  String get instructions;

  /// Cooking time field label
  ///
  /// In ro, this message translates to:
  /// **'Timp de gătit'**
  String get cookingTime;

  /// Servings field label
  ///
  /// In ro, this message translates to:
  /// **'Porții'**
  String get servings;

  /// Button text to save recipe
  ///
  /// In ro, this message translates to:
  /// **'Salvează rețeta'**
  String get saveRecipe;

  /// Button text to edit recipe
  ///
  /// In ro, this message translates to:
  /// **'Editează rețeta'**
  String get editRecipe;

  /// Button text to delete recipe
  ///
  /// In ro, this message translates to:
  /// **'Șterge rețeta'**
  String get deleteRecipe;

  /// Button text to share recipe
  ///
  /// In ro, this message translates to:
  /// **'Partajează rețeta'**
  String get shareRecipe;

  /// Button text to start cooking mode
  ///
  /// In ro, this message translates to:
  /// **'Începe să gătești'**
  String get startCooking;

  /// Cooking mode page title
  ///
  /// In ro, this message translates to:
  /// **'Mod gătit'**
  String get cookingMode;

  /// Button text to add ingredients to shopping list
  ///
  /// In ro, this message translates to:
  /// **'Adaugă la lista de cumpărături'**
  String get addToShoppingList;

  /// Shopping list page title
  ///
  /// In ro, this message translates to:
  /// **'Lista de cumpărături'**
  String get shoppingList;

  /// Clear shopping list button
  ///
  /// In ro, this message translates to:
  /// **'Golește lista'**
  String get clearList;

  /// Meal planner page title
  ///
  /// In ro, this message translates to:
  /// **'Planificator mese'**
  String get mealPlanner;

  /// Button text to add recipe to meal planner
  ///
  /// In ro, this message translates to:
  /// **'Adaugă la planificator'**
  String get addToPlanner;

  /// Button text to view original text
  ///
  /// In ro, this message translates to:
  /// **'Vezi original'**
  String get viewOriginal;

  /// Button text to view translated text
  ///
  /// In ro, this message translates to:
  /// **'Tradus în română'**
  String get translatedToRomanian;

  /// Language setting label
  ///
  /// In ro, this message translates to:
  /// **'Limbă'**
  String get language;

  /// Theme setting label
  ///
  /// In ro, this message translates to:
  /// **'Temă'**
  String get theme;

  /// Notifications setting label
  ///
  /// In ro, this message translates to:
  /// **'Notificări'**
  String get notifications;

  /// Privacy setting label
  ///
  /// In ro, this message translates to:
  /// **'Confidențialitate'**
  String get privacy;

  /// About setting label
  ///
  /// In ro, this message translates to:
  /// **'Despre'**
  String get about;

  /// Loading text
  ///
  /// In ro, this message translates to:
  /// **'Se încarcă...'**
  String get loading;

  /// Error text
  ///
  /// In ro, this message translates to:
  /// **'Eroare'**
  String get error;

  /// Retry button text
  ///
  /// In ro, this message translates to:
  /// **'Încearcă din nou'**
  String get retry;

  /// Cancel button text
  ///
  /// In ro, this message translates to:
  /// **'Anulează'**
  String get cancel;

  /// Done button text
  ///
  /// In ro, this message translates to:
  /// **'Gata'**
  String get done;

  /// OK button text
  ///
  /// In ro, this message translates to:
  /// **'OK'**
  String get ok;

  /// Hint text for link input field
  ///
  /// In ro, this message translates to:
  /// **'Lipește linkul aici'**
  String get addLinkHint;

  /// Button text to process recipe
  ///
  /// In ro, this message translates to:
  /// **'Procesează rețeta'**
  String get processRecipe;

  /// Text for empty state on home page
  ///
  /// In ro, this message translates to:
  /// **'Adaugă un link de pe TikTok, Reels sau Shorts'**
  String get addLinkText;

  /// Original language toggle
  ///
  /// In ro, this message translates to:
  /// **'Original'**
  String get original;

  /// Romanian language toggle
  ///
  /// In ro, this message translates to:
  /// **'Română'**
  String get romanian;

  /// Recipe creator attribution
  ///
  /// In ro, this message translates to:
  /// **'Rețetă de la @{handle}'**
  String recipeBy(String handle);

  /// Button to watch video
  ///
  /// In ro, this message translates to:
  /// **'Vezi video'**
  String get watchVideo;

  /// Save button
  ///
  /// In ro, this message translates to:
  /// **'Salvează'**
  String get save;

  /// Button to open cooking mode
  ///
  /// In ro, this message translates to:
  /// **'Deschide în Mod Gătit'**
  String get openCookingMode;

  /// Steps section title
  ///
  /// In ro, this message translates to:
  /// **'Pași'**
  String get steps;

  /// Search recipes hint
  ///
  /// In ro, this message translates to:
  /// **'Caută rețete'**
  String get searchRecipes;

  /// Empty state for saved recipes
  ///
  /// In ro, this message translates to:
  /// **'Încă nu ai salvat rețete.'**
  String get noSavedRecipes;

  /// Edit button
  ///
  /// In ro, this message translates to:
  /// **'Editează'**
  String get edit;

  /// Delete button
  ///
  /// In ro, this message translates to:
  /// **'Șterge'**
  String get delete;

  /// Like button
  ///
  /// In ro, this message translates to:
  /// **'Like'**
  String get like;

  /// Share button
  ///
  /// In ro, this message translates to:
  /// **'Partajează'**
  String get share;

  /// Consolidate duplicates button
  ///
  /// In ro, this message translates to:
  /// **'Consolidează duplicatele'**
  String get consolidateDuplicates;

  /// Empty shopping list message
  ///
  /// In ro, this message translates to:
  /// **'Lista de cumpărături este goală'**
  String get noShoppingItems;

  /// Saved recipes tab in planner
  ///
  /// In ro, this message translates to:
  /// **'Rețete salvate'**
  String get savedRecipes;

  /// New link tab in planner
  ///
  /// In ro, this message translates to:
  /// **'Link nou'**
  String get newLink;

  /// Camera tab in planner
  ///
  /// In ro, this message translates to:
  /// **'Cameră'**
  String get camera;

  /// Generate weekly shopping list button
  ///
  /// In ro, this message translates to:
  /// **'Generează lista pentru săptămână'**
  String get generateWeeklyList;

  /// Public profile button
  ///
  /// In ro, this message translates to:
  /// **'Profil public'**
  String get publicProfile;

  /// Edit profile button
  ///
  /// In ro, this message translates to:
  /// **'Editează profil'**
  String get editProfile;

  /// Dark mode toggle
  ///
  /// In ro, this message translates to:
  /// **'Mod întunecat'**
  String get darkMode;

  /// Planner reminders setting
  ///
  /// In ro, this message translates to:
  /// **'Memento planificare'**
  String get plannerReminders;

  /// Cooking timers setting
  ///
  /// In ro, this message translates to:
  /// **'Cronometre gătit'**
  String get cookingTimers;

  /// Open social feed button
  ///
  /// In ro, this message translates to:
  /// **'Deschide Feed'**
  String get openFeed;

  /// App info section
  ///
  /// In ro, this message translates to:
  /// **'Informații aplicație'**
  String get appInfo;

  /// App version
  ///
  /// In ro, this message translates to:
  /// **'Versiune'**
  String get version;

  /// Mark recipe as cooked button
  ///
  /// In ro, this message translates to:
  /// **'Marchează ca gătită'**
  String get markAsCooked;

  /// Step counter in cooking mode
  ///
  /// In ro, this message translates to:
  /// **'Pasul {current} din {total}'**
  String stepOf(int current, int total);

  /// Add photo button
  ///
  /// In ro, this message translates to:
  /// **'Adaugă foto'**
  String get addPhoto;

  /// Extract text from photo option
  ///
  /// In ro, this message translates to:
  /// **'Extrage text din poză'**
  String get extractText;

  /// Recipe saved success message
  ///
  /// In ro, this message translates to:
  /// **'Rețeta a fost salvată!'**
  String get recipeSaved;

  /// Added to shopping list message
  ///
  /// In ro, this message translates to:
  /// **'Adăugat în lista de cumpărături'**
  String get addedToShoppingList;

  /// Recipe processed success message
  ///
  /// In ro, this message translates to:
  /// **'Rețeta a fost procesată!'**
  String get recipeProcessed;

  /// Breakfast meal type
  ///
  /// In ro, this message translates to:
  /// **'Mic dejun'**
  String get breakfast;

  /// Lunch meal type
  ///
  /// In ro, this message translates to:
  /// **'Pranz'**
  String get lunch;

  /// Dinner meal type
  ///
  /// In ro, this message translates to:
  /// **'Cina'**
  String get dinner;

  /// Snack meal type
  ///
  /// In ro, this message translates to:
  /// **'Gustare'**
  String get snack;

  /// Confirm button
  ///
  /// In ro, this message translates to:
  /// **'Confirmă'**
  String get confirm;

  /// Yes button
  ///
  /// In ro, this message translates to:
  /// **'Da'**
  String get yes;

  /// No button
  ///
  /// In ro, this message translates to:
  /// **'Nu'**
  String get no;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
