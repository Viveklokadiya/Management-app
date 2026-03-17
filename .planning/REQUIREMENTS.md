# Requirements: Shree Giriraj Engineering — Transaction Management App

**Defined:** 2026-03-17
**Core Value:** Partners and admins can record and view site-based money transactions accurately, with role-appropriate access, wherever they are on site.

---

## v1 Requirements

### Authentication & Access (AUTH)

- [ ] **AUTH-01**: User can sign in via Google Sign-In button on the login screen
- [ ] **AUTH-02**: After Google auth, app checks Firestore `users` collection for email match
- [ ] **AUTH-03**: If user email is not found or `isActive` is false, user sees a friendly "Unauthorized" message and cannot proceed
- [ ] **AUTH-04**: Authenticated user's session persists across app restarts (Firebase Auth handles this)
- [ ] **AUTH-05**: User can log out from the Profile screen
- [ ] **AUTH-06**: Splash screen detects auth state and routes to Login or Home appropriately

### Role-Based Access Control (RBAC)

- [ ] **RBAC-01**: Partner role can only view and create transactions for their assigned sites
- [ ] **RBAC-02**: Partner role cannot see global partner list or manage users
- [ ] **RBAC-03**: Admin role can view, create, edit, and delete all transactions
- [ ] **RBAC-04**: Admin role can view all partners and partner details
- [ ] **RBAC-05**: Admin role can manage sites (create, edit, deactivate)
- [ ] **RBAC-06**: Admin role cannot manage admin or super admin user records
- [ ] **RBAC-07**: Super Admin role has all Admin permissions plus user management
- [ ] **RBAC-08**: Super Admin can create, edit, and deactivate any user including admins
- [ ] **RBAC-09**: Navigation and available screens adapt to the user's role

### Transactions (TXN)

- [ ] **TXN-01**: User can create a transaction with: amount, type (income/expense), site, payment method (cash/upi/bank/other), date, optional remarks
- [ ] **TXN-02**: Transaction amount is displayed with Indian currency formatting (₹ with Indian number system)
- [ ] **TXN-03**: Partner's site dropdown is limited to their assigned sites
- [ ] **TXN-04**: Admin/Super Admin site dropdown shows all active sites
- [ ] **TXN-05**: Transaction list screen shows card-based list with amount, type, site, date, payment method
- [ ] **TXN-06**: Transaction list supports filters: date range, site, type (income/expense), payment method
- [ ] **TXN-07**: Transaction detail screen shows all fields including captured location summary and createdAt
- [ ] **TXN-08**: Admin and Super Admin can edit an existing transaction
- [ ] **TXN-09**: Admin and Super Admin can delete a transaction
- [ ] **TXN-10**: All create/edit/delete actions on transactions generate an audit log entry

### Sites (SITE)

- [ ] **SITE-01**: Admin/Super Admin can view all sites in a list with name, address, partner count
- [ ] **SITE-02**: Admin/Super Admin can create a new site with: name, address, optional lat/lng
- [ ] **SITE-03**: Admin/Super Admin can edit site details
- [ ] **SITE-04**: Admin/Super Admin can deactivate a site
- [ ] **SITE-05**: Site detail screen has tabs: Overview, Partners (assigned), Transactions

### Users & Partners (USER)

- [ ] **USER-01**: Super Admin can view all users in a list with name, email, role chip, active/inactive status
- [ ] **USER-02**: Super Admin can add a new user with: name, email, phone, role, active status
- [ ] **USER-03**: Super Admin can edit any user's details including role
- [ ] **USER-04**: Super Admin can deactivate/reactivate a user
- [ ] **USER-05**: Admin/Super Admin can view all partners in a list with avatar, name, assigned site count, last location updated
- [ ] **USER-06**: Admin/Super Admin can view partner detail with tabs: Overview, Transactions, Location
- [ ] **USER-07**: Partner detail > Overview shows profile info, assigned sites, transaction stats
- [ ] **USER-08**: Partner detail > Transactions shows all transactions for that partner with filters
- [ ] **USER-09**: Partner detail > Location shows last known location and timestamp

### Location (LOC)

- [ ] **LOC-01**: App captures user's device location when the app opens (foreground only)
- [ ] **LOC-02**: App captures user's device location when a transaction is created
- [ ] **LOC-03**: Captured location (lat/lng + timestamp) is stored in user's Firestore document
- [ ] **LOC-04**: Transaction document stores the location at time of creation
- [ ] **LOC-05**: App handles location permission denial gracefully (proceeds without location)

### Audit Logs (AUDIT)

