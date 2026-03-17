import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/auth_repository.dart';
import '../domain/models/app_user.dart';
import 'user_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserRemoteDataSource _userRemoteDataSource;

  AuthRepositoryImpl(
    this._firebaseAuth,
    this._googleSignIn,
    this._userRemoteDataSource,
  );

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was canceled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null || firebaseUser.email == null) {
        throw Exception('Failed to sign in. No email found.');
      }

      // Check user in Firestore
      final appUser = await _userRemoteDataSource.getUserByEmail(firebaseUser.email!);

      if (appUser == null) {
        await _firebaseAuth.signOut();
        await _googleSignIn.signOut();
        throw Exception('User is not registered. Please contact an administrator.');
      }

      if (!appUser.isActive) {
        await _firebaseAuth.signOut();
        await _googleSignIn.signOut();
        throw Exception('Your account is inactive. Please contact an administrator.');
      }

      return appUser;
    } catch (e) {
      if (e is FirebaseAuthException) {
         throw Exception(e.message ?? 'Unknown Firebase Error');
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && user.email != null) {
      final appUser = await _userRemoteDataSource.getUserByEmail(user.email!);
      if (appUser != null && appUser.isActive) {
        return appUser;
      } else {
        await signOut();
      }
    }
    return null;
  }
}
