import 'package:ceygo_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:ceygo_app/core/constants/countries.dart';
import 'package:ceygo_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceygo_app/features/auth/domain/models/auth_state.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final String? phone;
  const SignupScreen({super.key, this.phone});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _licenseController = TextEditingController();

  bool _agreedToTerms = false;
  String _selectedRole = 'renter';
  String _selectedIdType = 'NIC';
  String _selectedNationality = 'Sri Lankan';

  @override
  void initState() {
    super.initState();
    if (widget.phone != null) {
      _phoneController.text = widget.phone!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  String _formatPhone(String phone) {
    phone = phone.trim();
    if (phone.startsWith('0')) {
      return '+94${phone.substring(1)}';
    }
    if (!phone.startsWith('+')) {
      return '+94$phone';
    }
    return phone;
  }

  void _handleRegister() {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service'),
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).requestSignupOtp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _formatPhone(_phoneController.text),
        nationality: _selectedNationality,
        idType: _selectedIdType,
        idNumber: _idNumberController.text.trim(),
        licenseNo: _licenseController.text.trim(),
        role: _selectedRole,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next is AuthAuthenticated) {
        context.go('/home');
      } else if (next is AuthOtpSent) {
        context.push('/otp', extra: {'phone': next.phone, 'isSignup': true});
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(authProvider.notifier).resetError();
      }
    });

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          "Create an Account",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "Complete your profile to get started",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            width: 1,
                            color: const Color(0xFF2563EB).withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Role Toggle
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildRoleSelector(
                                      context: context,
                                      label: l10n.rider,
                                      icon: Icons.person,
                                      isSelected: _selectedRole == 'renter',
                                      onTap: () => setState(
                                        () => _selectedRole = 'renter',
                                      ),
                                    ),
                                    _buildRoleSelector(
                                      context: context,
                                      label: l10n.provider,
                                      icon: Icons.drive_eta_outlined,
                                      isSelected: _selectedRole == 'owner',
                                      onTap: () => setState(
                                        () => _selectedRole = 'owner',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: "Full Name",
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) =>
                                    value!.isEmpty ? 'Please enter your name' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: "Phone Number",
                                  hintText: "07X XXX XXXX",
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                keyboardType: TextInputType.phone,
                                readOnly: widget.phone != null,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  final phone = _formatPhone(value);
                                  final regex = RegExp(r'^(?:\+94|0)7[0-9]{8}$');
                                  if (!regex.hasMatch(phone)) {
                                    return 'Enter a valid Sri Lankan number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedNationality,
                                decoration: const InputDecoration(
                                  labelText: "Nationality",
                                  prefixIcon: Icon(Icons.flag_outlined),
                                ),
                                isExpanded: true,
                                menuMaxHeight: 300,
                                items: countries
                                    .map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _selectedNationality = value!);
                                },
                                validator: (value) =>
                                    value == null ? 'Please select nationality' : null,
                              ),
                              const SizedBox(height: 16),
                              // ID Type Dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedIdType,
                                decoration: const InputDecoration(
                                  labelText: "ID Type",
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'NIC',
                                    child: Text('NIC'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Passport',
                                    child: Text('Passport'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedIdType = value!);
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _idNumberController,
                                decoration: InputDecoration(
                                  labelText: _selectedIdType == 'NIC'
                                      ? "NIC Number"
                                      : "Passport Number",
                                  hintText: _selectedIdType == 'NIC'
                                      ? "199012345678 or 901234567V"
                                      : "N1234567",
                                  prefixIcon: const Icon(Icons.credit_card_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your ${_selectedIdType} number';
                                  }
                                  final regex = RegExp(
                                    r'^(?:[0-9]{9}[xXvV]|[0-9]{12}|[A-Z][0-9]{7})$',
                                  );
                                  if (!regex.hasMatch(value)) {
                                    return 'Enter a valid ${_selectedIdType} number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _licenseController,
                                decoration: const InputDecoration(
                                  labelText: "Driving License No",
                                  prefixIcon: Icon(Icons.drive_eta_outlined),
                                ),
                                validator: (value) =>
                                    value!.isEmpty
                                        ? 'Please enter your license number'
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              CheckboxListTile(
                                value: _agreedToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreedToTerms = value ?? false;
                                  });
                                },
                                title: RichText(
                                  text: TextSpan(
                                    text: 'I agree to the ',
                                    style: theme.textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                activeColor: theme.primaryColor,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Create Account",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go('/login'),
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleSelector({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
