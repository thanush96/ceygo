import 'dart:convert';

import 'package:ceygo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _Bank {
  final int id;
  final String name;
  const _Bank({required this.id, required this.name});
}

class _Branch {
  final int id;
  final String name;
  const _Branch({required this.id, required this.name});
}

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();

  List<_Bank> _banks = [];
  Map<int, List<_Branch>> _branchesMap = {};

  _Bank? _selectedBank;
  _Branch? _selectedBranch;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final banksRaw =
        await rootBundle.loadString('assets/data/banks.json');
    final branchesRaw =
        await rootBundle.loadString('assets/data/branches.json');

    final List<dynamic> banksJson = json.decode(banksRaw) as List<dynamic>;
    final Map<String, dynamic> branchesJson =
        json.decode(branchesRaw) as Map<String, dynamic>;

    final banks = banksJson
        .map((b) => _Bank(
              id: int.parse(b['ID'].toString()),
              name: b['name'] as String,
            ))
        .toList();

    final branchesMap = <int, List<_Branch>>{};
    branchesJson.forEach((key, value) {
      final bankId = int.parse(key);
      final list = (value as List<dynamic>)
          .map((br) => _Branch(
                id: int.parse(br['ID'].toString()),
                name: br['name'] as String,
              ))
          .toList();
      branchesMap[bankId] = list;
    });

    if (mounted) {
      setState(() {
        _banks = banks;
        _branchesMap = branchesMap;
        _loading = false;
      });
    }
  }

  List<_Branch> get _branches =>
      _selectedBank != null ? (_branchesMap[_selectedBank!.id] ?? []) : [];

  void _onBankChanged(_Bank? bank) {
    setState(() {
      _selectedBank = bank;
      _selectedBranch = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    // TODO: persist via provider / API
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment method saved')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header illustration ──────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 28, horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.75),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.account_balance,
                                  color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bank Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Add your bank details to receive payments',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Form Card ────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bank name dropdown
                            _SectionLabel(label: 'Bank Name'),
                            const SizedBox(height: 8),
                            _BankDropdown(
                              banks: _banks,
                              value: _selectedBank,
                              onChanged: _onBankChanged,
                            ),

                            const SizedBox(height: 20),

                            // Branch dropdown
                            _SectionLabel(label: 'Branch'),
                            const SizedBox(height: 8),
                            _BranchDropdown(
                              branches: _branches,
                              value: _selectedBranch,
                              enabled: _selectedBank != null,
                              onChanged: (b) =>
                                  setState(() => _selectedBranch = b),
                            ),

                            const SizedBox(height: 20),

                            // Full name
                            _SectionLabel(label: 'Account Holder Name'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _fullNameCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: _inputDecoration(
                                hint: 'Enter full name as per bank records',
                                icon: Icons.person_outline,
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Please enter account holder name'
                                      : null,
                            ),

                            const SizedBox(height: 20),

                            // Account number
                            _SectionLabel(label: 'Account Number'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _accountCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: _inputDecoration(
                                hint: 'Enter account number',
                                icon: Icons.credit_card_outlined,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter account number';
                                }
                                if (v.trim().length < 6) {
                                  return 'Account number must be at least 6 digits';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Save button ──────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Payment Method',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
    prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    filled: true,
    fillColor: const Color(0xFFF5F7FA),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
          const BorderSide(color: AppTheme.primaryColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

class _BankDropdown extends StatelessWidget {
  final List<_Bank> banks;
  final _Bank? value;
  final ValueChanged<_Bank?> onChanged;

  const _BankDropdown({
    required this.banks,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<_Bank>(
      value: value,
      isExpanded: true,
      decoration: _inputDecoration(
        hint: 'Select bank',
        icon: Icons.account_balance_outlined,
      ),
      hint: Text(
        'Select bank',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
      items: banks
          .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Please select a bank' : null,
    );
  }
}

class _BranchDropdown extends StatelessWidget {
  final List<_Branch> branches;
  final _Branch? value;
  final bool enabled;
  final ValueChanged<_Branch?> onChanged;

  const _BranchDropdown({
    required this.branches,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<_Branch>(
      value: value,
      isExpanded: true,
      decoration: _inputDecoration(
        hint: enabled ? 'Select branch' : 'Select a bank first',
        icon: Icons.location_on_outlined,
      ),
      hint: Text(
        enabled ? 'Select branch' : 'Select a bank first',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
      items: enabled
          ? branches
              .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
              .toList()
          : [],
      onChanged: enabled ? onChanged : null,
      validator: (v) =>
          (enabled && v == null) ? 'Please select a branch' : null,
    );
  }
}
