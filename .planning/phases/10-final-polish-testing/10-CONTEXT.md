# Phase 10: Final Polish & Testing - Context

**Gathered:** 2026-03-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Fix all `flutter analyze` warnings (125 issues — all warnings/infos, no errors): remove unnecessary `!` null assertions, fix `prefer_const_constructors`, resolve deprecated `withOpacity` and `activeColor` usages, fix `use_build_context_synchronously`. Verify all 33 existing tests still pass. Confirm loading/empty/error states exist on all screens.

</domain>

<decisions>
## Implementation Decisions

### All Implementation Choices at Claude's Discretion
Pure polish phase — run `dart fix --apply` to auto-fix what it can, then manually fix remaining warnings. All implementation choices at Claude's discretion.

### Known Issues from flutter analyze (125 total)
- **unnecessary_non_null_assertion** (~80 warnings): Remove `!` on non-nullable expressions across: admin_home_screen, admin_partners_screen, admin_sites_screen, admin_transactions_screen, partner_home_screen, partner_transactions_screen, add_transaction_screen, admin_shell, partner_shell, language_tile, admin_profile_screen, partner_profile_screen, transaction_detail_screen
- **prefer_const_constructors** (~20 infos): add_edit_site_screen, admin_partner_detail_screen, admin_site_detail_screen, partner_profile_screen
- **deprecated_member_use withOpacity** (~10 infos): replace `.withOpacity(x)` with `.withValues(alpha: x)` — partner_home_screen, partner_profile_screen, partner_transactions_screen, add_transaction_screen
- **deprecated_member_use activeColor** (2 infos): replace `activeColor` with `activeThumbColor` in add_edit_site_screen, add_edit_user_screen
- **dead_null_aware_expression** (1 warning): admin_transactions_screen:300
- **use_build_context_synchronously** (2 infos): add_transaction_screen:105, 108

### Test Status
All 33 tests currently pass — do not break them.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `dart fix --apply` can auto-fix unnecessary_non_null_assertion and prefer_const_constructors
- All screens already have LoadingWidget / ErrorStateWidget / EmptyStateWidget from phase 5/6

### Established Patterns
- `.withValues(alpha: x)` replaces `.withOpacity(x)`
- `activeThumbColor` replaces `activeColor` in Switch widgets
- Remove `!` from non-nullable expressions (e.g. `ref.watch(authStateProvider).value!.name!` → `ref.watch(authStateProvider).value?.name ?? ''`)

### Integration Points
- Run `dart fix --apply` first
- Then manually fix remaining deprecated API usages
- Run `flutter analyze` and `flutter test` to confirm clean

</code_context>

<specifics>
## Specific Ideas

No specific UI design changes — this is a polish/correctness phase only.

</specifics>

<deferred>
## Deferred Ideas

None — staying within phase scope.

</deferred>
