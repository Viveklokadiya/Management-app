# Phase 6: Admin Screens - Context

**Gathered:** 2026-03-17
**Status:** Complete — implemented directly from Designs folder

<domain>
## Phase Boundary

All admin-facing screens: Admin Home dashboard, Admin Transactions list (with tab filters), Admin Sites list (search + status filter), Admin Partners list (search), Admin Profile. Connected to Firestore via new admin providers (allPartnersStreamProvider, allTransactionsStreamProvider using collectionGroup).

</domain>

<decisions>
## Implementation Decisions

### Screen Architecture
- AdminShell already existed with 5 bottom-nav tabs (Home, Partners, Sites, Transactions, Profile) + conditional Users for superAdmin
- All 5 screens implemented as ConsumerWidget or ConsumerStatefulWidget
- Screens replace placeholder widgets in app_router.dart

### Data Providers
- allTransactionsStreamProvider: uses collectionGroup('transactions') — no orderBy to avoid index requirement, sorted client-side
- allPartnersStreamProvider: queries users collection where role=partner, sorted client-side
- siteRepositoryProvider.getAllSites() used for Sites screen, orderBy removed client-side

### Design Fidelity
- Matched Designs/admin_home_dashboard/code.html — orange Net Balance card, 2-column income/expense grid, quick actions, recent list
- Matched Designs/admin_transaction_list/code.html — tab filter, monthly balance card, grouped-by-date list
- Matched Designs/sites_list/code.html — search bar, filter chips, site cards with status badges
- Matched Designs/partners_list/code.html — search bar, partner cards with avatar/phone/location

### Claude's Discretion
- Client-side sorting chosen over Firestore orderBy to avoid composite index requirements
- Partner online/offline status inferred from lastLocationAt within 30 minutes

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- AppColors, AppTextStyles, CurrencyFormatter used throughout
- LoadingWidget, ErrorStateWidget, EmptyStateWidget for state coverage
- SiteRepository.getAllSites() stream reused directly

### Established Patterns
- ConsumerWidget + ref.watch(streamProvider) pattern from partner screens
- StreamBuilder for site data (uses repository not provider)
- GoRouter navigation with context.go() and context.push()

### Integration Points
- app_router.dart: admin shell routes updated to real screens
- repository_providers.dart: 2 new providers added
- admin_shell.dart: unchanged — already had correct nav structure

</code_context>

<specifics>
## Specific Ideas

- Use existing Designs/ folder HTML mockups as design reference (user explicitly requested this)
- FAB on AdminTransactionsScreen navigates to addTransaction route

</specifics>

<deferred>
## Deferred Ideas

- Site detail screen (tabs: Partners, Transactions) — Phase 6 roadmap mentions it but not in Designs folder, deferred
- Partner detail screen (tabs: Overview, Transactions, Location) — deferred
- Transaction edit/delete from admin — deferred to post-Phase 6

</deferred>
