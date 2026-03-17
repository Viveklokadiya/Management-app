---
description: "Router infrastructure: routes constants, route guard logic, and app_router wiring"
dependencies: []
gap_closure: false
wave: 1
---

# Phase 3: Role-Based Routing & Guards — Plan 1 (Router Infrastructure)

## 1. Create Route Constants
<task>
<read_first>
- lib/features/auth/domain/models/app_user.dart
</read_first>
<action>
Create `lib/core/router/routes.dart`.

Define a final class `AppRoutes` with static const string route name constants:

```dart
final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const unauthorized = '/unauthorized';

  // Partner routes
  static const partnerHome = '/partner/home';
  static const partnerTransactions = '/partner/transactions';
  static const partnerProfile = '/partner/profile';

  // Admin routes
  static const adminHome = '/admin/home';
  static const adminPartners = '/admin/partners';
  static const adminSites = '/admin/sites';
  static const adminTransactions = '/admin/transactions';
  static const adminProfile = '/admin/profile';

  // Super Admin routes (extends admin)
  static const superAdminUsers = '/admin/users';
}
```
</action>
<acceptance_criteria>
- `lib/core/router/routes.dart` exists
- Contains `class AppRoutes` with all route constants listed above
- Each constant is a `static const String`
</acceptance_criteria>
</task>

## 2. Create Route Guard
<task>
<read_first>
- lib/core/router/routes.dart
- lib/features/auth/domain/models/app_user.dart
- lib/features/auth/presentation/providers/auth_provider.dart
</read_first>
<action>
Create `lib/core/router/route_guard.dart`.

Implement a `redirect` function for go_router that reads from `authStateProvider` (Riverpod) and enforces role-based access:

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/models/app_user.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'routes.dart';

String? routeGuard(WidgetRef ref, GoRouterState state) {
  final authAsync = ref.read(authStateProvider);

  return authAsync.when(
    loading: () => null, // let splash handle it
    error: (_, __) => AppRoutes.login,
    data: (user) {
      final location = state.matchedLocation;

      // Not logged in → always redirect to login
      if (user == null) {
        if (location == AppRoutes.login || location == AppRoutes.splash) return null;
        return AppRoutes.login;
      }

      // Logged-in user hitting auth screens → redirect to their home
      if (location == AppRoutes.login || location == AppRoutes.splash) {
        return _homeForUser(user);
      }

      // Role enforcement: partner cannot access admin routes
      if (location.startsWith('/admin') && user.role == UserRole.partner) {
        return AppRoutes.partnerHome;
      }

      // Role enforcement: admin cannot access super_admin-only routes
      if (location == AppRoutes.superAdminUsers && user.role == UserRole.admin) {
        return AppRoutes.adminHome;
      }

      return null; // allow navigation
    },
  );
}

String _homeForUser(AppUser user) {
  return switch (user.role) {
    UserRole.partner => AppRoutes.partnerHome,
    UserRole.admin => AppRoutes.adminHome,
    UserRole.superAdmin => AppRoutes.adminHome,
  };
}
```
</action>
<acceptance_criteria>
- `lib/core/router/route_guard.dart` exists
- Contains `routeGuard` function that returns `String?`
- Partner role redirected away from `/admin/` routes
- Admin role redirected away from `/admin/users`
- Unauthenticated user redirected to `/login`
</acceptance_criteria>
</task>

## 3. Create App Router
<task>
<read_first>
- lib/core/router/routes.dart
- lib/core/router/route_guard.dart
- lib/features/auth/presentation/screens/login_screen.dart
- lib/features/auth/presentation/screens/unauthorized_screen.dart
</read_first>
<action>
Create `lib/core/router/app_router.dart`.

Use `riverpod_annotation` to create a `@riverpod` `GoRouter` provider using `ref.watch(authStateProvider)` for redirect invalidation:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/unauthorized_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/partner/presentation/shell/partner_shell.dart';
import '../../features/admin/presentation/shell/admin_shell.dart';
import 'route_guard.dart';
import 'routes.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthChangeNotifier(ref, authState),
    redirect: (context, state) => routeGuard(ref, state),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.unauthorized,
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      // Partner shell with nested routes
      ShellRoute(
        builder: (context, state, child) => PartnerShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.partnerHome,        builder: (c, s) => const PartnerHomePlaceholder()),
          GoRoute(path: AppRoutes.partnerTransactions, builder: (c, s) => const PartnerTransactionsPlaceholder()),
          GoRoute(path: AppRoutes.partnerProfile,      builder: (c, s) => const PartnerProfilePlaceholder()),
        ],
      ),
      // Admin shell with nested routes
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.adminHome,         builder: (c, s) => const AdminHomePlaceholder()),
          GoRoute(path: AppRoutes.adminPartners,     builder: (c, s) => const AdminPartnersPlaceholder()),
          GoRoute(path: AppRoutes.adminSites,        builder: (c, s) => const AdminSitesPlaceholder()),
          GoRoute(path: AppRoutes.adminTransactions, builder: (c, s) => const AdminTransactionsPlaceholder()),
          GoRoute(path: AppRoutes.adminProfile,      builder: (c, s) => const AdminProfilePlaceholder()),
          GoRoute(path: AppRoutes.superAdminUsers,   builder: (c, s) => const SuperAdminUsersPlaceholder()),
        ],
      ),
    ],
  );
}

// Notifier that tells GoRouter to re-evaluate redirect when auth changes
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref, AsyncValue authState) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
```

Note: Placeholder screens (e.g. `PartnerHomePlaceholder`) will be simple `Scaffold` widgets with a `Text` label. They exist ONLY as stubs — real screen implementations come in Phases 5–7.

Create all placeholder widgets in `lib/core/router/app_router.dart` as private classes at the bottom of the file:

```dart
class PartnerHomePlaceholder extends StatelessWidget {
  const PartnerHomePlaceholder({super.key});
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Partner Home (Phase 5)')));
}
// ... repeat for all placeholders
```
</action>
<acceptance_criteria>
- `lib/core/router/app_router.dart` exists and contains `appRouterProvider`
- GoRouter uses `ShellRoute` for partner and admin groups
- `redirect` calls `routeGuard(ref, state)`
- `refreshListenable` triggers on auth state change
- All placeholder routes compile without errors
</acceptance_criteria>
</task>
