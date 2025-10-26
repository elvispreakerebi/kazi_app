import 'package:flutter/material.dart';
import '../../../components/app_page_header.dart';
import '../../../components/language_popover.dart';
import '../../../components/app_theme.dart';
import '../../../components/app_button.dart';
import '../../../components/app_input.dart';
import '../../../components/app_checkbox.dart';

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

  Widget _backButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(100),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.secondary,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.chevron_left,
            color: AppTheme.textDark,
            size: 22,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppPageHeader(
              showLogo: false,
              parentContext: context,
              backButton: _backButton(context),
              actions: [
                LanguagePopover(parentContext: context),
                AppButton(
                  text: 'Log in',
                  onPressed: () {},
                  variant: ButtonVariant.secondary,
                  expanded: false,
                  height: 48,
                  borderRadius: AppTheme.radiusFull,
                ),
              ],
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 28),
                            // Kazi Logo, left aligned, smaller
                            SizedBox(
                              height: 34,
                              child: Image.asset(
                                'assets/images/Kazi-Logo.png',
                                fit: BoxFit.contain,
                                width: 64,
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Hero text container left-aligned
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Reach every of your student with Kazi',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Create account to get started',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: AppTheme.inputDescription,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
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
                              rightLabelWidget: GestureDetector(
                                onTap: () => setState(
                                  () => _showPassword = !_showPassword,
                                ),
                                child: Text(
                                  _showPassword
                                      ? 'Hide password'
                                      : 'Show password',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: AppTheme.inputDescription,
                                    fontSize: 15,
                                    letterSpacing: 0.05,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            AppCheckbox(
                              value: _termsChecked,
                              onChanged: (v) =>
                                  setState(() => _termsChecked = v),
                              label:
                                  'By creating an account you agree to our Terms of Service and Privacy Policy.',
                            ),
                            const SizedBox(height: 28),
                            AppButton(
                              text: 'Create account',
                              variant: ButtonVariant.primary,
                              onPressed: () {},
                              borderRadius: AppTheme.radiusFull,
                              height: 48,
                            ),
                            const SizedBox(height: 28),
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
                            const SizedBox(height: 28),
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
                              height: 48,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
