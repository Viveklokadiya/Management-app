# Roadmap: Shree Giriraj Engineering — Transaction Management App

**Milestone:** v1.0 — Android MVP
**Requirements:** 58 v1 requirements
**Phases:** 10

---

## Phase Overview

| # | Phase | Goal | Requirements | Success Criteria |
|---|-------|------|--------------|-----------------|
| 1 | Project Setup & Architecture | Flutter project scaffold with clean architecture, theming, and reusable widgets | TECH-01–08 | App builds; layer structure exists; theme applies |
| 2 | Firebase Integration & Auth | Complete    | 2026-03-17 | Login flow complete; unauthorized denied |
| 3 | Role-Based Routing & Guards | Complete    | 2026-03-17 | Each role sees correct navigation |
| 4 | Firestore Schema & Repositories | Complete    | 2026-03-17 | Repositories read/write to Firestore correctly |
| 5 | Partner MVP Screens | All partner-facing screens functional end-to-end | TXN-01–05, DASH-01–02, PROF-01–03, AUDIT-01–03, LOC-01–05 | Partner can log in, create transactions, view list/detail, see home dashboard |
| 6 | Admin Screens | All admin-facing screens functional | TXN-06–09, SITE-01–05, USER-05–09, DASH-03–05 | Admin can manage transactions, sites, view partners |
| 7 | Super Admin Screens | User management screens for super admin | USER-01–04 | Super admin can add, edit, deactivate users |
| 8 | Location Capture | Foreground location on app open and transaction creation | LOC-01–05 | Location stored in user doc and transaction; permission denial handled |
| 9 | Firestore Security Rules | Write and deploy security rules enforcing role-based access | SEC-01–06 | Unauthorized reads/writes rejected; authorized access works |
| 10 | Final Polish & Testing | UI consistency pass, error states, edge case handling, basic unit tests | All | App demo-ready; error/loading/empty states everywhere; tests pass |

---

## Phase Details

---

### Phase 1: Project Setup & Architecture

**Goal:** Create a production-quality Flutter project structure with clean architecture, centralized theming, and reusable widget foundations that all subsequent phases build upon.

**Requirements:** TECH-01–08

**Files to create:**
```
lib/
  main.dart
  app.dart
  core/
    theme/
      app_theme.dart
      app_colors.dart
      app_text_styles.dart
    constants/
      app_constants.dart
    utils/
      currency_formatter.dart
      date_formatter.dart
    widgets/
      app_button.dart
      app_card.dart
      app_text_field.dart
      loading_widget.dart
      empty_state_widget.dart
      error_state_widget.dart
      amount_display.dart
  features/
    (empty placeholder dirs for each feature)
pubspec.yaml (with all dependencies declared)
```

**Dependencies to add:**
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `google_sign_in`
- `flutter_riverpod`
- `riverpod_annotation`
- `go_router`
- `geolocator`
- `permission_handler`
- `intl` (for currency + date formatting)
- `cached_network_image`
- `flutter_svg` (if needed for assets)

**Success Criteria:**
1. `flutter run` launches without errors on Android
2. Deep navy theme applies to AppBar and primary buttons
3. `CurrencyFormatter.format(1234567)` returns `₹12,34,567`
4. Reusable widgets (AppButton, AppCard, AppTextField) render correctly in isolation
5. Clean 3-layer folder structure exists under `lib/features/`
6. All declared dependencies resolve (`flutter pub get` succeeds)

---

### Phase 2: Firebase Integration & Auth

**Goal:** Connect Firebase, implement Google Sign-In, query Firestore for user approval, and handle unauthorized access gracefully.

**Requirements:** AUTH-01–06

**Files to create/modify:**
```
lib/
  features/
    auth/
      data/
        auth_repository_impl.dart
        user_remote_data_source.dart
      domain/
        auth_repository.dart
        models/
          app_user.dart
      presentation/
        screens/
          splash_screen.dart
          login_screen.dart
          unauthorized_screen.dart
        providers/
          auth_provider.dart
  firebase_options.dart
google-services.json (user provides)
```

