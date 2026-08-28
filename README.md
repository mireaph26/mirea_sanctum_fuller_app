# Mirea Sanctum - Flutter App

## Setup Instructions

### 1. Install Flutter
Download Flutter SDK from: https://flutter.dev/docs/get-started/install

### 2. Run these commands
```bash
cd flutter_app
flutter pub get
flutter run
```

### 3. For Web
```bash
flutter run -d chrome
```

### 4. For Android
```bash
flutter run -d android
```

### 5. For iOS
```bash
flutter run -d ios
```

### 6. Build APK
```bash
flutter build apk
```

### 7. Build Web
```bash
flutter build web
```

## Project Structure
```
flutter_app/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── models.dart
│   ├── services/
│   │   └── storage_service.dart
│   ├── screens/
│   │   ├── landing_screen.dart
│   │   ├── main_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── finance_screen.dart
│   │   ├── home_screen.dart
│   │   ├── family_screen.dart
│   │   └── lifestyle_screen.dart
│   ├── widgets/
│   └── theme/
│       └── app_theme.dart
└── assets/
    └── logo.png
```

## Features
- Landing page with login/register
- Dashboard with sub-pages
- Finance & Budgeting with sub-pages
- Home & Routine with sub-pages
- Family & Health with sub-pages
- Lifestyle & Growth with sub-pages
- Local storage persistence
- Family member management
- Chore tracking
- Bill tracking
- Meal planning
- Calendar
- And more...
