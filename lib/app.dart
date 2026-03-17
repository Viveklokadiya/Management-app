import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/providers/locale_provider.dart';
import 'core/widgets/app_button.dart';
import 'core/widgets/app_card.dart';
import 'core/widgets/amount_display.dart';
import 'core/utils/currency_formatter.dart';

class ShreeGirirajApp extends ConsumerWidget {
  const ShreeGirirajApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Shree Giriraj Engineering',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: appSupportedLocales,
      home: const _PlaceholderHome(),
    );
  }
}

/// Temporary placeholder — replaced by go_router + auth in Phase 2
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shree Giriraj Engineering'),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phase 1 — Design System Preview',
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 24),

            // Income / Expense summary cards
            const Row(
              children: [
                Expanded(
                  child: AmountSummaryCard(
                    label: 'Today Income',
                    amount: 1234567,
                    type: TransactionType.income,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AmountSummaryCard(
                    label: 'Today Expense',
                    amount: 456789,
                    type: TransactionType.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Currency formatter demo
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Indian Currency Formatter',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(1234567),
                    style: AppTextStyles.amountMedium,
                  ),
                  Text(
                    CurrencyFormatter.formatCompact(1500000),
                    style: AppTextStyles.amountSmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Button variants
            const AppButton(label: 'Primary Button', onPressed: null),
            const SizedBox(height: 8),
            const AppButton(
                label: 'Loading...', onPressed: null, isLoading: true),
            const SizedBox(height: 8),
            const AppButton(
              label: 'Outline',
              onPressed: null,
              variant: AppButtonVariant.outline,
            ),
            const SizedBox(height: 8),
            const AppButton(
              label: 'Danger',
              onPressed: null,
              variant: AppButtonVariant.danger,
            ),
          ],
        ),
      ),
    );
  }
}
