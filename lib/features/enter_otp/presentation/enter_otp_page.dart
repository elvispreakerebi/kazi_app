import 'package:flutter/material.dart';
import '../../../components/app_page_header.dart';
import '../../../components/language_popover.dart';
import '../../../components/app_theme.dart';
import '../../../components/app_button.dart';
import '../../../components/error_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import '../../../shared/services/api_service.dart';

class EnterOtpPage extends StatefulWidget {
  final String email;
  const EnterOtpPage({super.key, required this.email});

  @override
  State<EnterOtpPage> createState() => _EnterOtpPageState();
}

class _EnterOtpPageState extends State<EnterOtpPage> {
  final int otpLength = 6;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  String? _otpError;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < otpLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onOtpChanged(int idx, String val) {
    if (val.length > 1) {
      _controllers[idx].text = val[val.length - 1];
    }
    if (val.isNotEmpty && idx < otpLength - 1) {
      _focusNodes[idx + 1].requestFocus();
    } else if (val.isEmpty && idx > 0) {
      _focusNodes[idx - 1].requestFocus();
    }
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _verifyCode() async {
    setState(() {
      _isVerifying = true;
      _otpError = null;
    });
    if (_otpCode.length < otpLength) {
      setState(() {
        _otpError = 'error_invalid_otp'.tr();
        _isVerifying = false;
      });
      return;
    }
    try {
      final result = await ApiService().verifyEmailCode(
        email: widget.email,
        code: _otpCode,
      );
      final statusCode = result['statusCode'] ?? 0;
      final errorText = (result['error'] ?? '').toString().toLowerCase();
      if (statusCode == -1) {
        setState(() {
          _otpError = 'error_network'.tr();
          _isVerifying = false;
        });
      } else if (statusCode == 400 || statusCode == 422) {
        if (errorText.contains('expired')) {
          setState(() {
            _otpError = 'error_otp_expired'.tr();
            _isVerifying = false;
          });
        } else {
          setState(() {
            _otpError = 'error_invalid_otp'.tr();
            _isVerifying = false;
          });
        }
      } else if (result['ok'] == true || result['success'] == true) {
        setState(() {
          _otpError = null;
          _isVerifying = false;
        });
        // Navigate to onboarding welcome, pass name if available
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final name = args != null && args['name'] is String
            ? args['name'] as String
            : '';
        Navigator.of(context).pushReplacementNamed(
          '/onboarding-welcome',
          arguments: {'name': name},
        );
        // Clear fields (optional)
      } else {
        setState(() {
          _otpError =
              result['error']?.toString() ?? 'error_backend_generic'.tr();
          _isVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        _otpError = 'error_backend_generic'.tr();
        _isVerifying = false;
      });
    }
  }

  void _resendCode() async {
    setState(() {
      _otpError = null;
      _isResending = true;
    });
    try {
      final result = await ApiService().resendVerification(email: widget.email);
      final statusCode = result['statusCode'] ?? 0;
      if (statusCode == -1) {
        setState(() {
          _otpError = 'error_network'.tr();
          _isResending = false;
        });
        return;
      }
      if (result['ok'] == true || result['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('otp_resent'.tr())));
        setState(() => _isResending = false);
      } else {
        setState(() {
          _otpError =
              result['error']?.toString() ?? 'error_backend_generic'.tr();
          _isResending = false;
        });
      }
    } catch (_) {
      setState(() {
        _otpError = 'error_backend_generic'.tr();
        _isResending = false;
      });
    }
  }

  Widget _otpFields() {
    final fields = <Widget>[];
    for (int i = 0; i < otpLength; i++) {
      fields.add(
        SizedBox(
          width: 46,
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              letterSpacing: 0.3,
              fontWeight: FontWeight.w600,
            ),
            keyboardType: TextInputType.number,
            maxLength: 1,
            enableInteractiveSelection: false,
            decoration: InputDecoration(
              counterText: '',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              filled: true,
              fillColor: AppTheme.inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                borderSide: BorderSide(
                  color: _otpError != null
                      ? AppTheme.inputOutlineError
                      : AppTheme.inputOutline,
                  width: 1.6,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                borderSide: BorderSide(
                  color: _otpError != null
                      ? AppTheme.inputOutlineError
                      : AppTheme.inputOutline,
                  width: 1.6,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                borderSide: BorderSide(
                  color: AppTheme.inputOutlineFocused,
                  width: 1.6,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                borderSide: BorderSide(
                  color: AppTheme.inputOutlineDisabled,
                  width: 1.6,
                ),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (val) => setState(() => _onOtpChanged(i, val)),
          ),
        ),
      );
      if ((i + 1) % 2 == 0 && i < otpLength - 1) {
        fields.add(const SizedBox(width: 8));
        fields.add(
          Text(
            '•',
            style: TextStyle(fontSize: 28, color: AppTheme.inputOutline),
          ),
        );
        fields.add(const SizedBox(width: 8));
      } else if (i < otpLength - 1) {
        fields.add(const SizedBox(width: 12));
      }
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: fields);
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
              showLogo: true,
              parentContext: context,
              actions: [LanguagePopover(parentContext: context)],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    // Section 1 texts
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'verify_email_title'.tr(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'verify_email_desc'.tr(
                            namedArgs: {'email': widget.email},
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: AppTheme.inputDescription,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Inputs section
                    Container(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _otpFields(),
                          if (_otpError != null && _otpError!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                                left: 5,
                                right: 5,
                              ),
                              child: ErrorAlert(
                                message: _otpError!,
                                margin: EdgeInsets.zero,
                                borderRadius: 8,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 14, bottom: 0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: _isResending ? null : _resendCode,
                                child: _isResending
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'resend_code'.tr(),
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          decoration: TextDecoration.underline,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Button
                    AppButton(
                      text: 'verify_email_button'.tr(),
                      onPressed: _isVerifying ? null : _verifyCode,
                      height: 48,
                      borderRadius: AppTheme.radiusFull,
                      icon: _isVerifying
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
