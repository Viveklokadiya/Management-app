---
description: "PartnerTransactionsScreen with filters and AddTransactionScreen form"
dependencies: ["01-PLAN.md"]
gap_closure: false
wave: 2
---

# Phase 5: Partner MVP Screens — Plan 2 (Transactions List & Add Transaction)

## 1. PartnerTransactionsScreen
<task>
<read_first>
- lib/core/widgets/chips.dart
- lib/core/widgets/state_widgets.dart
- lib/core/widgets/app_card.dart
- lib/core/theme/app_colors.dart
- lib/core/providers/repository_providers.dart
- lib/features/transactions/domain/models/transaction_model.dart
- lib/features/sites/domain/models/site_model.dart
- lib/features/auth/presentation/providers/auth_provider.dart
</read_first>
<action>
Create `lib/features/partner/presentation/screens/partner_transactions_screen.dart`.

`ConsumerStatefulWidget` with filter state:

```dart
class _FilterState {
  DateTimeRange? dateRange;   // null = current month
  String? siteId;             // null = all sites
  TransactionType? type;      // null = all
  PaymentMethod? paymentMethod; // null = all
}
```

Screen structure:
```
Scaffold
  AppBar: title "Transactions"
  body: Column:
    ├── _FilterBar (horizontal ScrollView of filter chips)
    ├── Divider
    └── Expanded → StreamBuilder → _TransactionList / states
  floatingActionButton: FAB → context.push(AppRoutes.addTransaction)
```

**_FilterBar:** SingleChildScrollView(scrollDirection: Axis.horizontal) containing a Row of `FilterChip` widgets styled to match the design system:
1. Date chip: shows "This Month" (default) or custom range → opens `showDateRangePicker`
2. Site chip: shows "All Sites" or site name → opens bottom sheet with site list from `getAssignedSites`
3. Type chip: shows "All" / "Income" / "Expense" → tap cycles through
4. Payment chip: shows "All" / "Cash" / "UPI" / "Bank" / "Other" → bottom sheet picker

Filter chips style:
```dart
FilterChip(
  label: Text(label, style: AppTextStyles.labelMedium),
  selected: isActive,
  selectedColor: AppColors.primaryLight,
  backgroundColor: AppColors.surface,
  side: BorderSide(color: isActive ? AppColors.primary : AppColors.border),
  onSelected: (_) => onTap(),
)
```

**StreamBuilder data:** `ref.watch(transactionRepositoryProvider).getTransactionsByUser(userId)` — then filter the list client-side based on the active `_FilterState`.

Apply filters locally (already fetched via stream):
```dart
List<TransactionModel> _apply(List<TransactionModel> all, _FilterState f) {
  var list = all;
  if (f.dateRange != null) {
    list = list.where((t) =>
      !t.transactionDate.isBefore(f.dateRange!.start) &&
      !t.transactionDate.isAfter(f.dateRange!.end.add(const Duration(days: 1)))
    ).toList();
  } else {
    // default: current month
    final now = DateTime.now();
    list = list.where((t) =>
      t.transactionDate.year == now.year && t.transactionDate.month == now.month
    ).toList();
  }
  if (f.siteId != null) list = list.where((t) => t.siteId == f.siteId).toList();
  if (f.type != null) list = list.where((t) => t.type == f.type).toList();
  if (f.paymentMethod != null) list = list.where((t) => t.paymentMethod == f.paymentMethod).toList();
  return list;
}
```

**_TransactionList:** `ListView.separated` with `_TransactionListCard` items (same card design as Plan 1 `_TransactionCard`). When list is empty after filtering, show `EmptyStateWidget(title: 'No transactions', message: 'Try adjusting your filters', icon: Icons.receipt_long_outlined)`.

**Running totals header** above the list:
```dart
Row(
  children: [
    _TotalBadge(label: 'Filtered Income', amount: filteredIncomeTotal, color: AppColors.income),
    _TotalBadge(label: 'Filtered Expense', amount: filteredExpenseTotal, color: AppColors.expense),
  ],
)
```
</action>
<acceptance_criteria>
- `lib/features/partner/presentation/screens/partner_transactions_screen.dart` exists
- Filter bar has Date, Site, Type, Payment chips
- Default filter: current month
- Transactions filtered client-side from stream
- Running totals shown above list
- Empty state shown when no transactions match filters
- FAB navigates to add transaction
</acceptance_criteria>
</task>

