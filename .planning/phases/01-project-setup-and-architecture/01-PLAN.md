---
plan: "01"
phase: "01-project-setup-and-architecture"
title: "Flutter Project Creation & Dependency Setup"
wave: 1
depends_on: []
files_modified:
  - pubspec.yaml
  - lib/main.dart
  - lib/app.dart
  - android/app/build.gradle
  - android/build.gradle
  - analysis_options.yaml
  - .gitignore
autonomous: true
requirements:
  - TECH-01
  - TECH-03
---

## Goal

Create the Flutter project, configure `pubspec.yaml` with all production dependencies, set up the Android minimum SDK, establish the 3-layer folder structure skeleton, and create `main.dart` + `app.dart` entry points.

## Context

- App name: **Shree Giriraj Engineering**
- Package name: `com.shreegiriraj.management`
- Flutter minimum SDK: `3.0.0`
- Android `minSdkVersion`: `21` (required for geolocator + Firebase)
- Android `compileSdkVersion`: `34`
- State management: **Riverpod** (flutter_riverpod + riverpod_annotation)
- Router: **go_router**
- Firebase packages: firebase_core, firebase_auth, cloud_firestore, google_sign_in

## Tasks

<task id="1.1">
<title>Create Flutter project with correct package name</title>
<read_first>
  - Check if `pubspec.yaml` already exists (it may if project was pre-initialized)
  - If project already initialized: skip `flutter create`, go directly to task 1.2
</read_first>
<action>
Run from `D:\project\Management-app`:

```
flutter create --org com.shreegiriraj --project-name shree_giriraj_management --platforms android .
```

If flutter create fails because directory is non-empty, instead manually verify:
- `pubspec.yaml` exists with `name: shree_giriraj_management`
- `android/app/src/main/AndroidManifest.xml` exists
- `lib/main.dart` exists

If the project already exists (has pubspec.yaml), skip this task entirely and proceed to 1.2.
</action>
<acceptance_criteria>
- `pubspec.yaml` contains `name: shree_giriraj_management`
- `android/app/build.gradle` exists
- `lib/main.dart` exists
- `flutter doctor` returns no critical errors
</acceptance_criteria>
</task>

<task id="1.2">
<title>Configure pubspec.yaml with all production dependencies</title>
<read_first>
  - `pubspec.yaml` — read current content before replacing
</read_first>
<action>
Replace the entire `pubspec.yaml` content with:

```yaml
name: shree_giriraj_management
description: Internal transaction management app for Shree Giriraj Engineering
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.1.0
  firebase_auth: ^5.1.0
  cloud_firestore: ^5.1.0
  google_sign_in: ^6.2.1

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.2.0

  # Location
  geolocator: ^12.0.0
  permission_handler: ^11.3.1

  # UI & Utilities
  intl: ^0.19.0
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.10+1

  # Icons
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.3
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.13

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

Then run: `flutter pub get`
</action>
<acceptance_criteria>
- `pubspec.yaml` contains `firebase_core:`
- `pubspec.yaml` contains `flutter_riverpod:`
- `pubspec.yaml` contains `go_router:`
- `pubspec.yaml` contains `geolocator:`
- `pubspec.yaml` contains `intl:`
- `flutter pub get` completes with exit code 0
- No dependency conflicts in output
</acceptance_criteria>
</task>

<task id="1.3">
<title>Configure Android SDK versions and permissions</title>
<read_first>
  - `android/app/build.gradle` — current compileSdkVersion and minSdkVersion
  - `android/app/src/main/AndroidManifest.xml` — existing permissions
</read_first>
<action>
**In `android/app/build.gradle`**, ensure:
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.shreegiriraj.management"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }
}
```