- [ ] **AUDIT-01**: Every transaction create action writes an audit log with: action=create, recordId, newData, actionBy, actionAt
- [ ] **AUDIT-02**: Every transaction update action writes an audit log with: action=update, recordId, oldData, newData, actionBy, actionAt
- [ ] **AUDIT-03**: Every transaction delete action writes an audit log with: action=delete, recordId, oldData, actionBy, actionAt

### Dashboard & Home (DASH)

- [ ] **DASH-01**: Partner Home shows: today's income, today's expense, total transaction count, recent transactions
- [ ] **DASH-02**: Partner Home has quick action buttons: Add Income, Add Expense
- [ ] **DASH-03**: Admin Home shows: today's income, today's expense, net balance, total transactions today, active sites count
- [ ] **DASH-04**: Admin Home shows recent transactions list
- [ ] **DASH-05**: Both home screens use summary cards with Indian currency formatting

### Profile (PROF)

- [ ] **PROF-01**: Profile screen shows: name, email, phone, profile image (avatar), last location updated timestamp
- [ ] **PROF-02**: Profile screen has a Logout button
- [ ] **PROF-03**: Profile screen has a Privacy Policy placeholder link
- [ ] **PROF-04**: Profile screen has a Language selector to switch between English, Hindi, and Gujarati

### Localization (LANG)

- [ ] **LANG-01**: App supports English, Hindi (हिन्दी), and Gujarati (ગુજરાતી) languages
- [ ] **LANG-02**: User's selected language is persisted across app restarts (stored in SharedPreferences)
- [ ] **LANG-03**: All UI strings are externalized via ARB files — no hardcoded English strings in widgets

### Firestore Security (SEC)

- [ ] **SEC-01**: Only authenticated, approved users can read their own user document
- [ ] **SEC-02**: Partners can only read site documents for their assigned sites
- [ ] **SEC-03**: Partners can only read/write their own transactions
- [ ] **SEC-04**: Admins can read/write all site and transaction documents
- [ ] **SEC-05**: Only Super Admins can write to admin/super admin user records
- [ ] **SEC-06**: Audit logs are write-only from client (no client reads)

### Architecture & Technical (TECH)

- [ ] **TECH-01**: App is structured with presentation / domain / data layers
- [ ] **TECH-02**: Firebase repositories abstract all Firestore access
- [ ] **TECH-03**: Riverpod used consistently for state management
- [ ] **TECH-04**: go_router used for navigation with role-based route guards
- [ ] **TECH-05**: Centralized theming: deep navy primary, white/light grey background, rounded UI
- [ ] **TECH-06**: Reusable widget library: cards, inputs, buttons, loading/empty/error states
- [ ] **TECH-07**: Form validation on all input screens
- [ ] **TECH-08**: Business logic is unit-testable (pure Dart, no Flutter deps in domain layer)

---

## v2 Requirements

### Notifications
- **NOTF-01**: Push notifications for new transactions on assigned sites
- **NOTF-02**: Admin alert when a large transaction is created

### Reports & Exports
- **REPT-01**: Admin can export transaction report as PDF or CSV
- **REPT-02**: Date-range and site-filtered summary report

### File Attachments
- **ATCH-01**: User can attach a photo receipt to a transaction

### Advanced Features
- **ADV-01**: Dashboard charts (income vs expense over time)
- **ADV-02**: Multi-language support (Hindi)
- **ADV-03**: Offline transaction creation with sync on reconnect

---

## Out of Scope

| Feature | Reason |
|---------|--------|
| iOS build | Android-only MVP; iOS later |
| Web build | Android-only MVP |
| Dark mode | Light theme only per spec |
| Background location | Privacy concern, explicit exclusion |
| Inventory/material tracking | Different product domain |
| Accounting ERP | Different product domain |
| Email/password auth | Google Sign-In only per spec |
| File attachments (MVP) | Phase 2 |
| Push notifications (MVP) | Phase 2 |
| Reports/exports (MVP) | Phase 2 |
| Multi-language (was v2) | Promoted to v1 — Hindi, English, Gujarati required from start |

---

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01–06 | Phase 2 | Complete |
| RBAC-01–09 | Phase 3 | Pending |
| TXN-01–10 | Phase 5 | Pending |
| SITE-01–05 | Phase 6 | Pending |
| USER-01–09 | Phase 7 | Pending |
| LOC-01–05 | Phase 8 | Pending |
| AUDIT-01–03 | Phase 5 | Pending |
| DASH-01–05 | Phase 5–6 | Pending |
| PROF-01–04 | Phase 5 | Pending |
| LANG-01–03 | Phase 1 | Pending |
| SEC-01–06 | Phase 9 | Pending |
| TECH-01–08 | Phase 1–4 | Pending |

**Coverage:**
- v1 requirements: 58 total
- Mapped to phases: 58
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-17*
*Last updated: 2026-03-17 after initial definition*
