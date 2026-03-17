final class AppRoutes {
  AppRoutes._();

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

  // Super Admin routes (extends admin shell)
  static const superAdminUsers = '/admin/users';
}