**In `android/app/src/main/AndroidManifest.xml`**, add these permissions inside `<manifest>` tag (before `<application>`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```
</action>
<acceptance_criteria>
- `android/app/build.gradle` contains `minSdkVersion 21`
- `android/app/build.gradle` contains `compileSdkVersion 34`
- `android/app/build.gradle` contains `applicationId "com.shreegiriraj.management"`
- `android/app/src/main/AndroidManifest.xml` contains `ACCESS_FINE_LOCATION`
- `android/app/src/main/AndroidManifest.xml` contains `INTERNET`
</acceptance_criteria>
</task>

<task id="1.4">
<title>Create 3-layer folder structure skeleton</title>
<read_first>
  - `lib/` — check what currently exists
</read_first>
<action>
Create the following folder structure under `lib/`. Create a `.gitkeep` file in each empty directory to preserve the structure in git:

```
lib/
  core/
    theme/           → .gitkeep
    constants/       → .gitkeep
    utils/           → .gitkeep
    widgets/         → .gitkeep
    router/          → .gitkeep
    providers/       → .gitkeep
    services/        → .gitkeep
  features/
    auth/
      data/          → .gitkeep
      domain/
        models/      → .gitkeep
        repositories/ → .gitkeep
      presentation/
        screens/     → .gitkeep
        providers/   → .gitkeep
    transactions/
      data/          → .gitkeep
      domain/
        models/      → .gitkeep
        repositories/ → .gitkeep
      presentation/
        screens/     → .gitkeep
        providers/   → .gitkeep
    sites/
      data/          → .gitkeep
      domain/
        models/      → .gitkeep
        repositories/ → .gitkeep
      presentation/
        screens/     → .gitkeep
        providers/   → .gitkeep
    users/
      data/          → .gitkeep
      domain/
        models/      → .gitkeep
        repositories/ → .gitkeep
      presentation/
        screens/     → .gitkeep
        providers/   → .gitkeep
    partner/
      presentation/
        screens/     → .gitkeep
        shell/       → .gitkeep
    admin/
      presentation/
        screens/     → .gitkeep
        shell/       → .gitkeep
    super_admin/
      presentation/
        screens/     → .gitkeep
        shell/       → .gitkeep
assets/
  images/            → .gitkeep
  icons/             → .gitkeep
```
</action>
<acceptance_criteria>
- `lib/core/theme/` directory exists
- `lib/core/widgets/` directory exists
- `lib/features/auth/data/` directory exists
- `lib/features/auth/domain/models/` directory exists
- `lib/features/auth/presentation/screens/` directory exists
- `lib/features/transactions/` directory exists
- `lib/features/sites/` directory exists
- `lib/features/users/` directory exists
- `lib/features/partner/presentation/shell/` directory exists
- `lib/features/admin/presentation/shell/` directory exists
- `lib/features/super_admin/presentation/screens/` directory exists
- `assets/images/` directory exists
</acceptance_criteria>
</task>

<task id="1.5">
<title>Create main.dart and app.dart entry points</title>
<read_first>
  - `lib/main.dart` — existing content (likely default Flutter counter app)
</read_first>
<action>
**Create `lib/main.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization will be added in Phase 2
  runApp(
    const ProviderScope(
      child: ShreeGirirajApp(),
    ),
  );
}
```

**Create `lib/app.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

class ShreeGirirajApp extends ConsumerWidget {
  const ShreeGirirajApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Shree Giriraj Engineering',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text(
            'Shree Giriraj Engineering',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
```

Note: `AppTheme.lightTheme` will be created in Plan 02. If running before Plan 02 exists, create a temporary placeholder:
```dart
// Temporary: replace with AppTheme.lightTheme from Plan 02
theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D2137))),
```
</action>
<acceptance_criteria>
- `lib/main.dart` contains `ProviderScope`
- `lib/main.dart` contains `WidgetsFlutterBinding.ensureInitialized()`
- `lib/app.dart` contains `class ShreeGirirajApp extends ConsumerWidget`
- `lib/app.dart` contains `MaterialApp`
- `lib/app.dart` contains `debugShowCheckedModeBanner: false`
</acceptance_criteria>
</task>

<task id="1.6">
<title>Configure analysis_options.yaml and .gitignore</title>
<read_first>
  - `analysis_options.yaml` — existing linting config
  - `.gitignore` — existing Flutter gitignore
</read_first>
<action>
**Replace `analysis_options.yaml`:**
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  errors:
    missing_required_param: error
    missing_return: error
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_print
    - avoid_unnecessary_containers
    - cancel_subscriptions
    - prefer_const_constructors
    - prefer_final_fields
    - prefer_single_quotes
    - sort_child_properties_last
    - use_key_in_widget_constructors
```

**Add to `.gitignore`** (append to existing):
```
# Firebase
google-services.json
GoogleService-Info.plist
firebase_options.dart

# Build artifacts
*.jks
*.keystore
key.properties
```
</action>
<acceptance_criteria>
- `analysis_options.yaml` contains `implicit-casts: false`
- `analysis_options.yaml` contains `prefer_single_quotes`
- `.gitignore` contains `google-services.json`
- `.gitignore` contains `key.properties`
</acceptance_criteria>
</task>

## Verification

```bash
flutter pub get
flutter analyze lib/main.dart lib/app.dart
```

Expected: `flutter pub get` exits 0. `flutter analyze` reports 0 errors (warnings for missing AppTheme acceptable at this stage).

## must_haves

- [ ] `pubspec.yaml` has all required dependencies (firebase_core, flutter_riverpod, go_router, geolocator, intl)
- [ ] `flutter pub get` succeeds without conflicts
- [ ] Android minSdkVersion is 21
- [ ] 3-layer folder structure (core/, features/ with data/domain/presentation per feature) exists
- [ ] `lib/main.dart` bootstraps with `ProviderScope`
- [ ] `lib/app.dart` has `ShreeGirirajApp` as `ConsumerWidget`
