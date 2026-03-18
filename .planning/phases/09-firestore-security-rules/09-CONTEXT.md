# Phase 9: Firestore Security Rules - Context

**Gathered:** 2026-03-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Write a `firestore.rules` file enforcing role-based access at the database level: partners read/write only their assigned site transactions; admins read/write all transactions and sites; super admin manages users; audit logs are write-only from client. Also adjust the Flutter app to handle permission-denied errors gracefully.

</domain>

<decisions>
## Implementation Decisions

### All Implementation Choices at Claude's Discretion
Pure infrastructure phase — write and deploy Firestore security rules. All implementation choices (rule logic, helper functions, condition ordering) are at Claude's discretion based on the Firestore schema already in place.

### Schema reference (already in Firestore)
- `users/{userId}` — uid, email, name, role (superAdmin/admin/partner), isActive, lastLatitude, lastLongitude, lastLocationAt
- `sites/{siteId}` — name, city, state, isActive
- `site_users/{id}` — siteId, userId, userName, userEmail, assignedAt, assignedByUserId
- `transactions/{txnId}` — createdByUserId, siteId, type, amount, paymentMethod, transactionDate, remarks, latitude, longitude, createdAt, updatedAt
- `audit_logs/{id}` — write-only from client

### Access matrix
- Partner: read own user doc; read/create transactions where createdByUserId == uid and site is assigned; no edit/delete
- Admin: read/write all transactions, sites, site_users; read all user docs; no delete users
- Super Admin: full access to users collection; inherits admin access
- Audit logs: create only (any authenticated user); no reads from client

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `firestore.rules` — new file at project root
- Firebase project already initialized (firebase_options.dart present)
- `firebase.json` may or may not exist — check before writing

### Established Patterns
- Google Sign-In auth — `request.auth.uid` is the Firebase UID
- Role stored as string in users/{uid}.role field ("superAdmin", "admin", "partner")
- site_users join table used for partner→site assignment

### Integration Points
- `firestore.rules` at project root
- `firebase.json` at project root (target: firestore)
- App-side: repository error handling may need updating for permission-denied

</code_context>

<specifics>
## Specific Ideas

No specific requirements — pure infrastructure phase.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>
