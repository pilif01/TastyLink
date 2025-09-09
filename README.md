# TastyLink - AI-Powered Recipe Extraction App

TastyLink is a Flutter app that extracts recipes from video/audio content using AI transcription and on-device translation. It provides a comprehensive cooking experience with meal planning, shopping lists, and social features.

## Features

### Core Functionality
- **AI Recipe Extraction**: Transcribe video/audio content and extract structured recipe data
- **On-Device Translation**: Translate recipes to Romanian using local ML models
- **OCR Support**: Extract text from recipe images
- **Meal Planning**: Plan meals for the week with shopping list generation
- **Cooking Mode**: Step-by-step cooking guidance with timers
- **Social Features**: Share recipes, follow creators, and discover new content

### Monetization
- **Freemium Model**: Free users get 10 recipe extractions per month
- **Premium Subscription**: Unlimited processing, ad-free experience, advanced features
- **In-App Purchases**: Monthly and yearly subscription options
- **AdMob Integration**: Banner and interstitial ads for free users

### Technical Features
- **Firebase Backend**: Cloud Functions for transcription, Firestore for data
- **Offline Support**: Saved recipes and shopping lists work offline
- **Performance Optimized**: Cold start < 2.5s, 60fps navigation
- **Analytics & Crash Reporting**: Comprehensive tracking and error monitoring

## Architecture

### Backend (Firebase Functions)
- **Container**: Docker image with yt-dlp, ffmpeg, Python, faster-whisper
- **Function**: `transcribeFromLink` callable function
- **Processing Pipeline**:
  1. Download audio using yt-dlp
  2. Convert to 16kHz mono WAV with ffmpeg
  3. Transcribe with faster-whisper (small model)
  4. Extract recipe components using rule-based parsing
  5. Store canonical recipe in Firestore

### Client Services
- **TranslationService**: On-device Romanian translation
- **OcrService**: Image text extraction and recipe parsing
- **MonetizationService**: IAP, AdMob, usage tracking
- **NotificationService**: Local notifications and FCM
- **AnalyticsService**: Event tracking and crash reporting

### Data Models
- **Recipe**: Core recipe data with multilingual support
- **Ingredient**: Structured ingredient information
- **StepItem**: Cooking steps with timing
- **ShoppingItem**: Shopping list items
- **UserProfile**: User preferences and settings

## Setup

### Prerequisites
- Flutter 3.0+
- Firebase project
- Google Cloud Platform account
- AdMob account (for monetization)

### Firebase Setup
1. Create a Firebase project
2. Enable Authentication, Firestore, Functions, Analytics, Crashlytics
3. Configure Remote Config with default values
4. Deploy Firestore rules and indexes
5. Deploy Cloud Functions

### Local Development
```bash
# Clone the repository
git clone <repository-url>
cd tasty_link

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Functions Deployment
```bash
cd firebase/functions

# Install dependencies
npm install

# Deploy functions
firebase deploy --only functions
```

## Configuration

### Remote Config
Set these values in Firebase Remote Config:
- `free_recipe_limit`: 10 (free recipes per month)
- `premium_price_eur`: "4.99" (premium price)
- `enable_ads`: true (enable AdMob ads)

### AdMob Setup
1. Create AdMob account
2. Add app and create ad units
3. Update ad unit IDs in `MonetizationService`
4. Test with test ad units in debug mode

### IAP Setup
1. Configure products in Google Play Console / App Store Connect
2. Add product IDs: `premium_monthly`, `premium_yearly`
3. Test purchases in sandbox environment

## Testing

### Unit Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/recipe_extractor_test.dart
```

### Golden Tests
```bash
# Generate golden files
flutter test --update-goldens

# Run golden tests
flutter test test/widgets/
```

### Integration Tests
```bash
# Run integration tests
flutter test integration_test/
```

## Performance

### Quality Gates
- **Cold Start**: < 2.5 seconds
- **Navigation**: 60fps tab switches
- **Processing**: 30-60 seconds average for typical links
- **Offline**: Saved recipes and shopping lists work offline

### Optimization
- Lazy loading of images and data
- Efficient Firestore queries with proper indexing
- Cached translations and OCR results
- Background processing for heavy operations

## Security

### Data Protection
- User authentication required for all operations
- Firestore security rules enforce data access
- No sensitive data in logs or analytics
- Secure API key management

### Content Safety
- User reporting system for inappropriate content
- Moderation tools for admin users
- Rate limiting on API calls
- Input validation and sanitization

## Deployment

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build iOS app
flutter build ios --release
```

### Firebase Functions
```bash
# Deploy to production
firebase deploy --only functions

# Deploy with specific region
firebase deploy --only functions --project production
```

## Monitoring

### Analytics
Track key events:
- `share_intent_opened`: User opened share intent
- `process_started`: Recipe processing started
- `process_success`: Recipe processing completed
- `process_failed_reason`: Processing failed with reason
- `recipe_saved`: Recipe saved to user's collection
- `shopping_add`: Item added to shopping list
- `planner_add`: Meal added to planner
- `cooking_mode_start`: Cooking mode started
- `badge_unlocked`: User unlocked achievement
- `iap_purchase`: In-app purchase completed

### Crash Reporting
- Automatic crash collection with Firebase Crashlytics
- Custom error logging for non-fatal issues
- User context and device information
- Stack trace analysis and grouping

## Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Run tests and linting
5. Submit pull request

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add documentation for public APIs
- Write tests for new functionality

### Testing Requirements
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows
- Golden tests for visual regression

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review existing issues and discussions

## Roadmap

### Phase 1 (Current)
- ✅ Core recipe extraction
- ✅ Basic translation support
- ✅ Monetization system
- ✅ Analytics and crash reporting

### Phase 2 (Next)
- 🔄 Advanced OCR with better accuracy
- 🔄 Social features and user profiles
- 🔄 Meal planning improvements
- 🔄 Cooking mode enhancements

### Phase 3 (Future)
- 📋 AI-powered recipe recommendations
- 📋 Voice commands for cooking mode
- 📋 Integration with smart kitchen devices
- 📋 Advanced analytics and insights