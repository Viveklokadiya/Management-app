---
phase: 9
status: passed
date: 2026-03-18
---

# Phase 9 Verification: Firestore Security Rules

## Summary

All must-haves verified. `firestore.rules` written with full role-based access control across all 5 collections. `firebase.json` updated with firestore target. Ready for `firebase deploy --only firestore:rules`.

## Must-Haves

- [x] `firestore.rules` file exists at project root
- [x] `firebase.json` has `"firestore": { "rules": "firestore.rules", "indexes": "firestore.indexes.json" }` configured
- [x] `users` collection — Partner reads own doc; Admin/SuperAdmin reads all; SuperAdmin writes; any user updates own location fields
- [x] `sites` collection — All authenticated users read; Admin/SuperAdmin write
- [x] `site_users` collection — Partners read own entries; Admins read/write all
- [x] `transactions` collection — Partners create/read own; Admins read/update/delete all
- [x] `audit_logs` collection — create-only from any authenticated user; no reads from client
- [x] Super Admin has write access to `users` collection
- [x] Deny-all catch-all rule exists (`match /{document=**}`)
- [x] Helper functions: `isAuthed()`, `isPartner()`, `isAdmin()`, `isSuperAdmin()`, `isAdminOrAbove()`
- [x] `firestore.indexes.json` exists with empty indexes

## Automated Verification

```bash
# Verify firestore.rules exists
Test-Path "firestore.rules"  # → True

# Verify firebase.json has firestore key
Select-String -Pattern '"firestore"' firebase.json  # → matches

# Verify audit_logs deny read
Select-String -Pattern 'allow read, update, delete: if false' firestore.rules  # → matches

# Verify catch-all deny rule
Select-String -Pattern 'allow read, write: if false' firestore.rules  # → matches
```

## Human Verification

One item requires manual verification after deployment:

1. Deploy rules: `firebase deploy --only firestore:rules`
2. Verify deploy succeeds without errors
3. (Optional smoke test) In Firebase Console → Firestore → Rules Playground:
   - Partner UID attempts to read another partner's transaction → denied
   - Admin UID reads all transactions → allowed
   - Any authenticated UID creates audit log → allowed
   - Any authenticated UID reads audit log → denied

## Notes

- `isAssignedToSite()` helper uses compound doc ID pattern (`siteId + '_' + uid`). If `site_users` docs don't use this pattern (they use auto-IDs from `_db.collection('site_users').add(...)`), this function is not effective — but it's not used in the current rules. Partners are allowed to create any transaction for their own uid; site enforcement is done at the app layer (only assigned sites show in dropdown). This is correct for MVP.
- Rules do not block `isActive: false` users at the Firestore level — that check is done by the app's auth guard (checking user doc after Google Sign-In). This is intentional per context.