**Success Criteria:**
1. Splash screen shows branding, then redirects to Login or Home based on auth state
2. Google Sign-In button works on Android device/emulator
3. Firestore query checks `users` collection by email
4. If email not found → Unauthorized screen with friendly message
5. If `isActive: false` → Unauthorized screen shown
6. Logout from Profile screen clears auth state and returns to Login
7. Auth state persists across app restarts (Firebase Auth token)

---

### Phase 3: Role-Based Routing & Guards

**Goal:** Configure go_router with role guards that redirect users to the correct home screen based on their Firestore role, and build the navigation shells for each role.

**Requirements:** RBAC-01–09

**Files to create/modify:**
```
lib/
  core/
    router/
      app_router.dart
      route_guard.dart
      routes.dart (route name constants)
  features/
    partner/
      presentation/
        shell/
          partner_shell.dart (bottom nav)
    admin/
      presentation/
        shell/
          admin_shell.dart (bottom nav)
    super_admin/
      presentation/
        shell/
          super_admin_shell.dart
```

**Success Criteria:**
1. Partner role → navigates to Partner shell (bottom nav: Home, Transactions, Profile)
2. Admin role → navigates to Admin shell (bottom nav: Home, Partners, Sites, Transactions, Profile)
3. Super Admin role → navigates to Admin shell + Users item in nav
4. Direct URL to partner-only route as admin → redirected to Admin home
5. Unauthenticated user hitting any protected route → redirected to Login
6. Role guard reads from Riverpod auth state (no extra Firestore calls)

---

### Phase 4: Firestore Schema & Repositories

**Goal:** Define Dart data models for all Firestore collections and implement repository classes with CRUD operations, Firestore-to-model mapping, and error handling.

**Requirements:** TECH-01–04 (foundational for all feature phases)

**Files to create:**
```
lib/
  features/
    auth/
      domain/models/
        app_user.dart (extended — with role enum, location fields)
    transactions/
      domain/models/
        transaction_model.dart
        audit_log_model.dart
      domain/repositories/
        transaction_repository.dart
      data/
        transaction_repository_impl.dart
        transaction_remote_data_source.dart
    sites/
      domain/models/
        site_model.dart
        site_user_model.dart
      domain/repositories/
        site_repository.dart
      data/
        site_repository_impl.dart
        site_remote_data_source.dart
    users/
      domain/models/
        user_model.dart
      domain/repositories/
        user_repository.dart
      data/
        user_repository_impl.dart
        user_remote_data_source.dart
  core/
    providers/
      repository_providers.dart
```

**Collections:**
- `users` — full model including role, location fields, isActive
- `sites` — site details, isActive
- `site_users` — siteId + userId join table
- `transactions` — full transaction model
- `audit_logs` — write-only audit entries

**Success Criteria:**
1. `AppUser.fromFirestore()` parses all fields including nested role enum
2. `TransactionModel.fromFirestore()` and `.toMap()` are symmetric (round-trip)
3. `TransactionRepository.createTransaction()` writes to Firestore and returns created doc ID
4. `TransactionRepository.getTransactionsForSite()` returns stream of transactions
5. `SiteRepository.getAssignedSites(userId)` returns correct sites for a partner
6. Repository providers are registered in Riverpod and injectable

---

### Phase 5: Partner MVP Screens

**Goal:** Build all partner-facing screens end-to-end: Home dashboard, transaction list, add/edit transaction, transaction detail, and profile.

**Requirements:** TXN-01–05, DASH-01–02, PROF-01–03, AUDIT-01–03, LOC-01–02

**Screens to build:**
```
lib/features/partner/presentation/screens/
  partner_home_screen.dart
  partner_transactions_screen.dart
  add_transaction_screen.dart   (shared with admin)
  transaction_detail_screen.dart (shared)
  profile_screen.dart           (shared)
```

