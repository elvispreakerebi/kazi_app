import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'dart:math';
import '../../../components/app_page_header.dart';
import '../../../components/language_popover.dart';
import '../../../components/app_theme.dart';
import '../../../components/app_button.dart';
import '../../../components/app_input.dart';
import '../../../components/app_checkbox.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import '../../../shared/services/api_service.dart';
import '../../../components/error_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final bool _isLoading = false;
  String? _formError;
  bool _submitted = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;

  // Google OAuth constants
  static const String androidClientId =
      '943087778314-iqotm7kuon08kouuadtm0arapstisc7s.apps.googleusercontent.com';
  static const String androidRedirectUri =
      'com.googleusercontent.apps.943087778314-iqotm7kuon08kouuadtm0arapstisc7s:/oauthredirect';
  static const String iosClientId =
      '943087778314-9e75n0oo41q7a4tmdhafiuv7u9p26gsq.apps.googleusercontent.com';
  static const String iosRedirectUri =
      'com.googleusercontent.apps.943087778314-9e75n0oo41q7a4tmdhafiuv7u9p26gsq:/oauthredirect';

  String get googleClientId => Platform.isIOS ? iosClientId : androidClientId;
  String get googleRedirectUri =>
      Platform.isIOS ? iosRedirectUri : androidRedirectUri;

  static const AuthorizationServiceConfiguration googleServiceConfig =
      AuthorizationServiceConfiguration(
        authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
        tokenEndpoint: 'https://oauth2.googleapis.com/token',
      );
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (!_submitted) return null;
    if (value == null || value.trim().isEmpty) {
      return 'error_required_field'.tr();
    }
    return null;
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
    if (value.length < 8) {
      return 'error_password_length'.tr();
    }
    return null;
  }

  bool _validateAllFieldsForSubmit() {
    final valid =
        (_nameController.text.trim().isNotEmpty) &&
        (_emailController.text.trim().isNotEmpty &&
            _emailController.text.contains('@')) &&
        (_passwordController.text.length >= 8) &&
        _termsChecked;
    setState(() {
      if (!_termsChecked) {
        _formError = 'error_terms_required'.tr();
      } else {
        _formError = null;
      }
    });
    return valid;
  }

  Future<void> _register() async {
    setState(() {
      _submitted = true;
      _formError = null;
      _isLoadingEmail = true;
    });
    if (!_validateAllFieldsForSubmit()) {
      setState(() {
        _isLoadingEmail = false;
      });
      return;
    }
    try {
      final result = await ApiService().createAccount(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final statusCode = result['statusCode'] ?? 0;
      final errText = (result['error'] ?? '').toString().toLowerCase();
      if (statusCode == 409) {
        setState(() => _formError = 'error_email_taken'.tr());
      } else if (statusCode == -1) {
        setState(() => _formError = 'error_network'.tr());
      } else if (statusCode == 422 || statusCode == 400) {
        if (errText.contains('email')) {
          setState(() => _formError = 'error_invalid_email'.tr());
        } else if (errText.contains('password')) {
          setState(() => _formError = 'error_password_length'.tr());
        } else {
          setState(() => _formError = 'error_backend_generic'.tr());
        }
      } else if (errText.isNotEmpty) {
        setState(() => _formError = result['error'].toString());
      } else {
        setState(() {
          _formError = null;
          _submitted = false;
        });
        // Persist JWT if returned (anticipating follow-up verification/auto-login)
        if (result['token'] != null) {
          ApiService().setToken(result['token'] as String);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', result['token'] as String);
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('success_created'.tr())));
        Navigator.of(context).pushReplacementNamed(
          '/enter-otp',
          arguments: {'email': _emailController.text.trim()},
        );
        // Optionally: clear form or navigate
      }
    } catch (_) {
      setState(() {
        _formError = 'error_network'.tr();
      });
    } finally {
      setState(() {
        _isLoadingEmail = false;
      });
    }
  }

  Future<void> _googleRegister() async {
    setState(() {
      _formError = null;
      _isLoadingGoogle = true;
    });
    try {
      final AuthorizationTokenResponse googleResult = await _appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              googleClientId,
              googleRedirectUri,
              serviceConfiguration: googleServiceConfig,
              scopes: ['openid', 'email', 'profile'],
            ),
          );
      if (googleResult.idToken == null) {
        setState(() {
          _formError = 'error_google_login'.tr();
          _isLoadingGoogle = false;
        });
        return;
      }
      final result = await ApiService().googleIdTokenLogin(
        idToken: googleResult.idToken!,
        name: _nameController.text.trim(),
      );
      if (result['error'] != null) {
        setState(() => _formError = result['error'].toString());
      } else if (result['message'] != null && result['token'] == null) {
        setState(() => _formError = result['message'].toString());
      } else {
        setState(() {
          _formError = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('success_created'.tr())));
        // navigate, or clear form, or show onboarding complete
      }
    } catch (e) {
      setState(() {
        _formError = 'error_google_login'.tr();
      });
    } finally {
      setState(() {
        _isLoadingGoogle = false;
      });
    }
  }

  Widget _backButton(BuildContext context) {
    final isIOS =
        Theme.of(context).platform == TargetPlatform.iOS || Platform.isIOS;
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
          child: Icon(
            isIOS ? Icons.chevron_left : Icons.arrow_back,
            color: AppTheme.textDark,
            size: isIOS ? 22 : 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                  text: 'login'.tr(),
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/login'),
                  variant: ButtonVariant.secondary,
                  expanded: false,
                  height: 48,
                  borderRadius: AppTheme.radiusFull,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: max(MediaQuery.of(context).viewInsets.bottom, 24),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'welcome_title'.tr(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'create_account_to_get_started'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: AppTheme.inputDescription,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    AppInput(
                      label: 'full_name'.tr(),
                      controller: _nameController,
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: AppTheme.inputDescription,
                      ),
                      errorText: _submitted
                          ? _validateName(_nameController.text)
                          : null,
                      description: '',
                    ),
                    const SizedBox(height: 20),
                    AppInput(
                      label: 'email_address'.tr(),
                      controller: _emailController,
                      prefixIcon: const Icon(
                        Icons.mail_outline,
                        color: AppTheme.inputDescription,
                      ),
                      errorText: _submitted
                          ? _validateEmail(_emailController.text)
                          : null,
                      description: '',
                      keyboardType: TextInputType.emailAddress,
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
                    const SizedBox(height: 20),
                    AppCheckbox(
                      value: _termsChecked,
                      onChanged: (v) => setState(() => _termsChecked = v),
                      label: 'by_creating_account_agree'.tr(
                        namedArgs: {
                          'terms': 'terms_of_service'.tr(),
                          'privacy': 'privacy_policy'.tr(),
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      text: 'create_account'.tr(),
                      variant: ButtonVariant.primary,
                      onPressed: _isLoadingEmail ? null : _register,
                      borderRadius: AppTheme.radiusFull,
                      height: 48,
                      icon: _isLoadingEmail
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
                      text: 'create_account_with_google'.tr(),
                      icon: _isLoadingGoogle
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
                      onPressed: _isLoadingGoogle ? null : _googleRegister,
                      borderRadius: AppTheme.radiusFull,
                      expanded: true,
                      height: 48,
                    ),
                    const SizedBox(height: 10),
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
