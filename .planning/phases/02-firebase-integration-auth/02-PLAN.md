---
description: "Firebase initialization, UI logic (Login, Splash, Unauthorized)"
dependencies: ["01-PLAN.md"]
gap_closure: false
---

# Phase 2: Firebase Integration & Auth - Plan 2 (UI Integration)

## 1. Firebase Initialization & App Updates
<task>
<read_first>
- lib/main.dart
</read_first>
<action>
In `lib/main.dart`:
- Change `main()` to `Future<void> main() async`.
- Call `WidgetsFlutterBinding.ensureInitialized()`.
- Add `await Firebase.initializeApp()`.
- Wrap the app with `ProviderScope`.
</action>
<acceptance_criteria>
- `lib/main.dart` contains `await Firebase.initializeApp()` after `WidgetsFlutterBinding.ensureInitialized()`
- Entire app is wrapped inside a Riverpod `ProviderScope`
</acceptance_criteria>
</task>

## 2. Build Splash Screen, Login Screen, and Unauthorized Screen
<task>
<read_first>
- lib/app.dart
- Designs/login_screen/code.html
- Designs/splash_screen/code.html
- lib/core/theme/app_colors.dart
- lib/features/auth/presentation/providers/auth_provider.dart
</read_first>
<action>
Create:
- `lib/features/auth/presentation/screens/splash_screen.dart`
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/screens/unauthorized_screen.dart`

**Splash Screen:**
Displays logo or brand name in centered view (dark background) using `AppColors.accent`. Checks the `authProvider` status and naturally navigates to login if unauthenticated, or home if authenticated. (Since we aren't using deep routing yet, just display it or a placeholder delay).

**Login Screen:**
A clean screen matching Figma/HTML design using `AppColors.background`. Shows the app logo/name and a large Google Sign-In button (`AppButton.icon`).
On tap, calls `ref.read(authRepositoryProvider).signInWithGoogle()`. Shows a loading state (`AppButton` with `isLoading=true`).
If success, redirect to dummy home. If failed / unauthorized, navigate to `UnauthorizedScreen` or show an Error Snackbar.

**Unauthorized Screen:**
Simple empty state with `AppColors.error` or warning icon. Message: "Your account is inactive or missing permissions. Please contact an administrator."
Add a button to "Sign Out & Try Again".
</action>
<acceptance_criteria>
- `splash_screen.dart` exists and uses `AppColors.accent` background
- `login_screen.dart` exists and integrates `Google SignIn` via AuthRepository
- `unauthorized_screen.dart` exists with the proper error message
</acceptance_criteria>
</task>

## 3. Wire Up Auth Routing to App Entrypoint
<task>
<read_first>
- lib/app.dart
- lib/features/auth/presentation/providers/auth_provider.dart
</read_first>
<action>
Update `lib/app.dart` to use `authProvider` state to determine the `home:` widget temporarily before go_router is added in Phase 3.
- If `state.isLoading`, show `SplashScreen()`.
- If `state.hasError` or the user obj indicates unauthorized, show `UnauthorizedScreen()`.
- If `state.hasData` (user is logged in and active), show `_PlaceholderHome()`.
- Otherwise (no user), show `LoginScreen()`.
</action>
<acceptance_criteria>
- `lib/app.dart` reads auth state and points `home:` to `SplashScreen`, `LoginScreen`, `UnauthorizedScreen`, or `_PlaceholderHome` based on current authentication
- Riverpod state is dynamically observed using `ref.watch()`
</acceptance_criteria>
</task>
