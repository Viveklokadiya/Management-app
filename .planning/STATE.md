---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: in_progress
last_updated: "2026-03-17T18:21:00.000Z"
progress:
  total_phases: 10
  completed_phases: 8
  total_plans: 13
  completed_plans: 13
---

# STATE.md — Shree Giriraj Engineering

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-17)

**Core value:** Partners and admins can record and view site-based money transactions accurately, with role-appropriate access, wherever they are on site.
**Current focus:** Phase 9 — Firestore Security Rules

---

## Current Status

**Phase:** 9 of 10
**Phase name:** Firestore Security Rules
**Phase state:** Not started

## Last Action

Phases 7 and 8 complete today (2026-03-17):

**Phase 7 (Super Admin Screens):**
- SuperAdminUsersScreen: tab filter (All/Admins/Partners), search, user cards with role badges, 3-dot menu (Edit, Toggle Active)
- AddEditUserScreen: Add/Edit mode, name + email, role dropdown, site checkboxes, active toggle, Firestore write
- Routes: /admin/add-user, /admin/edit-user/:id added to app_router.dart
- Providers: allUsersStreamProvider added to repository_providers.dart

**Phase 8 (Location Capture):**
- LocationService: request permission, capture GPS at LocationAccuracy.high, write to users/{id} doc (lastLatitude, lastLongitude, lastLocationAt)
- LocationPermissionBanner: persistent amber banner when permission denied/disabled, tap to open settings, dismiss button
- PartnerShell + AdminShell upgraded to ConsumerStatefulWidget — capture location on app open (post-frame)
- Fix: Replaced all Firestore collectionGroup queries with flat root `transactions` collection — partners and admin transaction queries now work without any Firestore index

## Architecture Decision: Flat Root Transactions Collection

Previous: `sites/{siteId}/transactions/{txnId}` subcollection with collectionGroup query → requires Firestore index  
New: Writes go to both `sites/{siteId}/transactions/{txnId}` AND `transactions/{txnId}` (root mirror)  
Partner home/transactions queries `transactions` where `createdByUserId == userId` → no index needed  
Admin all-transactions queries `transactions` root collection → no index needed

**Existing data note:** Transactions created before this change are only in the subcollection — they will not appear in partner/admin list until re-added. New transactions will appear correctly.

## Completed Phases

- [x] Phase 1: Project Setup & Architecture — 2026-03-17
- [x] Phase 2: Firebase Integration & Auth — 2026-03-17
- [x] Phase 3: Role-Based Routing & Guards — 2026-03-17
- [x] Phase 4: Firestore Schema & Repositories — 2026-03-17
- [x] Phase 5: Partner MVP Screens — 2026-03-17
- [x] Phase 6: Admin Screens — 2026-03-17
- [x] Phase 7: Super Admin Screens — 2026-03-17
- [x] Phase 8: Location Capture — 2026-03-17

## Blockers

None currently.

## Notes

- Figma design assets are in `Designs/` folder — 15 screen directories available
- All screens use AppColors, AppTextStyles, CurrencyFormatter for consistency
- collectionGroup index issue resolved by flat root transactions collection mirror
- Remaining: Phase 9 (Security Rules) + Phase 10 (Polish & Testing)

---
*STATE.md updated: 2026-03-17 — Phases 1–8 complete*
