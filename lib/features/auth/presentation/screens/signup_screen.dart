import 'package:ceygo_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:ceygo_app/core/providers/auth_provider.dart';
import 'package:ceygo_app/core/widgets/error_dialog.dart';
import 'package:ceygo_app/core/widgets/loading_overlay.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _agreedToTerms = false;
  String _selectedRole = 'Rider'; // Default role

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   leading: IconButton(
        //     icon: const Icon(Icons.arrow_back_ios_new),
        //     onPressed: () => context.pop(),
        //   ),
        //   title: Text(l10n.signup),
        // ),
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
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          "Create an Account",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                Colors
                                    .black, // Changed to white for better contrast on gradient
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "We're glad to have you here! Let's get started",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            width: 1,
                            color: Color(0xFF2563EB).withOpacity(0.3),
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
                              // User/Driver Toggle
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),

                                // "rider": "Rider",
                                // "provider": "Provider",
                                child: Row(
                                  children: [
                                    _buildRoleSelector(
                                      context: context,
                                      label: l10n.rider,
                                      icon: Icons.person,
                                      isSelected: _selectedRole == 'Rider',
                                      onTap:
                                          () => setState(
                                            () => _selectedRole = 'Rider',
                                          ),
                                    ),
                                    _buildRoleSelector(
                                      context: context,
                                      label: l10n.provider,
                                      icon: Icons.drive_eta_outlined,
                                      isSelected: _selectedRole == 'Provider',
                                      onTap:
                                          () => setState(
                                            () => _selectedRole = 'Provider',
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),
                              TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                  labelText: "First Name",
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator:
                                    (value) =>
                                        value!.isEmpty
                                            ? 'Please enter your first name'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  labelText: "Last Name",
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator:
                                    (value) =>
                                        value!.isEmpty
                                            ? 'Please enter your last name'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: "Email (Optional)",
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: "Phone Number",
                                  hintText: "+94771234567",
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                keyboardType: TextInputType.phone,
                                validator:
                                    (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      if (!value.startsWith('+')) {
                                        return 'Phone number must start with +';
                                      }
                                      return null;
                                    },
                              ),

                              const SizedBox(height: 20),
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
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                activeColor: theme.primaryColor,
                              ),

                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () async {
                                  if (!_agreedToTerms) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please agree to the Terms of Service',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      // Register user
                                      await ref.read(authProvider.notifier).register(
                                        phoneNumber: _phoneController.text.trim(),
                                        firstName: _firstNameController.text.trim(),
                                        lastName: _lastNameController.text.trim(),
                                        email: _emailController.text.trim().isEmpty 
                                            ? null 
                                            : _emailController.text.trim(),
                                      );
                                      
                                      // Send OTP
                                      await ref.read(authProvider.notifier).sendOtp(_phoneController.text.trim());
                                      
                                      if (mounted) {
                                        context.push('/otp', extra: {'phone': _phoneController.text.trim()});
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        showErrorDialog(
                                          context,
                                          title: 'Registration Failed',
                                          message: e.toString().replaceAll('Exception: ', ''),
                                        );
                                      }
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  "Create Account",
                                  style: const TextStyle(
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
                                    onTap: () => context.pop(),
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
            boxShadow:
                isSelected
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
