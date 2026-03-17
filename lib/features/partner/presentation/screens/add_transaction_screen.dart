import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../sites/domain/models/site_model.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../transactions/domain/models/transaction_model.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this.initialType});
  final TransactionType? initialType;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();

  late TransactionType _type;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  String? _selectedSiteId;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  List<SiteModel> _sites = [];
  bool _loadingSites = true;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? TransactionType.expense;
    _loadSites();
  }

  Future<void> _loadSites() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    List<SiteModel> sites;
    if (user.role == UserRole.admin || user.role == UserRole.superAdmin) {
      sites = await ref.read(siteRepositoryProvider).getAllSites().first;
    } else {
      sites = await ref.read(siteRepositoryProvider).getAssignedSites(user.id);
    }
    if (mounted) {
      setState(() {
        _sites = sites;
        _loadingSites = false;
        if (sites.length == 1) _selectedSiteId = sites.first.id;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSiteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectSite)),
      );
      return;
    }
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() => _isSubmitting = true);
    try {
      final amountRupees = double.parse(
          _amountController.text.replaceAll(',', ''));
      final txn = TransactionModel(
        id: '',
        siteId: _selectedSiteId!,
        createdByUserId: user.id,
        createdByName: user.name,
        type: _type,
        amountPaise: (amountRupees * 100).round(),
        paymentMethod: _paymentMethod,
        remarks: _remarksController.text.trim().isEmpty
            ? null
            : _remarksController.text.trim(),
        transactionDate: _selectedDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref
          .read(transactionRepositoryProvider)
          .createTransaction(txn);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorPrefix}$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isIncome = _type == TransactionType.income;
    final typeColor = isIncome ? AppColors.income : AppColors.expense;
    final amountText = _amountController.text.replaceAll(',', '');
    final parsedAmount = double.tryParse(amountText) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 2,
        title: Text(
          isIncome ? l10n.addIncome : l10n.addExpense,
          style: AppTextStyles.headlineSmall
              .copyWith(color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Type Toggle ──────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: l10n.expense,
                        selected: _type == TransactionType.expense,
                        color: AppColors.expense,
                        onTap: () => setState(
                            () => _type = TransactionType.expense),
                      ),
                    ),
                    Expanded(
                      child: _TypeButton(
                        label: l10n.income,
                        selected: _type == TransactionType.income,
                        color: AppColors.income,
                        onTap: () => setState(
                            () => _type = TransactionType.income),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── Amount ───────────────────────────────────────────
              _FieldLabel(l10n.amount),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                style: AppTextStyles.amountMedium,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Text('₹',
                        style: AppTextStyles.headlineMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 18),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.amountIsRequired;
                  final n = double.tryParse(v.replaceAll(',', ''));
                  if (n == null || n <= 0) return l10n.enterValidAmount;
                  return null;
                },
              ),
              if (amountText.isNotEmpty && parsedAmount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    CurrencyFormatter.format(parsedAmount),
                    style: AppTextStyles.labelMedium
                        .copyWith(color: typeColor),
                  ),
                ),
              const SizedBox(height: 20),

              // ─── Site ─────────────────────────────────────────────
              _FieldLabel(l10n.siteLocation),
              const SizedBox(height: 6),
              _loadingSites
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedSiteId,
                      isExpanded: true,
                      decoration: _dropdownDecoration(l10n.selectSite),
                      items: _sites
                          .map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name,
                                    style: AppTextStyles.bodyMedium),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedSiteId = v),
                      validator: (v) =>
                          v == null ? l10n.pleaseSelectSite : null,
                    ),
              const SizedBox(height: 20),

              // ─── Payment Method ───────────────────────────────────
              _FieldLabel(l10n.paymentMethod),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3,
                children: PaymentMethod.values
                    .map((m) => _PaymentMethodTile(
                          method: m,
                          selected: _paymentMethod == m,
                          onTap: () =>
                              setState(() => _paymentMethod = m),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),

              // ─── Date ─────────────────────────────────────────────
              _FieldLabel(l10n.date),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: Theme.of(ctx).colorScheme.copyWith(
                            primary: AppColors.accent),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('d MMMM yyyy')
                              .format(_selectedDate),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      const Icon(Icons.calendar_today_outlined,
                          size: 18,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ─── Remarks ──────────────────────────────────────────
              _FieldLabel(l10n.remarksOptional),
              const SizedBox(height: 6),
              TextFormField(
                controller: _remarksController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: l10n.whatWasThisFor,
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textHint),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              // Space for the footer button
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // ─── Sticky Save Button ─────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            border: const Border(top: BorderSide(color: AppColors.border)),
          ),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isSubmitting ? null : () => _submit(context),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    l10n.saveTransaction,
                    style: AppTextStyles.labelLarge
                        .copyWith(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected ? color : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (method) {
      PaymentMethod.cash => l10n.cash,
      PaymentMethod.upi => l10n.upi,
      PaymentMethod.bank => l10n.bank,
      PaymentMethod.other => l10n.other,
    };
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.labelMedium
            .copyWith(color: AppColors.textSecondary),
      );
}
