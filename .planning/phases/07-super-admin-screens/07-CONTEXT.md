# Phase 7: Super Admin Screens - Context

**Gathered:** 2026-03-17
**Status:** Ready for planning

<domain>
## Phase Boundary

Two screens visible only to Super Admin: Users List (all users with role-colour chips, active/inactive badge, tab filter) and Add/Edit User (name, email, role dropdown, site checkbox list, active toggle). Create Firestore doc directly — Google sign-in matches by email.

</domain>

<decisions>
## Implementation Decisions

### Screen Architecture
- Add/Edit User launched via: FAB → push route; 3-dot menu per card → push same route with user pre-filled
- Full push route (outside admin shell) for Add/Edit User — same pattern as AddTransactionScreen
- SuperAdminUsersScreen lives inside admin shell on /admin/users route (already in AdminShell)

### Data & Firestore
- Add User creates users/{auto-id} Firestore doc; email is the matching key for Google Sign-In
- Role dropdown options: Partner, Admin, Super Admin (all 3 UserRole values)
- Assigned sites: checkbox list fetched from site stream — stored in site_users subcollection

### UI Design (from Designs/users_management_super_admin + Designs/add_edit_user)
- Users list: sticky header, tab bar (All / Admins / Partners), user cards with avatar initial, role badge (orange=superAdmin, orange-light=admin, grey=partner), active/inactive badge, 3-dot menu
- Add/Edit: back button header, User Profile section (name + email), Access & Permissions section (role dropdown + site checkboxes), User Status toggle, sticky footer (Cancel + Save)

### Claude's Discretion
- 3-dot menu shows: Edit, Toggle Active — no delete (data integrity)
- Email is read-only on Edit mode (required for Google Sign-In matching)
- allUsersStreamProvider queries all users regardless of role

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- AppColors, AppTextStyles, CurrencyFormatter from core/theme
- LoadingWidget, ErrorStateWidget, EmptyStateWidget from core/widgets/state_widgets.dart
- allPartnersStreamProvider pattern → model for allUsersStreamProvider
- siteRepositoryProvider.getAllSites() stream for site assignment checkboxes
- UserRole enum in app_user.dart: superAdmin, admin, partner

### Established Patterns
- ConsumerStatefulWidget + ref.watch(streamProvider) for list screens
- Context.push() for full-screen routes outside shell
- Firestore direct write via firestoreProvider

### Integration Points
- app_router.dart: replace SuperAdminUsersPlaceholder with real screen; add /admin/add-edit-user route
- routes.dart: add superAdminAddUser constant
- repository_providers.dart: add allUsersStreamProvider

</code_context>

<specifics>
## Specific Ideas

- Use colour-coded role badges: Super Admin = solid primary (orange), Admin = primary/10 bg + primary text, Partner = grey
- Inactive user card has reduced opacity (0.8) and greyscale avatar (matching design)
- Use initials avatar (first letter of name) — no network images

</specifics>

<deferred>
## Deferred Ideas

- Site assignment on add/edit user — include checkbox list but write to site_users collection
- Delete user permanently — out of scope (toggle isActive instead)

</deferred>
