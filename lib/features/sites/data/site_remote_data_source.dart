import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/site_model.dart';
import '../domain/models/site_user_model.dart';

class SiteRemoteDataSource {
  final FirebaseFirestore _db;
  SiteRemoteDataSource(this._db);

  Stream<List<SiteModel>> watchAllSites() => _db
      .collection('sites')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) {
        final list = s.docs.map(SiteModel.fromFirestore).toList();
        list.sort((a, b) => a.name.compareTo(b.name)); // sort client-side
        return list;
      });

  Future<List<SiteModel>> getSitesForUser(String userId) async {
    // Step 1: find all site_users entries for this user
    final siteUserDocs = await _db
        .collection('site_users')
        .where('userId', isEqualTo: userId)
        .get();

    final siteIds = siteUserDocs.docs
        .map((d) => d['siteId'] as String)
        .toList();

    if (siteIds.isEmpty) return [];

    // Step 2: fetch those site docs (whereIn limit: 30)
    final siteDocs = await _db
        .collection('sites')
        .where(FieldPath.documentId, whereIn: siteIds.take(30).toList())
        .where('isActive', isEqualTo: true)
        .get();

    return siteDocs.docs.map(SiteModel.fromFirestore).toList();
  }

  Future<String> createSite(SiteModel site) async {
    final ref = await _db.collection('sites').add(site.toMap());
    return ref.id;
  }

  Future<void> updateSite(SiteModel site) =>
      _db.collection('sites').doc(site.id).update(site.toMap());

  Future<void> assignUser(SiteUserModel siteUser) =>
      _db.collection('site_users').add(siteUser.toMap());

  Future<void> removeUser({
    required String siteId,
    required String userId,
  }) async {
    final snap = await _db
        .collection('site_users')
        .where('siteId', isEqualTo: siteId)
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<SiteUserModel>> getUsersForSite(String siteId) async {
    final snap = await _db
        .collection('site_users')
        .where('siteId', isEqualTo: siteId)
        .get();
    return snap.docs.map(SiteUserModel.fromFirestore).toList();
  }
}
