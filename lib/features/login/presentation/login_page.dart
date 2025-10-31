import 'package:flutter/material.dart';
import '../../../components/app_page_header.dart';
import '../../../components/app_theme.dart';
import '../../../components/app_button.dart';
import '../../../components/app_input.dart';
import '../../../components/language_popover.dart';
import '../../../components/error_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../shared/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;
  String? _formError;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // (removed email verified snackbar logic)
  }

  String? _validateEmail(String? value) {
    if (!_submitted) return null;
    if (value == null || value.trim().isEmpty) {
      return 'error_required_field'.tr();
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'error_invalid_email'.tr();
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (!_submitted) return null;
    if (value == null || value.trim().isEmpty) {
      return 'error_required_field'.tr();
    }
    // Add stricter password validation if needed
    return null;
  }

  void _submit() async {
    setState(() {
      _submitted = true;
      _formError = null;
      _isLoading = true;
    });
    if (_validateEmail(_emailController.text) != null ||
        _validatePassword(_passwordController.text) != null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final result = await ApiService().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      setState(() => _isLoading = false);
      if (result['token'] != null) {
        ApiService().setToken(result['token'] as String);
        Navigator.of(context).pushReplacementNamed('/home');
      } else if ((result['error'] ?? '').toString().toLowerCase().contains(
        'verify',
      )) {
        setState(() {
          _formError = 'error_email_not_verified'.tr();
        });
      } else if ((result['error'] ?? '').toString().isNotEmpty) {
        setState(() {
          _formError = result['error'].toString();
        });
      } else if ((result['message'] ?? '').toString().isNotEmpty) {
        setState(() {
          _formError = result['message'].toString();
        });
      } else {
        setState(() {
          _formError = 'error_backend_generic'.tr();
        });
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
        _formError = 'error_backend_generic'.tr();
      });
    }
  }

  void _loginWithGoogle() async {
    setState(() {
      _formError = null;
      _isLoading = true;
    });
    // TODO: Implement Google login logic
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  void _resetPassword() {
    // TODO: Route to password reset page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('reset_password_not_implemented'.tr())),
    );
  }

  Widget _header(BuildContext context) {
    return AppPageHeader(
      showLogo: true,
      parentContext: context,
      actions: [
        LanguagePopover(parentContext: context),
        const SizedBox(width: 8),
        AppButton(
          text: 'create_account'.tr(),
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed('/create-account'),
          variant: ButtonVariant.secondary,
          expanded: false,
          height: 48,
          borderRadius: AppTheme.radiusFull,
        ),
      ],
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
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_formError != null && _formError!.isNotEmpty)
                      ErrorAlert(message: _formError!),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 34,
                      child: Image.asset(
                        'assets/images/Kazi-Logo.png',
                        fit: BoxFit.contain,
                        width: 64,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'login_welcome_title'.tr(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'login_welcome_desc'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: AppTheme.inputDescription,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Inputs container
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppInput(
                          label: 'email_address'.tr(),
                          controller: _emailController,
                          prefixIcon: const Icon(
                            Icons.mail_outline,
                            color: AppTheme.inputDescription,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          errorText: _submitted
                              ? _validateEmail(_emailController.text)
                              : null,
                          description: '',
                        ),
                        const SizedBox(height: 20),
                        AppInput(
                          label: 'password'.tr(),
                          controller: _passwordController,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppTheme.inputDescription,
                          ),
                          obscureText: !_showPassword,
                          errorText: _submitted
                              ? _validatePassword(_passwordController.text)
                              : null,
                          description: '',
                          rightLabelWidget: GestureDetector(
                            onTap: () =>
                                setState(() => _showPassword = !_showPassword),
                            child: Text(
                              _showPassword
                                  ? 'hide_password'.tr()
                                  : 'show_password'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: AppTheme.inputDescription,
                                fontSize: 15,
                                letterSpacing: 0.05,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: _resetPassword,
                            child: Text(
                              'reset_password'.tr(),
                              style: const TextStyle(
                                color: AppTheme.primary,
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      text: 'login'.tr(),
                      onPressed: _isLoading ? null : _submit,
                      height: 48,
                      borderRadius: AppTheme.radiusFull,
                      icon: _isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : null,
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
                        Text(
                          'or'.tr(),
                          style: const TextStyle(
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
                      text: 'login_with_google'.tr(),
                      icon: _isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Image.asset(
                              'assets/images/google-logo.png',
                              height: 22,
                              width: 22,
                            ),
                      variant: ButtonVariant.secondary,
                      onPressed: _isLoading ? null : _loginWithGoogle,
                      borderRadius: AppTheme.radiusFull,
                      expanded: true,
                      height: 48,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
