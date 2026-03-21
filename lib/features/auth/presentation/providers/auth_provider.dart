import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/auth_repository_impl.dart';
import '../../data/user_remote_data_source.dart';
import '../../domain/auth_repository.dart';
import '../../domain/models/app_user.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    FirebaseAuth.instance,
    GoogleSignIn(clientId: '103378846246-0k8s5q4utn435fejei3a0vej07cj82v8.apps.googleusercontent.com'),
    UserRemoteDataSource(FirebaseFirestore.instance),
  );
}

@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<AppUser?> build() async {
    final authRepository = ref.read(authRepositoryProvider);
    return await authRepository.getCurrentUser();
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      return await authRepository.signInWithGoogle();
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signOut();
      return null;
    });
  }

  Future<void> updateProfile({
    required String name,
    required String? phone,
  }) async {
    final current = state.value;
    if (current == null) return;
    state = await AsyncValue.guard(() async {
      return await ref.read(authRepositoryProvider).updateProfile(
            userId: current.id,
            name: name,
            phone: phone,
          );
    });
  }
}