## 2. AddTransactionScreen
<task>
<read_first>
- lib/core/widgets/app_button.dart
- lib/core/widgets/app_text_field.dart
- lib/core/theme/app_colors.dart
- lib/core/theme/app_text_styles.dart
- lib/core/providers/repository_providers.dart
- lib/features/transactions/domain/models/transaction_model.dart
- lib/features/sites/domain/models/site_model.dart
- lib/features/auth/presentation/providers/auth_provider.dart
</read_first>
<action>
Create `lib/features/partner/presentation/screens/add_transaction_screen.dart`.

`ConsumerStatefulWidget`. Receives optional `TransactionType? initialType` from `GoRouterState.extra` (set by quick action buttons on Home).

Form fields:
1. **Type toggle** (Income | Expense) — custom segmented control
2. **Amount** — `AppTextField (keyboardType: numeric)`, ₹ prefix icon, formatted display below
3. **Site** — `DropdownButtonFormField` populated from `getAssignedSites(userId)`
4. **Payment method** — `DropdownButtonFormField` with Cash, UPI, Bank, Other options
5. **Date** — `TextFormField` with calendar icon; opens `showDatePicker`, defaults to today
6. **Remarks** — `AppTextField(maxLines: 3, optional)`

**Type toggle widget:**
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border),
  ),
  child: Row(
    children: [
      Expanded(child: _TypeButton(label: 'Income', isSelected: type == income, color: AppColors.income)),
      Expanded(child: _TypeButton(label: 'Expense', isSelected: type == expense, color: AppColors.expense)),
    ],
  ),
)
```

**Formatted amount display:**
```dart
// Below the amount field:
if (amountText.isNotEmpty)
  Text(
    CurrencyFormatter.format(double.tryParse(amountText) ?? 0),
    style: AppTextStyles.amountMedium.copyWith(
      color: type == TransactionType.income ? AppColors.income : AppColors.expense,
    ),
  )
```

**Save logic:**
```dart
Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);
  try {
    final txn = TransactionModel(
      id: '',
      siteId: _selectedSiteId!,
      createdByUserId: user.id,
      createdByName: user.name,
      type: _type,
      amountPaise: (double.parse(_amountController.text) * 100).round(),
      paymentMethod: _paymentMethod,
      remarks: _remarksController.text.isEmpty ? null : _remarksController.text,
      transactionDate: _selectedDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ref.read(transactionRepositoryProvider).createTransaction(txn);
    if (mounted) context.pop();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

**Validation rules:**
- Amount: required, must be > 0
- Site: required (non-null dropdown selection)
- Payment method: required
- Date: required (defaults to today so always valid)
- Remarks: optional

Screen structure:
```
Scaffold
  AppBar: title "Add Transaction" (or "Add Income" / "Add Expense" based on type)
  body: Form → SingleChildScrollView → Column(padding: 16):
    ├── _TypeToggle
    ├── SizedBox(16)
    ├── AppTextField(label: 'Amount', prefix: '₹', numeric)
    ├──  CurrencyFormatter display (conditional)
    ├── SizedBox(16)
    ├── DropdownButtonFormField (Site)
    ├── SizedBox(16)
    ├── DropdownButtonFormField (Payment Method)
    ├── SizedBox(16)
    ├── _DateField (tap to pick date)
    ├── SizedBox(16)
    ├── AppTextField(label: 'Remarks (optional)', maxLines: 3)
    ├── SizedBox(24)
    └── AppButton(label: 'Save Transaction', isLoading: _isLoading, onPressed: _save)
```
</action>
<acceptance_criteria>
- `lib/features/partner/presentation/screens/add_transaction_screen.dart` exists
- Type toggle (Income/Expense) at top, color-coded
- Amount field with ₹ prefix, formatted display below input
- Site dropdown only shows partner's assigned sites
- Payment method dropdown (Cash, UPI, Bank, Other)
- Date picker defaulting to today
- Optional remarks field
- Saves via `transactionRepositoryProvider.createTransaction()` and navigates back
- Loading state on save button
- Inline validation errors on required fields
</acceptance_criteria>
</task>
