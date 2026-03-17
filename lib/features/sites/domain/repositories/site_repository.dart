import '../models/site_model.dart';
import '../models/site_user_model.dart';

abstract class SiteRepository {
  /// Real-time stream of all active sites (admin/superAdmin)
  Stream<List<SiteModel>> getAllSites();

  /// Fetch sites assigned to a specific partner via site_users join
  Future<List<SiteModel>> getAssignedSites(String userId);

  /// Create a new site — returns doc ID
  Future<String> createSite(SiteModel site);

  /// Update site details
  Future<void> updateSite(SiteModel site);

  /// Assign a partner user to a site
  Future<void> assignUserToSite(SiteUserModel siteUser);

  /// Remove a partner user from a site
  Future<void> removeUserFromSite({
    required String siteId,
    required String userId,
  });

  /// Get all users assigned to a site
  Future<List<SiteUserModel>> getUsersForSite(String siteId);
}
