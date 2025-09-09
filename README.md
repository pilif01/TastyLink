# TastyLink

A Flutter app for extracting and managing recipes from links with on-device translation to Romanian.

## Features

- 🔗 Extract recipes from any URL
- 🍽️ Save and organize recipes
- 🛒 Create shopping lists from ingredients
- 📅 Meal planning
- 🌍 On-device translation to Romanian
- 📱 Cross-platform (Android, iOS, Web, Desktop)
- 🔒 Privacy-focused with local processing

## Tech Stack

- **Frontend**: Flutter with Riverpod state management
- **Backend**: Firebase (Auth, Firestore, Storage, Functions)
- **Translation**: Google ML Kit (on-device)
- **OCR**: Tesseract
- **Heavy Processing**: Firebase Functions with yt-dlp, ffmpeg, faster-whisper

## Setup Instructions

### Prerequisites

1. Install Flutter SDK (>=3.10.0)
2. Install Firebase CLI
3. Create a Firebase project
4. Enable the following Firebase services:
   - Authentication
   - Firestore Database
   - Storage
   - Functions
   - Analytics
   - Crashlytics
   - Remote Config

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd tasty_link
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Generate localization files:
```bash
flutter gen-l10n
```

4. Configure Firebase:
```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in the project
firebase init

# Select the following services:
# - Firestore
# - Functions
# - Storage
# - Hosting (optional)
```

5. Update Firebase configuration:
   - Copy your Firebase config to `firebase/firebase_options.dart`
   - Update the API keys and project IDs

6. Deploy Firebase Functions:
```bash
cd firebase/functions
npm install
npm run build
firebase deploy --only functions
```

### Platform-specific Setup

#### Android

1. Add your `google-services.json` to `android/app/`
2. Update `android/app/build.gradle` with your Firebase project configuration
3. The app is configured to handle shared text content

#### iOS

1. Add your `GoogleService-Info.plist` to `ios/Runner/`
2. Update the bundle identifier in `ios/Runner.xcodeproj`
3. Configure App Groups for share extension (if needed)

### Running the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios
flutter run -d web
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

## Project Structure

```
lib/
├── app.dart                 # Main app widget
├── main.dart               # App entry point
├── core/
│   └── constants.dart      # App constants
├── l10n/                   # Localization files
├── models/                 # Data models
├── pages/                  # UI pages
│   ├── home/
│   ├── saved/
│   ├── shopping/
│   ├── planner/
│   ├── settings/
│   ├── recipe/
│   ├── cooking/
│   ├── social/
│   ├── profile/
│   └── onboarding/
├── providers/              # Riverpod state providers
├── router/
│   └── app_router.dart     # Navigation configuration
├── services/               # Business logic services
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── translation_service.dart
│   ├── ocr_service.dart
│   └── share_handler.dart
├── theme/
│   └── app_theme.dart      # App theming
└── widgets/                # Reusable UI components

assets/
├── brand/                  # Logo and branding assets
├── illustrations/          # App illustrations
└── tessdata/              # OCR language data files

firebase/
├── functions/              # Firebase Functions
└── firebase_options.dart   # Firebase configuration
```

## Key Features Implementation

### Recipe Extraction
- Uses Firebase Functions with yt-dlp for video processing
- ffmpeg for audio extraction
- faster-whisper for speech-to-text
- Web scraping for text-based recipes

### Translation
- Google ML Kit Language Identification
- On-device translation to Romanian
- Automatic model downloading and caching

### OCR
- Tesseract integration for image text extraction
- Support for English and Romanian
- Recipe-specific text parsing

### Sharing
- Android: Share Target for text/plain
- iOS: Share Extension with App Groups
- Cross-platform recipe sharing

## Development

### Adding New Features

1. Create models in `lib/models/`
2. Add services in `lib/services/`
3. Create providers in `lib/providers/`
4. Build UI in `lib/pages/`
5. Add routing in `lib/router/app_router.dart`

### Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

### Building for Production

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@tastylink.app or create an issue in the repository.
