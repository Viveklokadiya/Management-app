# Phase 5: Partner MVP Screens — Context

**Gathered:** 2026-03-17
**Status:** Ready for planning

<domain>
## Phase Boundary

Build all 5 partner-facing screens end-to-end: Home dashboard, Transaction list, Add/Edit transaction form, Transaction detail, and Profile. Partner shell (bottom nav) already exists from Phase 3 — this phase replaces the placeholder routes with real screens connected to the Phase 4 repository layer.

</domain>

<decisions>
## Implementation Decisions

### Home Dashboard Layout
- Two summary cards side-by-side: Today Income (₹) and Today Expense (₹) using existing `AmountSummaryCard`
- Show last 5 recent transactions below summary
- Two quick action buttons below cards: "+ Income" and "+ Expense" (pre-fills transaction type)
- Dynamic time-based greeting: "Good morning/afternoon/evening, [Name] 👋"

### Transaction List & Filters
- Transaction card: large amount + `TransactionTypeBadge` + site name + formatted date + `PaymentMethodChip` — uses existing chips from Phase 1
- Horizontal scrollable filter chips row (Date range, Site, Type, Payment method)
- Default filter: current month
- `EmptyStateWidget` when no transactions with "Add Transaction" action button

### Add Transaction Form
- Full-width segmented control (Income | Expense) at top, color-coded green/red
- Large numeric field with ₹ prefix + formatted display below entry
- Site dropdown populated from `getAssignedSites(userId)` — partner's assigned sites only
- Inline validation errors below each field on submit attempt

### Claude's Discretion
- Transaction list uses `StreamBuilder` over `getTransactionsForSite` or `getTransactionsByUser` depending on context
- Date formatting uses existing `DateFormat` from intl package
- Profile screen shows user info, last location timestamp, and logout — sign-out via `authStateProvider.notifier.signOut()`
- Transaction detail is read-only for partners (no edit/delete buttons)
- Navigation: Add Transaction as FAB on Home and List screens; pushes named route

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `AmountSummaryCard` — ready for income/expense summary cards on Home
- `TransactionTypeBadge` — income/expense badge for transaction cards
- `PaymentMethodChip` — payment method display chip
- `SectionHeader` — section titles with optional action link ("See all")
- `AppCard` — base card container for list items
- `AppButton` — primary/outline/danger variants
- `AppTextField` — styled text input
- `LoadingWidget`, `EmptyStateWidget`, `ErrorStateWidget` — all states handled
- `CurrencyFormatter.format()` and `.formatCompact()` — ₹ formatting

### Established Patterns
- Riverpod `ConsumerWidget` / `ConsumerStatefulWidget` for state
- Async state via `AsyncValue.when(data, loading, error)`
- `ref.watch(authStateProvider).value` for current user
- `ref.watch(transactionRepositoryProvider)` / `ref.watch(siteRepositoryProvider)` for data
- `context.go()` / `context.push()` for navigation via go_router
- `AppColors`, `AppTextStyles` for all styling — no inline styles

### Integration Points
- Routes defined in `AppRoutes` — `partnerHome`, `partnerTransactions`, `partnerProfile`
- Add Transaction is a new route: `AppRoutes.addTransaction` = `/partner/add-transaction`
- Transaction Detail: `AppRoutes.transactionDetail` = `/partner/transaction/:id`
- Repository providers from `lib/core/providers/repository_providers.dart`
- Auth provider from `lib/features/auth/presentation/providers/auth_provider.dart`

</code_context>

<specifics>
## Specific Ideas

- Income is green (`AppColors.income`), Expense is red (`AppColors.expense`) — consistent with existing `TransactionTypeBadge`
- Amounts always displayed with `CurrencyFormatter.format()` — never raw numbers
- Partner sees only their assigned sites in the Add Transaction dropdown
- Profile has Logout button using `AppButtonVariant.danger`
- FAB uses `AppColors.primary` with `Icons.add`

</specifics>

<deferred>
## Deferred Ideas

- Editing existing transactions — admin-only, deferred to Phase 6
- Push notifications for new assignments — out of MVP scope
- Export transactions to PDF/CSV — deferred to Phase 10

</deferred>
