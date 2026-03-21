import 'models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
  Future<AppUser> updateProfile({required String userId, required String name, required String? phone});
}
