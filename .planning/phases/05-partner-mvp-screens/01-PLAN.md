---
description: "Add new partner routes to AppRoutes + app_router, build PartnerHomeScreen and PartnerProfileScreen"
dependencies: []
gap_closure: false
wave: 1
---

# Phase 5: Partner MVP Screens — Plan 1 (Home & Profile Screens + Route Updates)

## 1. Add New Partner Routes
<task>
<read_first>
- lib/core/router/routes.dart
- lib/core/router/app_router.dart
</read_first>
<action>
Add two new route constants to `lib/core/router/routes.dart`:

```dart
// Add inside AppRoutes class:
static const addTransaction = '/partner/add-transaction';
static const transactionDetail = '/partner/transaction/:id';
```

Then in `lib/core/router/app_router.dart`, add these two routes inside the **partner ShellRoute** routes list (after `partnerProfile`):

```dart
GoRoute(
  path: AppRoutes.addTransaction,
  builder: (c, s) => const AddTransactionScreen(),
),
GoRoute(
  path: '/partner/transaction/:id',
  builder: (c, s) => TransactionDetailScreen(
    transactionId: s.pathParameters['id']!,
  ),
),
```

These routes are NOT part of the shell (no bottom nav) but appear on top — use `context.push()` to navigate to them.

Add imports for `AddTransactionScreen` and `TransactionDetailScreen` at the top of `app_router.dart`:
```dart
import '../../features/partner/presentation/screens/add_transaction_screen.dart';
import '../../features/partner/presentation/screens/transaction_detail_screen.dart';
```

Also update: replace the `PartnerHomePlaceholder`, `PartnerTransactionsPlaceholder`, `PartnerProfilePlaceholder` references in `app_router.dart` with real screen imports:
```dart
import '../../features/partner/presentation/screens/partner_home_screen.dart';
import '../../features/partner/presentation/screens/partner_transactions_screen.dart';
import '../../features/partner/presentation/screens/partner_profile_screen.dart';
```

And replace the placeholder builder calls:
```dart
// partner shell routes:
GoRoute(path: AppRoutes.partnerHome, builder: (c, s) => const PartnerHomeScreen()),
GoRoute(path: AppRoutes.partnerTransactions, builder: (c, s) => const PartnerTransactionsScreen()),
GoRoute(path: AppRoutes.partnerProfile, builder: (c, s) => const PartnerProfileScreen()),
```

Remove the placeholder classes from `app_router.dart` for partner screens only (keep admin placeholders).

Run `dart run build_runner build -d` after updating the router since `app_router.g.dart` needs regeneration.
</action>
<acceptance_criteria>
- `AppRoutes.addTransaction` and `AppRoutes.transactionDetail` constants exist in `routes.dart`
- `app_router.dart` partner shell now uses real screen imports (not placeholder classes)
- `addTransaction` and `transactionDetail` routes registered in the partner ShellRoute
- `build_runner` runs without errors
</acceptance_criteria>
</task>

## 2. PartnerHomeScreen
<task>
<read_first>
- lib/core/router/routes.dart
- lib/core/theme/app_colors.dart
- lib/core/theme/app_text_styles.dart
- lib/core/widgets/amount_display.dart
- lib/core/widgets/state_widgets.dart
- lib/core/widgets/chips.dart
- lib/core/providers/repository_providers.dart
- lib/features/auth/presentation/providers/auth_provider.dart
- lib/features/transactions/domain/models/transaction_model.dart
- lib/features/sites/domain/models/site_model.dart
</read_first>
<action>
Create `lib/features/partner/presentation/screens/partner_home_screen.dart`.

This is a `ConsumerStatefulWidget` because we need to fetch multiple async items (sites and transactions).

Screen structure:
```
Scaffold
  AppBar: title "Home", no back arrow, backgroundColor: AppColors.surface
  body: RefreshIndicator → SingleChildScrollView → Column:
    ├── _GreetingHeader (user name + time-based greeting)
    ├── SizedBox(16)
    ├── _SummaryCards (Today Income + Today Expense side by side)
    ├── SizedBox(24)
    ├── _QuickActions (+ Income | + Expense buttons)
    ├── SizedBox(24)
    └── _RecentTransactions (SectionHeader + last 5 items OR EmptyStateWidget)
  floatingActionButton: FAB → context.push(AppRoutes.addTransaction)
```

**_GreetingHeader:**
```dart
// Determine greeting based on hour
final hour = DateTime.now().hour;
final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
// Display: "$greeting, ${user.name.split(' ').first} 👋"
// Subtitle: today's date formatted as "Monday, 17 March"
```

**_SummaryCards:** (Row with two Expanded children)
Calculate `todayIncome` and `todayExpense` from transactions where `transactionDate` matches today's date.
Use the existing `AmountSummaryCard` widget:
```dart
AmountSummaryCard(label: 'Today Income', amount: todayIncomeRupees, type: TransactionType.income)
AmountSummaryCard(label: 'Today Expense', amount: todayExpenseRupees, type: TransactionType.expense)
```

