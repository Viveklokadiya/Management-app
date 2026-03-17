---
description: "Firebase initialization, Auth repositories, and AppUser modeling"
dependencies: []
gap_closure: false
---

# Phase 2: Firebase Integration & Auth - Plan 1 (Backend/Data Layer)

## 1. Implement AppUser Domain Model
<task>
<read_first>
- .planning/ROADMAP.md
- lib/features/auth/domain/models/
</read_first>
<action>
Create `lib/features/auth/domain/models/app_user.dart`.
Define `enum UserRole { superAdmin, admin, partner }`.
Define `AppUser` class using Freezed/JsonSerializable or standard Dart data class with:
- `id` (String)
- `email` (String)
- `name` (String)
- `phone` (String?)
- `role` (UserRole)
- `isActive` (bool)
- `lastLatitude` (double?)
- `lastLongitude` (double?)
- `lastLocationAt` (DateTime?)
- `createdAt` (DateTime)
- `updatedAt` (DateTime)

Implement `fromFirestore` factory method that safely parses the Firestore document snapshot, mapping the role string to the `UserRole` enum.
</action>
<acceptance_criteria>
- `lib/features/auth/domain/models/app_user.dart` exists and contains `class AppUser`
- Class contains all required fields including `UserRole role` and `bool isActive`
- `fromFirestore` method handles parsing and date conversions properly
</acceptance_criteria>
</task>

## 2. Implement User Remote Data Source
<task>
<read_first>
- lib/features/auth/domain/models/app_user.dart
</read_first>
<action>
Create `lib/features/auth/data/user_remote_data_source.dart`.
Define a class `UserRemoteDataSource` that takes a `FirebaseFirestore` instance.
Implement method `Future<AppUser?> getUserByEmail(String email)` that queries the `users` collection:
- `firestore.collection('users').where('email', isEqualTo: email).limit(1).get()`
- Parses the result using `AppUser.fromFirestore` and returns it, or returns null if not found.
</action>
<acceptance_criteria>
- `lib/features/auth/data/user_remote_data_source.dart` contains `getUserByEmail` logic
- Queries the `users` collection by `email`
</acceptance_criteria>
</task>

## 3. Implement Auth Repository and Provider
<task>
<read_first>
- lib/features/auth/domain/models/app_user.dart
- lib/features/auth/data/user_remote_data_source.dart
</read_first>
<action>
Create `lib/features/auth/domain/auth_repository.dart` defining `AuthRepository` interface (signInWithGoogle, signOut, getCurrentUser).
Create `lib/features/auth/data/auth_repository_impl.dart` implementing the interface:
- Take `FirebaseAuth`, `GoogleSignIn` and `UserRemoteDataSource` as dependencies.
- Implement `signInWithGoogle()`: uses `GoogleSignIn().signIn()`, gets auth tokens, signs into `FirebaseAuth` with credential. Then fetches the user from `UserRemoteDataSource.getUserByEmail(email)`. Throws an exception if user not active or not found.
- Implement `signOut()`: signs out from both `FirebaseAuth` and `GoogleSignIn()`.

Create `lib/features/auth/presentation/providers/auth_provider.dart` defining a Riverpod `authRepositoryProvider` and an `authStateProvider` (or similar StateNotifier) to expose the current authenticated `AppUser`.
</action>
<acceptance_criteria>
- `auth_repository_impl.dart` contains `signInWithGoogle` using `GoogleSignIn`
- Checks `isActive` flag for user and handles unauthorized cases
- Riverpod providers created to expose auth state
</acceptance_criteria>
</task>
