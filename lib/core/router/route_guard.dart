import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/models/app_user.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'routes.dart';

String? routeGuard(Ref ref, GoRouterState state) {
  final authAsync = ref.read(authStateProvider);

  return authAsync.when(
    loading: () => null,
    error: (_, __) => AppRoutes.login,
    data: (user) {
      final location = state.matchedLocation;

      // Not logged in → always redirect to login
      if (user == null) {
        if (location == AppRoutes.login) return null;
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

      return null;
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
