---
description: "TransactionDetailScreen (read-only for partner)"
dependencies: ["01-PLAN.md", "02-PLAN.md"]
gap_closure: false
wave: 3
---

# Phase 5: Partner MVP Screens — Plan 3 (Transaction Detail Screen)

## 1. TransactionDetailScreen
<task>
<read_first>
- lib/core/widgets/app_card.dart
- lib/core/widgets/chips.dart
- lib/core/widgets/state_widgets.dart
- lib/core/theme/app_colors.dart
- lib/core/theme/app_text_styles.dart
- lib/core/providers/repository_providers.dart
- lib/features/transactions/domain/models/transaction_model.dart
- lib/features/auth/presentation/providers/auth_provider.dart
</read_first>
<action>
Create `lib/features/partner/presentation/screens/transaction_detail_screen.dart`.

This screen is shared (partner sees it read-only; admin will see edit/delete buttons in Phase 6). Accept `transactionId` and `siteId` as constructor params. Read both from the route params:

Constructor:
```dart
const TransactionDetailScreen({super.key, required this.transactionId, required this.siteId});
```

Note: `siteId` is passed via `GoRouterState.extra` (Map) when pushing the route. Fallback: fetch from `getTransactionById` using the collectionGroup approach if siteId unavailable.

`ConsumerWidget` or `ConsumerStatefulWidget`.

**Data:** Use a `FutureProvider.family` or `StreamBuilder` to load the transaction:
```dart
final txnFuture = ref.watch(
  _txnDetailProvider(TransactionDetailArgs(siteId: siteId, txnId: transactionId))
);
```

For simplicity, use a plain `FutureBuilder` without provider:
```dart
final future = ref.read(transactionRepositoryProvider)
    .getTransactionById(siteId: siteId, transactionId: transactionId);
```

Screen structure:
```
Scaffold
  AppBar: title "Transaction Detail", back button
  body: FutureBuilder → loading / error / data:
    data → SingleChildScrollView → Column(padding: 16):
      ├── _AmountHero (large amount display with type color + badge)
      ├── SizedBox(16)
      ├── _DetailCard (site, payment method, date, created by, remarks)
      ├── SizedBox(16)
      └── _MetaCard (createdAt, updatedAt timestamps)
```

**_AmountHero:**
```dart
AppCard(
  child: Column(
    children: [
      TransactionTypeBadge(isIncome: txn.type == TransactionType.income),
      SizedBox(16),
      Text(
        CurrencyFormatter.format(txn.amountRupees),
        style: AppTextStyles.amountLarge.copyWith(
          color: txn.type == TransactionType.income ? AppColors.income : AppColors.expense,
        ),
      ),
      Text(DateFormat('EEEE, d MMMM yyyy').format(txn.transactionDate),
           style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
    ],
  ),
)
```

**_DetailCard:** AppCard with `_DetailRow` widgets (label + value pairs):
```dart
_DetailRow('Site', txn.siteId),    // ideally resolved to site name — simplification: show ID for now, Phase 6 can improve
_DetailRow('Payment', txn.paymentMethod.name.toUpperCase()),
_DetailRow('Recorded by', txn.createdByName),
if (txn.remarks != null) _DetailRow('Remarks', txn.remarks!),
if (txn.latitude != null) _DetailRow('Location', '${txn.latitude!.toStringAsFixed(4)}, ${txn.longitude!.toStringAsFixed(4)}'),
```

**_DetailRow widget:**
```dart
class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary))),
        Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
      ],
    ),
  );
}
```

**_MetaCard:** Timestamps in AppCard:
```dart
_DetailRow('Created', DateFormat('d MMM yyyy, h:mm a').format(txn.createdAt)),
_DetailRow('Updated', DateFormat('d MMM yyyy, h:mm a').format(txn.updatedAt)),
```

**No edit/delete buttons** — partner is read-only. Admin edit buttons deferred to Phase 6.

Handle the case where `siteId` is not available from route params by checking `GoRouterState.extra`:
```dart
// In app_router.dart, when pushing to detail:
// context.push('/partner/transaction/${txn.id}', extra: {'siteId': txn.siteId});
// In screen: final siteId = (GoRouterState.of(context).extra as Map?)['siteId'] ?? '';
```

Update the `GoRoute` for `transactionDetail` in `app_router.dart` to pass siteId via `extra` and extract it:
```dart
GoRoute(
  path: '/partner/transaction/:id',
  builder: (c, s) => TransactionDetailScreen(
    transactionId: s.pathParameters['id']!,
    siteId: (s.extra as Map<String, dynamic>?)?['siteId'] ?? '',
  ),
),
```
</action>
<acceptance_criteria>
- `lib/features/partner/presentation/screens/transaction_detail_screen.dart` exists
- Shows large amount hero with income/expense color and badge
- Shows site, payment method, date, recorded-by, remarks, location (if available)
- Shows createdAt and updatedAt timestamps
- Loading and error states handled
- No edit/delete buttons (read-only for partner)
- `siteId` passed via `GoRouterState.extra` for `getTransactionById` call
</acceptance_criteria>
</task>
