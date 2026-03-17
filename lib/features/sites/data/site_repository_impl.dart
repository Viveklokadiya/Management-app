import '../domain/models/site_model.dart';
import '../domain/models/site_user_model.dart';
import '../domain/repositories/site_repository.dart';
import 'site_remote_data_source.dart';

class SiteRepositoryImpl implements SiteRepository {
  final SiteRemoteDataSource _ds;
  SiteRepositoryImpl(this._ds);

  @override
  Stream<List<SiteModel>> getAllSites() => _ds.watchAllSites();

  @override
  Future<List<SiteModel>> getAssignedSites(String userId) =>
      _ds.getSitesForUser(userId);

  @override
  Future<String> createSite(SiteModel site) => _ds.createSite(site);

  @override
  Future<void> updateSite(SiteModel site) => _ds.updateSite(site);

  @override
  Future<void> assignUserToSite(SiteUserModel siteUser) =>
      _ds.assignUser(siteUser);

  @override
  Future<void> removeUserFromSite({
    required String siteId,
    required String userId,
  }) =>
      _ds.removeUser(siteId: siteId, userId: userId);

  @override
  Future<List<SiteUserModel>> getUsersForSite(String siteId) =>
      _ds.getUsersForSite(siteId);
}
