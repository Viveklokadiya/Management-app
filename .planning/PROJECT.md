# Shree Giriraj Engineering — Transaction Management App

## What This Is

An internal Android Flutter app for Shree Giriraj Engineering (a steel construction/vendor company). It enables site handlers (partners) and administrators to record, monitor, and manage site-based financial transactions. This is not an inventory system, accounting ERP, or material tracker — it is a focused, lightweight transaction management tool for field operations.

## Core Value

Partners and admins can record and view site-based money transactions accurately, with role-appropriate access, wherever they are on site.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Google Sign-In with Firebase Authentication
- [ ] Pre-approved user whitelist check via Firestore
- [ ] Role-based access: Super Admin, Admin, Partner
- [ ] Transaction creation (income/expense) with site, payment method, remarks
- [ ] Partner can only create/view transactions for assigned sites
- [ ] Admin can view/edit/delete all transactions
- [ ] Super Admin can manage all users and roles
- [ ] Site management (create, edit, deactivate)
- [ ] User management (create, edit, deactivate) — Super Admin only
- [ ] Location capture on app open and transaction creation (no background tracking)
- [ ] Audit log for create/update/delete actions on transactions
- [ ] Indian currency formatting (₹)
- [ ] Partner Home with summary cards and quick actions
- [ ] Admin Home with dashboard summary
- [ ] Transaction list with filters (date range, site, type, payment method)
- [ ] Partner detail with tabs: overview, transactions, location
- [ ] Site detail with tabs: overview, partners, transactions
- [ ] Profile screen with logout
- [ ] Splash screen with auth routing
- [ ] Firestore security rules enforcing role-based access

### Out of Scope

- Attachment/file upload — deferred to Phase 2
- Push notifications — Phase 2
- Reports/exports — Phase 2
- Background location tracking — explicit exclusion (privacy concern)
- Inventory or material tracking — not this app
- Accounting ERP features — not this app
- iOS support — Android only for MVP
- Web support — Android only for MVP

## Context

- Platform: Android only (Flutter)
- Backend: Firebase (Auth + Firestore)
- Figma design assets are available in `Designs/` folder
- Design system: Deep navy/blue primary, white/light grey backgrounds, rounded cards and inputs, high readability for financial values
- State management: Riverpod (preferred)
- Routing: go_router
- Architecture: Clean architecture — presentation / domain / data layers with repository pattern
- Location: Geolocator package
- Currency: Indian formatting with ₹ symbol
- This is an internal tool — performance and correctness matter more than viral growth features
- No CI/CD pipeline required for MVP

## Constraints

- **Platform**: Android-only Flutter — iOS build not required
- **Auth**: Google Sign-In only — no email/password, no magic links
- **Data**: Cloud Firestore only — no separate REST API
- **Design**: Light theme only — no dark mode in MVP
- **MVP scope**: No reports, no notifications, no file attachments
- **Location**: Foreground only, no background tracking
- **State management**: Riverpod — do not mix with other solutions

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Riverpod for state management | Compile-safe, testable, well-suited for reactive Firebase streams | — Pending |
| go_router for navigation | Declarative, supports role-based guard redirects, deep linking ready | — Pending |
| Clean architecture (3 layers) | Separation of concerns, testable business logic | — Pending |
| Firestore as primary database | Already in Firebase ecosystem, real-time capable, offline support | — Pending |
| Google Sign-In only | Simplest secure auth for internal tool, SSO-ready | — Pending |
| Repository pattern | Abstracts data source, allows future migration if needed | — Pending |
| No background location | Privacy best practice, MVP simplicity | — Pending |

---
*Last updated: 2026-03-17 after initialization*
