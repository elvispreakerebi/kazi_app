import 'package:flutter/material.dart';
import '../../../components/app_page_header.dart';
import '../../../components/language_popover.dart';
import '../../../components/app_theme.dart';
import '../../../components/app_button.dart';
import '../../../components/AppInput.dart';
import '../../../components/AppCheckbox.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _termsChecked = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              AppPageHeader(
                showLogo: false,
                parentContext: context,
                actions: [
                  LanguagePopover(parentContext: context),
                  const SizedBox(width: 12),
                  AppButton(
                    text: 'Log in',
                    onPressed: () {},
                    variant: ButtonVariant.secondary,
                    expanded: false,
                    height: 40,
                    borderRadius: AppTheme.radiusFull,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // 3 main vertical containers with 32px gap between
              // 1. Logo container
              Center(
                child: SizedBox(
                  height: 44,
                  child: Image.asset(
                    'assets/images/Kazi-Logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // 2. Hero text container
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reach every of your student with Kazi.',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create account to get started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: AppTheme.inputDescription,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // 3. Form container with 4 sections and 32px gap
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Fields section (20px gap)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppInput(
                            label: 'Full name',
                            controller: _nameController,
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: AppTheme.inputDescription,
                            ),
                            description: '',
                          ),
                          const SizedBox(height: 20),
                          AppInput(
                            label: 'Email address',
                            controller: _emailController,
                            prefixIcon: const Icon(
                              Icons.mail_outline,
                              color: AppTheme.inputDescription,
                            ),
                            description: '',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          AppInput(
                            label: 'Password',
                            controller: _passwordController,
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppTheme.inputDescription,
                            ),
                            obscureText: !_showPassword,
                            description: '',
                            suffixIcon: GestureDetector(
                              onTap: () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                              child: Text(
                                _showPassword
                                    ? 'Hide password'
                                    : 'Show password',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppTheme.inputDescription,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppCheckbox(
                            value: _termsChecked,
                            onChanged: (v) => setState(() => _termsChecked = v),
                            label:
                                'By creating an account you agree to our Terms of Service and Privacy Policy.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // 2. Create account button
                      AppButton(
                        text: 'Create account',
                        variant: ButtonVariant.primary,
                        onPressed: () {},
                        borderRadius: AppTheme.radiusFull,
                      ),
                      const SizedBox(height: 32),
                      // 3. Divider
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              height: 1,
                              color: AppTheme.inputOutline,
                            ),
                          ),
                          const Text(
                            'Or',
                            style: TextStyle(
                              color: AppTheme.inputDescription,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              height: 1,
                              color: AppTheme.inputOutline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // 4. Google signup button
                      AppButton(
                        text: 'Create account with Google',
                        icon: Image.asset(
                          'assets/images/google-logo.png',
                          height: 22,
                          width: 22,
                        ),
                        variant: ButtonVariant.secondary,
                        onPressed: () {},
                        borderRadius: AppTheme.radiusFull,
                        expanded: true,
                        height: 56,
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
  }
}