**Per screen:**

**Partner Home:**
- Greeting with user name
- Summary cards: Today Income (₹), Today Expense (₹), Total Transactions
- Quick action buttons: Add Income, Add Expense (pre-fills type)
- Recent transactions list (last 5)
- FAB → Add Transaction

**Transactions List:**
- Card-based list: amount + type color (green income, red expense), site name, date, payment method chip
- Filter row: date range picker, site dropdown, type toggle, payment method dropdown
- FAB → Add Transaction

**Add Transaction:**
- Segmented: Income | Expense
- Amount field (numeric, ₹ formatted)
- Site dropdown (partner's assigned sites only)
- Payment method dropdown: Cash, UPI, Bank, Other
- Date picker (defaults to today)
- Remarks text area (optional)
- Save button with loading state

**Transaction Detail:**
- All fields displayed in clean card layout
- Location captured at creation (city/coordinates)
- CreatedAt, UpdatedAt timestamps
- (Edit/Delete buttons hidden for partner)

**Profile:**
- Avatar + name + email + phone
- Last location updated timestamp
- Privacy Policy link (placeholder)
- Logout button

**Success Criteria:**
1. Partner can sign in, see home with ₹ formatted summary cards
2. Partner can create a transaction — appears in list immediately (Firestore stream)
3. Transaction list filters work independently and in combination
4. Adding a transaction writes audit log entry to `audit_logs` collection
5. Transaction detail shows all data including location summary
6. Profile shows correct user data; logout works

---

### Phase 6: Admin Screens

**Goal:** Build all admin-facing screens: Admin Home, Partners list, Partner detail (tabs), Sites list, Site detail (tabs), and admin-level transaction management.

**Requirements:** TXN-06–09, SITE-01–05, USER-05–09, DASH-03–05

**Screens to build:**
```
lib/features/admin/presentation/screens/
  admin_home_screen.dart
  partners_list_screen.dart
  partner_detail_screen.dart    (tabs: Overview, Transactions, Location)
  sites_list_screen.dart
  site_detail_screen.dart       (tabs: Overview, Partners, Transactions)
  admin_transactions_screen.dart
  add_edit_transaction_screen.dart  (extends add_transaction_screen.dart)
```

**Per screen:**

**Admin Home:**
- Greeting + date
- Summary cards: Today Income, Today Expense, Net Balance
- Stats row: Total Transactions Today, Active Sites
- Recent transactions list with all partners
- Quick actions: Add Transaction, View Partners, View Sites

**Partners List:**
- List card per partner: avatar, name, email/phone, assigned site count badge, last location updated
- Search bar

**Partner Detail:**
- Tab 1: Overview — profile info, assigned sites chips, total transactions, total income/expense
- Tab 2: Transactions — filtered list of this partner's transactions with date/type filters
- Tab 3: Location — map placeholder + last known lat/lng + timestamp

**Sites List:**
- Site cards: site name, address, partner count, recent transaction count

**Site Detail:**
- Tab 1: Overview — name, address, lat/lng, active status
- Tab 2: Partners — list of assigned partners
- Tab 3: Transactions — all transactions for this site

**Admin Transactions:**
- Same as partner list but shows all partners' transactions
- Includes edit and delete actions on each card
- Confirm dialog before delete + audit log on delete

**Success Criteria:**
1. Admin Home shows correct aggregated ₹ values from Firestore
2. Partners list loads all users with role=partner
3. Partner detail tabs all load correct data
4. Admin can edit a transaction → Firestore updated + audit log written
5. Admin can delete a transaction → Firestore deleted + audit log written (oldData captured)
6. Site detail shows correct assigned partners and transactions

---

### Phase 7: Super Admin Screens

**Goal:** Add user management screens visible only to Super Admin: Users list, Add user, Edit user (includes role assignment and active toggle).

**Requirements:** USER-01–04

**Screens to build:**
```
lib/features/super_admin/presentation/screens/
  users_list_screen.dart
  add_edit_user_screen.dart
```

**Users List:**
- All users (any role) in a list
- Role chip (color coded: Super Admin = dark navy, Admin = blue, Partner = grey)
- Active/Inactive badge
- Tap → Add/Edit User screen
- FAB → Add new user

**Add/Edit User:**
- Name, email (read-only on edit), phone
- Role dropdown: Partner | Admin | Super Admin
- Active toggle
- Save button

**Success Criteria:**
1. Super Admin sees Users List in nav; Admin does not
2. Super Admin can create a new user document in Firestore with correct role
3. Super Admin can change a user's role — updating Firestore document
4. Super Admin can deactivate a user — `isActive: false` set
5. Deactivated user cannot log in (auth check catches `isActive: false`)
6. Admin attempting to access Users List → redirected (route guard)

---

### Phase 8: Location Capture

**Goal:** Implement foreground location capture on app open and on transaction creation; store in Firestore and display in UI.

**Requirements:** LOC-01–05

**Files to create/modify:**
```
lib/
  core/
    services/
      location_service.dart
  features/
    auth/ (update: capture location on app open after login)
    transactions/ (update: capture location on transaction create)
```

**Logic:**
1. On app open (after auth confirmed): request location permission if not granted
2. If granted: get current position, write to `users/{userId}` fields: `lastLatitude`, `lastLongitude`, `lastLocationAt`
3. If denied: proceed silently, fields stay null
4. On transaction create: capture current position, store in transaction document
5. Partner detail > Location tab: display `lastLatitude`, `lastLongitude`, `lastLocationAt`
6. Transaction detail: display location captured at creation

**Success Criteria:**
1. On first launch, location permission dialog appears
2. After permission granted, user doc updates with lat/lng
3. Creating a transaction stores location in transaction document
4. Denying location permission → app continues without error
5. Partner Location tab shows last known coordinates and timestamp
6. Transaction detail shows "Location captured: [coords]" or "Location not available"

---

### Phase 9: Firestore Security Rules

**Goal:** Write and deploy Firestore security rules that enforce role-based access at the database level, preventing unauthorized reads and writes.

**Requirements:** SEC-01–06

**File to create:**
```
firestore.rules
```

**Rules summary:**
- `users/{userId}`: read if `request.auth.uid == userId` OR caller has admin/super_admin role; write only if Super Admin OR self (limited fields)
- `sites/{siteId}`: read if user is in `site_users` for this site (partner) OR admin/super_admin; write if admin/super_admin
- `site_users/{id}`: read if referenced userId is caller OR admin/super_admin; write if admin/super_admin
- `transactions/{id}`: read if `transaction.userId == caller` (partner) OR admin/super_admin; write (create) if partner for assigned site OR admin/super_admin; write (update/delete) only if admin/super_admin
- `audit_logs/{id}`: create only (no reads, no updates, no deletes from client)

**Success Criteria:**
1. Partner cannot read another partner's transactions (Firestore rejects)
2. Partner can read transactions for their assigned sites
3. Admin can read/write all transactions
4. Non-Super-Admin cannot write `admin` or `super_admin` role to `users`
5. Audit log: create works, read returns permission denied
6. Rules deploy without errors (`firebase deploy --only firestore:rules`)

---

### Phase 10: Final Polish & Testing

**Goal:** Ensure all screens have consistent loading, empty, and error states; fix UI inconsistencies; add basic unit tests for business logic; prepare for demo.

**Requirements:** All (coverage pass)

**Tasks:**
- Audit every screen for loading/empty/error state coverage
- Verify ₹ formatting is consistent everywhere
- Check that all FABs and CTAs are accessible
- Verify role guards on all routes (manual test each role)
- Write unit tests for:
  - `CurrencyFormatter.format()` edge cases
  - `TransactionModel.fromFirestore()` / `.toMap()` round-trip
  - Audit log generation logic
  - Role enum parsing
- Fix any Dart analysis warnings (`flutter analyze`)
- Run on Android emulator — verify no layout overflow or rendering issues
- Verify `flutter pub outdated` — no critical security updates pending
- Check all Firestore security rules still pass after any schema changes

**Success Criteria:**
1. Zero `flutter analyze` errors (warnings acceptable if documented)
2. All screens show a loading spinner while data fetches
3. All screens show "No data" empty state when collection is empty
4. All screens show "Something went wrong" + retry button on error
5. Unit tests pass: `flutter test`
6. Demo walkthrough passes: Partner creates transaction, Admin views it, Super Admin manages users
7. ₹ formatting is consistent on every screen with Indian number system (lakhs/crores)

---

## Requirement Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01 | 2 | Pending |
| AUTH-02 | 2 | Pending |
| AUTH-03 | 2 | Pending |
| AUTH-04 | 2 | Pending |
| AUTH-05 | 2 | Pending |
| AUTH-06 | 2 | Pending |
| RBAC-01 | 3 | Pending |
| RBAC-02 | 3 | Pending |
| RBAC-03 | 3 | Pending |
| RBAC-04 | 3 | Pending |
| RBAC-05 | 3 | Pending |
| RBAC-06 | 3 | Pending |
| RBAC-07 | 3 | Pending |
| RBAC-08 | 3 | Pending |
| RBAC-09 | 3 | Pending |
| TXN-01 | 5 | Pending |
| TXN-02 | 5 | Pending |
| TXN-03 | 5 | Pending |
| TXN-04 | 5 | Pending |
| TXN-05 | 5 | Pending |
| TXN-06 | 6 | Pending |
| TXN-07 | 5 | Pending |
| TXN-08 | 6 | Pending |
| TXN-09 | 6 | Pending |
| TXN-10 | 5 | Pending |
| SITE-01 | 6 | Pending |
| SITE-02 | 6 | Pending |
| SITE-03 | 6 | Pending |
| SITE-04 | 6 | Pending |
| SITE-05 | 6 | Pending |
| USER-01 | 7 | Pending |
| USER-02 | 7 | Pending |
| USER-03 | 7 | Pending |
| USER-04 | 7 | Pending |
| USER-05 | 6 | Pending |
| USER-06 | 6 | Pending |
| USER-07 | 6 | Pending |
| USER-08 | 6 | Pending |
| USER-09 | 6 | Pending |
| LOC-01 | 8 | Pending |
| LOC-02 | 8 | Pending |
| LOC-03 | 8 | Pending |
| LOC-04 | 8 | Pending |
| LOC-05 | 8 | Pending |
| AUDIT-01 | 5 | Pending |
| AUDIT-02 | 6 | Pending |
| AUDIT-03 | 6 | Pending |
| DASH-01 | 5 | Pending |
| DASH-02 | 5 | Pending |
| DASH-03 | 6 | Pending |
| DASH-04 | 6 | Pending |
| DASH-05 | 5–6 | Pending |
| PROF-01 | 5 | Pending |
| PROF-02 | 5 | Pending |
| PROF-03 | 5 | Pending |
| SEC-01 | 9 | Pending |
| SEC-02 | 9 | Pending |
| SEC-03 | 9 | Pending |
| SEC-04 | 9 | Pending |
| SEC-05 | 9 | Pending |
| SEC-06 | 9 | Pending |
| TECH-01 | 1 | Pending |
| TECH-02 | 4 | Pending |
| TECH-03 | 1 | Pending |
| TECH-04 | 3 | Pending |
| TECH-05 | 1 | Pending |
| TECH-06 | 1 | Pending |
| TECH-07 | 5 | Pending |
| TECH-08 | 10 | Pending |

**Coverage:**
- v1 requirements: 68 total (58 functional + 10 technical)
- Mapped to phases: 68
- Unmapped: 0 ✓

---
*Roadmap created: 2026-03-17*
*Milestone: v1.0 Android MVP*
