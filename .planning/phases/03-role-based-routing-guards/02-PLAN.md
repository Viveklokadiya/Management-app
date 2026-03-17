---
description: "Navigation shells: PartnerShell, AdminShell with bottom nav; wire app_router into app.dart"
dependencies: ["01-PLAN.md"]
gap_closure: false
wave: 2
---

# Phase 3: Role-Based Routing & Guards — Plan 2 (Navigation Shells & App Wiring)

## 1. Create Partner Shell
<task>
<read_first>
- lib/core/theme/app_colors.dart
- lib/core/router/routes.dart
- lib/features/auth/domain/models/app_user.dart
</read_first>
<action>
Create `lib/features/partner/presentation/shell/partner_shell.dart`.

Build a `PartnerShell` StatelessWidget with a `Scaffold` that has:
- `body: child` (passed in from ShellRoute)
- `bottomNavigationBar: NavigationBar` with 3 destinations:
  1. Home → icon `Icons.home_outlined`, selected `Icons.home`, label `'Home'`, route: `AppRoutes.partnerHome`
  2. Transactions → icon `Icons.receipt_long_outlined`, selected `Icons.receipt_long`, label `'Transactions'`, route: `AppRoutes.partnerTransactions`
  3. Profile → icon `Icons.person_outline`, selected `Icons.person`, label `'Profile'`, route: `AppRoutes.partnerProfile`

Use `GoRouter.of(context).go(route)` for navigation on tap.
Determine the `selectedIndex` by matching the current `GoRouterState.of(context).matchedLocation` against the tab routes.

Style the `NavigationBar` with:
- `backgroundColor: AppColors.surface`
- `indicatorColor: AppColors.primaryLight`
- Selected label/icon color: `AppColors.primary`
- Unselected: `AppColors.textSecondary`

```dart
class PartnerShell extends StatelessWidget {
  final Widget child;
  const PartnerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final tabs = [
      AppRoutes.partnerHome,
      AppRoutes.partnerTransactions,
      AppRoutes.partnerProfile,
    ];
    final selectedIndex = tabs.indexWhere((t) => location.startsWith(t)).clamp(0, tabs.length - 1);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => context.go(tabs[i]),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```
</action>
<acceptance_criteria>
- `lib/features/partner/presentation/shell/partner_shell.dart` exists
- Contains `class PartnerShell` with `final Widget child` constructor parameter
- `NavigationBar` has exactly 3 destinations: Home, Transactions, Profile
- Uses `context.go()` for tab navigation
</acceptance_criteria>
</task>

## 2. Create Admin Shell
<task>
<read_first>
- lib/core/theme/app_colors.dart
- lib/core/router/routes.dart
- lib/features/auth/domain/models/app_user.dart
- lib/features/auth/presentation/providers/auth_provider.dart
</read_first>
<action>
Create `lib/features/admin/presentation/shell/admin_shell.dart`.

Build a `AdminShell` ConsumerWidget with a `Scaffold` that has:
- `body: child` (passed in from ShellRoute)
- `bottomNavigationBar: NavigationBar` with destinations that vary by role:
  - **Admin & SuperAdmin common tabs:**
    1. Home → `Icons.dashboard_outlined` / `Icons.dashboard`, `AppRoutes.adminHome`
    2. Partners → `Icons.people_outline` / `Icons.people`, `AppRoutes.adminPartners`
    3. Sites → `Icons.location_city_outlined` / `Icons.location_city`, `AppRoutes.adminSites`
    4. Transactions → `Icons.receipt_long_outlined` / `Icons.receipt_long`, `AppRoutes.adminTransactions`
    5. Profile → `Icons.person_outline` / `Icons.person`, `AppRoutes.adminProfile`
  - **Super Admin only — append 6th tab:**
    6. Users → `Icons.manage_accounts_outlined` / `Icons.manage_accounts`, `AppRoutes.superAdminUsers`

Read the current user's role from `ref.watch(authStateProvider).value?.role` to decide whether to show 5 or 6 tabs.

```dart
class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final isSuperAdmin = user?.role == UserRole.superAdmin;

    final tabs = [
      AppRoutes.adminHome,
      AppRoutes.adminPartners,
      AppRoutes.adminSites,
      AppRoutes.adminTransactions,
      AppRoutes.adminProfile,
      if (isSuperAdmin) AppRoutes.superAdminUsers,
    ];
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = tabs.indexWhere((t) => location.startsWith(t)).clamp(0, tabs.length - 1);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => context.go(tabs[i]),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Partners'),
          const NavigationDestination(icon: Icon(Icons.location_city_outlined), selectedIcon: Icon(Icons.location_city), label: 'Sites'),
          const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transactions'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          if (isSuperAdmin)
            const NavigationDestination(icon: Icon(Icons.manage_accounts_outlined), selectedIcon: Icon(Icons.manage_accounts), label: 'Users'),
        ],
      ),
    );
  }
}
```
</action>
<acceptance_criteria>
- `lib/features/admin/presentation/shell/admin_shell.dart` exists
- Contains `class AdminShell extends ConsumerWidget` with `final Widget child`
- Normal admin sees 5 tabs; superAdmin sees 6 tabs (includes Users)
- Uses `ref.watch(authStateProvider)` to determine role
</acceptance_criteria>
</task>

## 3. Wire GoRouter into app.dart
<task>
<read_first>
- lib/app.dart
- lib/core/router/app_router.dart
- lib/features/auth/presentation/providers/auth_provider.dart
</read_first>
<action>
Update `lib/app.dart` to replace the manual auth-state `home:` switching with `MaterialApp.router` + the `appRouterProvider`.

Replace the `MaterialApp(...)` widget with `MaterialApp.router(...)`:

```dart
final router = ref.watch(appRouterProvider);

return MaterialApp.router(
  title: 'Shree Giriraj Engineering',
  debugShowCheckedModeBanner: false,
  theme: AppTheme.lightTheme,
  locale: locale,
  localizationsDelegates: const [...],
  supportedLocales: appSupportedLocales,
  routerConfig: router,
);
```

Remove the now-unneeded manual `authState.when(...)` home switching and the direct imports of screen files (login, splash, unauthorized) from `app.dart` — those are now handled by the router.

Keep `_PlaceholderHome` class inside `app.dart` for now (it's used by the router's redirect for authenticated admin users until Phase 5/6 screens are built).

Add import:
```dart
import 'core/router/app_router.dart';
```

Also run `dart run build_runner build -d` after all files are created to generate `app_router.g.dart`.
</action>
<acceptance_criteria>
- `lib/app.dart` uses `MaterialApp.router(routerConfig: router)`
- `ref.watch(appRouterProvider)` used to get the `GoRouter` instance
- No more hardcoded `home: authState.when(...)` in `app.dart`
- `app_router.g.dart` generated (build_runner passes without errors)
</acceptance_criteria>
</task>