**_QuickActions:** (Row of two Expanded AppButton widgets)
```dart
AppButton(label: '+ Income', onPressed: () => context.push(AppRoutes.addTransaction, extra: TransactionType.income), variant: AppButtonVariant.outline)
AppButton(label: '+ Expense', onPressed: () => context.push(AppRoutes.addTransaction, extra: TransactionType.expense), variant: AppButtonVariant.outline)
```

**_RecentTransactions:** SectionHeader('Recent Transactions', action: () => context.go(AppRoutes.partnerTransactions), actionLabel: 'See all')
Then a ListView.separated with 5 items, each being a `_TransactionCard` (see below).

**_TransactionCard:** (reusable private widget, same structure used in Phase 5 Plan 2)
```dart
AppCard(
  onTap: () => context.push('/partner/transaction/${txn.id}'),
  child: Row(
    children: [
      // Left: type icon in colored circle
      Container(width: 40, height: 40, decoration: BoxDecoration(
        color: txn.type == TransactionType.income ? AppColors.incomeLight : AppColors.expenseLight,
        shape: BoxShape.circle)),
        icon: income/expense arrow icon
      // Middle: site name + date
      Expanded(child: Column(
        Text(txn.siteName or 'Unknown site'),
        Text(formatted date)
      ))
      // Right: amount + payment chip
      Column(
        Text(CurrencyFormatter.format(txn.amountRupees), color: income/expense color),
        PaymentMethodChip(method: txn.paymentMethod.name)
      )
    ]
  )
)
```

Data loading: use `ref.watch(authStateProvider).value` to get the current user, then `ref.watch(transactionRepositoryProvider).getTransactionsByUser(userId)` as a `StreamBuilder`. Show `LoadingWidget` while loading, `ErrorStateWidget` on error.

Do NOT need to filter by site here — `getTransactionsByUser` already gets all transactions across the partner's sites.
</action>
<acceptance_criteria>
- `lib/features/partner/presentation/screens/partner_home_screen.dart` exists
- Shows time-sensitive greeting with user's first name
- Two side-by-side summary cards (Today Income, Today Expense) calculated from today's transactions
- Quick action buttons (+ Income, + Expense) that push to add transaction with pre-filled type
- Recent transactions list (last 5) in reverse date order
- FAB navigates to add transaction
- Loading / empty / error states all handled
</acceptance_criteria>
</task>

## 3. PartnerProfileScreen
<task>
<read_first>
- lib/core/theme/app_colors.dart
- lib/core/theme/app_text_styles.dart
- lib/core/widgets/app_button.dart
- lib/features/auth/presentation/providers/auth_provider.dart
- lib/features/auth/domain/models/app_user.dart
</read_first>
<action>
Create `lib/features/partner/presentation/screens/partner_profile_screen.dart`.

Simple `ConsumerWidget`:
```
Scaffold
  AppBar: title "Profile"
  body: SingleChildScrollView → Column → Padding(16):
    ├── _AvatarSection (initials avatar + name + email)
    ├── SizedBox(24)
    ├── _InfoSection (AppCard with ListTiles: name, email, phone, role)
    ├── SizedBox(16)
    ├── _LocationSection (AppCard: last location updated at timestamp OR "Never")
    ├── SizedBox(24)
    └── AppButton(label: 'Sign Out', variant: AppButtonVariant.danger, onPressed: signOut)
```

**_AvatarSection:**
```dart
CircleAvatar(
  radius: 40,
  backgroundColor: AppColors.primaryLight,
  child: Text(
    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
    style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary),
  ),
)
Text(user.name, style: AppTextStyles.headlineMedium)
Text(user.email, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))
```

**_InfoSection:** AppCard with ListTiles (no onTap, just display):
- Phone: user.phone ?? 'Not provided'
- Role: 'Partner'

**_LocationSection:**
```dart
// Format lastLocationAt if not null
final locationText = user.lastLocationAt != null
    ? 'Last updated ${DateFormat('d MMM yyyy, h:mm a').format(user.lastLocationAt!)}'
    : 'Location not yet captured';
```

**Sign Out button:**
```dart
AppButton(
  label: 'Sign Out',
  variant: AppButtonVariant.danger,
  icon: Icons.logout,
  isLoading: isSigningOut,
  onPressed: () async {
    setState(() => isSigningOut = true);
    await ref.read(authStateProvider.notifier).signOut();
  },
)
```

Use `ConsumerStatefulWidget` to track `isSigningOut` state.
</action>
<acceptance_criteria>
- `lib/features/partner/presentation/screens/partner_profile_screen.dart` exists
- Shows initials avatar, name, email
- Shows role, phone (or "Not provided")
- Shows last location timestamp or "Location not yet captured"
- Sign Out button with danger style and loading state
- Sign out calls `authStateProvider.notifier.signOut()`
</acceptance_criteria>
</task>
