import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:convex_flutter/convex_flutter.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'dart:io' show Platform;

late ConvexClient convexClient;

// --- Set to your deployed Convex Auth backend (site URL, no trailing slash)
const convexBackend =
    'https://kindly-crow-554.convex.site'; // CHANGE to your prod Convex .site URL when needed

/// -- REPLACE with your real Google OAuth values for the app --
// -- Update these with YOUR app's correct client IDs --
const String androidClientId =
    '943087778314-iqotm7kuon08kouuadtm0arapstisc7s.apps.googleusercontent.com';
const String androidRedirectUri =
    'com.googleusercontent.apps.943087778314-iqotm7kuon08kouuadtm0arapstisc7s:/oauthredirect';
const String iosClientId =
    '943087778314-9e75n0oo41q7a4tmdhafiuv7u9p26gsq.apps.googleusercontent.com';
const String iosRedirectUri =
    'com.googleusercontent.apps.943087778314-9e75n0oo41q7a4tmdhafiuv7u9p26gsq:/oauthredirect';

// Choose at runtime
final String googleClientId = Platform.isIOS ? iosClientId : androidClientId;
final String googleRedirectUri = Platform.isIOS
    ? iosRedirectUri
    : androidRedirectUri;

const AuthorizationServiceConfiguration googleServiceConfig =
    AuthorizationServiceConfiguration(
      authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
      tokenEndpoint: 'https://oauth2.googleapis.com/token',
    );

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  convexClient = await ConvexClient.init(
    deploymentUrl: convexBackend,
    clientId: "kazi-app-v1.0-demo1",
  );
  runApp(const KaziApp());
}

class KaziApp extends StatefulWidget {
  const KaziApp({super.key});
  @override
  State<KaziApp> createState() => _KaziAppState();
}

class _KaziAppState extends State<KaziApp> {
  String? _registeredEmail;
  String? _jwt;
  String? _googleError;
  StreamSubscription? _sub;
  String _view = 'register'; // 'register' | 'login' | 'verify'
  String? _resetEmail;
  String? _resetCode;
  String? _resetSuccessMessage;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void onRegistered(String email) => setState(() {
    _view = 'verify';
    _registeredEmail = email;
  });
  void onGoToLogin() => setState(() {
    _view = 'login';
    _registeredEmail = null;
  });
  void onBackToRegister() => setState(() {
    _view = 'register';
    _registeredEmail = null;
  });
  void onGoToVerification(String email) => setState(() {
    _view = 'verify';
    _registeredEmail = email;
  });
  void onLoggedIn(String jwt) => setState(() {
    _jwt = jwt;
    _googleError = null;
  });
  void logout() => setState(() => _jwt = null);

  Future<void> _initDeepLinks() async {
    _sub = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null && uri.scheme == 'kazi' && uri.host == 'auth-success') {
          final token = uri.queryParameters['token'];
          if (token != null && token.isNotEmpty) {
            onLoggedIn(token);
          } else {
            setState(
              () => _googleError = "No token found in Google OAuth deep link.",
            );
          }
        }
      },
      onError: (err) {
        setState(() => _googleError = 'Deep link error: $err');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_jwt != null) {
    return MaterialApp(
        title: 'Kazi App',
        home: HomeScreen(onLogout: logout),
        debugShowCheckedModeBanner: false,
      );
    }
    if (_view == 'verify' && _registeredEmail != null) {
      return MaterialApp(
        title: 'Kazi App',
        home: VerificationScreen(
          email: _registeredEmail!,
          onSuccess: () => setState(() {
            _view = 'login';
            _registeredEmail = null;
          }),
        ),
        debugShowCheckedModeBanner: false,
      );
    }
    if (_view == 'login') {
      return MaterialApp(
        title: 'Kazi App',
        home: LoginScreen(
          email: _registeredEmail ?? '',
          onLoggedIn: onLoggedIn,
          onBackToRegister: onBackToRegister,
          onGoogleError: _googleError,
          onGoToVerification: (email) => onGoToVerification(email),
          resetSuccessMessage: _resetSuccessMessage,
          onForgotPassword: () => setState(() {
            _view = 'passwordResetRequest';
          }),
        ),
        debugShowCheckedModeBanner: false,
      );
    }
    if (_view == 'passwordResetRequest') {
      return MaterialApp(
        title: 'Kazi App',
        home: PasswordResetRequestScreen(
          onRequested: (email) => setState(() {
            _resetEmail = email;
            _view = 'passwordResetCode';
          }),
          onBackToLogin: () => setState(() {
            _view = 'login';
          }),
        ),
        debugShowCheckedModeBanner: false,
      );
    }
    if (_view == 'passwordResetCode') {
      return MaterialApp(
        title: 'Kazi App',
        home: PasswordResetCodeScreen(
          email: _resetEmail ?? '',
          onCodeVerified: (code) => setState(() {
            _resetCode = code;
            _view = 'passwordResetSet';
          }),
          onBack: () => setState(() {
            _view = 'passwordResetRequest';
          }),
        ),
        debugShowCheckedModeBanner: false,
      );
    }
    if (_view == 'passwordResetSet') {
      return MaterialApp(
        title: 'Kazi App',
        home: PasswordResetSetScreen(
          email: _resetEmail ?? '',
          code: _resetCode ?? '',
          onPasswordReset: () => setState(() {
            _view = 'login';
            _resetEmail = null;
            _resetCode = null;
            _resetSuccessMessage =
                'Password reset successful! You can now log in.';
          }),
          onBack: () => setState(() {
            _view = 'passwordResetCode';
          }),
        ),
        debugShowCheckedModeBanner: false,
      );
    }
    // Default: registration
    return MaterialApp(
      title: 'Kazi App',
      home: RegistrationScreen(
        onRegistered: onRegistered,
        onGoogleError: _googleError,
        onLoggedIn: onLoggedIn,
        onGoToLogin: onGoToLogin,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  final void Function(String email) onRegistered;
  final String? onGoogleError;
  final void Function(String jwt)
  onLoggedIn; // Add this to RegistrationScreen props
  final VoidCallback onGoToLogin;
  const RegistrationScreen({
    Key? key,
    required this.onRegistered,
    this.onGoogleError,
    required this.onLoggedIn,
    required this.onGoToLogin,
  }) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _message;
  bool _loading = false;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final res = await http.post(
        Uri.parse('$convexBackend/api/auth/crate-account'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'name': _fullNameController.text.trim(),
        }),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 201) {
        widget.onRegistered(_emailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
      } else if (json['error'] != null) {
        setState(() {
          _message = json['error'];
        });
      } else if (json is Map && json['result']?['error'] != null) {
        setState(() {
          _message = json['result']['error'];
        });
      } else if (json['message'] != null) {
        setState(() {
          _message = json['message'];
        });
      } else {
        setState(() {
          _message =
              'Could not complete registration. Please check your input and try again.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Failed to contact backend: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _googleNativeLogin() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final AuthorizationTokenResponse? result = await _appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              googleClientId,
              googleRedirectUri,
              serviceConfiguration: googleServiceConfig,
              scopes: ['openid', 'email', 'profile'],
            ),
          );
      if (result?.idToken == null) {
        setState(() {
          _message = 'Google sign-in failed: No idToken received.';
        });
        return;
      }
      final response = await http.post(
        Uri.parse('$convexBackend/api/auth/google-idtoken-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': result!.idToken,
          'name': _fullNameController.text.trim(),
        }),
      );
      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['token'] != null) {
        widget.onLoggedIn(json['token']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created & logged in with Google!'),
            ),
          );
        }
        return;
      } else {
        setState(() {
          _message =
              json['error'] ?? json['message'] ?? 'Unknown error from backend.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Google sign-in failed: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Register',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter your full name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (v) => v != null && v.length >= 8
                        ? null
                        : 'Password must be at least 8 chars',
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Register Account'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _loading
                          ? null
                          : widget
                                .onGoToLogin, // Not onRegistered anymore! Fixes logic.
                      child: const Text('Already have an account?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Create account with Google'),
                      onPressed: _loading ? null : _googleNativeLogin,
                    ),
                  ),
                  if (widget.onGoogleError != null) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        widget.onGoogleError!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  if (_message != null && _message!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _message!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final String email;
  final void Function(String jwt) onLoggedIn;
  final VoidCallback onBackToRegister;
  final String? onGoogleError;
  final void Function(String email)? onGoToVerification;
  final String? resetSuccessMessage;
  final VoidCallback? onForgotPassword;
  const LoginScreen({
    Key? key,
    required this.email,
    required this.onLoggedIn,
    required this.onBackToRegister,
    this.onGoogleError,
    this.onGoToVerification,
    this.resetSuccessMessage,
    this.onForgotPassword,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _message;
  bool _loading = false;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  bool _showVerifyBtn = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _message = null;
      _showVerifyBtn = false; // Always reset at new login attempt.
    });
    try {
      final res = await http.post(
        Uri.parse('$convexBackend/api/auth/login-account'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['token'] != null) {
        widget.onLoggedIn(json['token']);
      } else {
        final backendError = json['error'] ?? json['message'];
        if (backendError != null &&
            backendError.toString().toLowerCase().contains('verify')) {
          setState(() {
            _message = backendError;
            _showVerifyBtn = true;
          });
          return;
        } else if (json['error'] != null) {
          setState(() {
            _message = json['error'];
            _showVerifyBtn = false;
          });
        } else if (json['message'] != null) {
          setState(() {
            _message = json['message'];
            _showVerifyBtn = false;
          });
        } else {
          setState(() {
            _message = 'Login failed.';
            _showVerifyBtn = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _message = 'Failed to contact backend: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _googleLogin() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final AuthorizationTokenResponse? result = await _appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              googleClientId,
              googleRedirectUri,
              serviceConfiguration: googleServiceConfig,
              scopes: ['openid', 'email', 'profile'],
            ),
          );
      if (result?.idToken == null) {
        setState(() {
          _message = 'Google login failed: No idToken received.';
        });
        return;
      }
      final response = await http.post(
        Uri.parse('$convexBackend/api/auth/google-idtoken-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': result!.idToken}),
      );
      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['token'] != null) {
        widget.onLoggedIn(json['token']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged in with Google!')),
          );
        }
      } else {
        setState(() {
          _message =
              json['error'] ?? json['message'] ?? 'Unknown error from backend.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Google sign-in failed: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: (v) => v != null && v.length >= 8
                        ? null
                        : 'Password must be at least 8 chars',
                  ),
                  if (widget.resetSuccessMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.resetSuccessMessage!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_message != null && _message!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _message!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_showVerifyBtn)
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _loading = true;
                            _message = null;
                          });
                          final res = await http.post(
                            Uri.parse(
                              '$convexBackend/api/auth/resend-verification',
                            ),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              'email': _emailController.text.trim(),
                            }),
                          );
                          final json = jsonDecode(res.body);
                          setState(() {
                            _loading = false;
                          });
                          if (res.statusCode == 200 && json['ok'] == true) {
                            if (widget.onGoToVerification != null)
                              widget.onGoToVerification!(
                                _emailController.text.trim(),
                              );
                          } else {
                            setState(() {
                              _message =
                                  json['error'] ??
                                  'Could not resend verification code.';
                            });
                          }
                        },
                        child: const Text('Verify Now'),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Log In'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Login with Google'),
                      onPressed: _loading ? null : _googleLogin,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _loading ? null : widget.onBackToRegister,
                      child: const Text('Back to Register'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: widget.onForgotPassword,
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  if (widget.onGoogleError != null) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        widget.onGoogleError!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback onSuccess;
  const VerificationScreen({
    Key? key,
    required this.email,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _codeController = TextEditingController();
  String? _message;
  bool _loading = false;
  int _seconds = 90;
  Timer? _timer;
  bool _resendLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _seconds = 90;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  Future<void> _verifyCode() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final res = await http.post(
        Uri.parse('$convexBackend/api/auth/verify-email-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'code': _codeController.text.trim(),
        }),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['ok'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified! You may now log in.'),
            ),
          );
          widget.onSuccess();
        }
      } else {
        setState(() {
          _message = json['error'] ?? 'Invalid or expired code.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Network error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _resendLoading = true;
      _message = null;
    });
    try {
      final res = await http.post(
        Uri.parse('$convexBackend/api/auth/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['ok'] == true) {
        setState(() {
          _message = 'Verification code resent.';
        });
        _startTimer();
      } else {
        setState(() {
          _message = json['error'] ?? 'Could not resend verification code.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Network error: $e';
      });
    } finally {
      setState(() {
        _resendLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
        child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verify Your Email',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
            Text(
                  'Enter the 6-digit code sent to your email address (${widget.email}):',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: '6-digit code',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  enabled: !_loading,
                ),
                if (_message != null && _message!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _message!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 15,
                            ),
                          ),
            ),
          ],
        ),
      ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _verifyCode,
                        child: _loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Verify'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Center(
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: _seconds > 0 || _resendLoading
                            ? null
                            : _resendCode,
                        child: _resendLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _seconds > 0
                                    ? 'Resend Code (wait $_seconds s)'
                                    : 'Resend Code',
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordResetRequestScreen extends StatefulWidget {
  final void Function(String email) onRequested;
  final VoidCallback onBackToLogin;
  const PasswordResetRequestScreen({
    Key? key,
    required this.onRequested,
    required this.onBackToLogin,
  }) : super(key: key);

  @override
  State<PasswordResetRequestScreen> createState() =>
      _PasswordResetRequestScreenState();
}

class _PasswordResetRequestScreenState
    extends State<PasswordResetRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _message;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final res = await http.post(
        Uri.parse('$convexBackend/api/auth/send-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['ok'] == true) {
        widget.onRequested(_emailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset request sent!')),
        );
      } else {
        setState(() {
          _message =
              json['error'] ??
              json['message'] ??
              'Could not send password reset request.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Network error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password Reset Request',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Enter a valid email'
                        : null,
                  ),
                  if (_message != null && _message!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _message!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Request Password Reset'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: widget.onBackToLogin,
                      child: const Text('Back to Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordResetCodeScreen extends StatefulWidget {
  final String email;
  final void Function(String code) onCodeVerified;
  final VoidCallback onBack;
  const PasswordResetCodeScreen({
    Key? key,
    required this.email,
    required this.onCodeVerified,
    required this.onBack,
  }) : super(key: key);

  @override
  State<PasswordResetCodeScreen> createState() =>
      _PasswordResetCodeScreenState();
}

class _PasswordResetCodeScreenState extends State<PasswordResetCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  String? _message;
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final res = await http.post(
        Uri.parse('$convexBackend/api/auth/verify-password-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'code': _codeController.text.trim(),
        }),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['ok'] == true) {
        widget.onCodeVerified(_codeController.text.trim());
      } else {
        setState(() {
          _message =
              json['error'] ?? json['message'] ?? 'Invalid or expired code.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Network error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password Reset Code',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Enter the 6-digit code sent to your email address (${widget.email}):',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: '6-digit code',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    enabled: !_loading,
                  ),
                  if (_message != null && _message!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _message!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loading ? null : _verifyCode,
                          child: _loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Verify Code'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: widget.onBack,
                      child: const Text('Back to Password Reset Request'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordResetSetScreen extends StatefulWidget {
  final String email;
  final String code;
  final void Function() onPasswordReset;
  final VoidCallback onBack;
  const PasswordResetSetScreen({
    Key? key,
    required this.email,
    required this.code,
    required this.onPasswordReset,
    required this.onBack,
  }) : super(key: key);

  @override
  State<PasswordResetSetScreen> createState() => _PasswordResetSetScreenState();
}

class _PasswordResetSetScreenState extends State<PasswordResetSetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  String? _message;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final res = await http.post(
        Uri.parse('$convexBackend/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'code': widget.code,
          'newPassword': _passwordController.text,
        }),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['ok'] == true) {
        widget.onPasswordReset();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successful!')),
        );
      } else {
        setState(() {
          _message =
              json['error'] ?? json['message'] ?? 'Could not reset password.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Network error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set New Password',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Text('Enter your new password for ${widget.email}:'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (v) => v != null && v.length >= 8
                        ? null
                        : 'Password must be at least 8 chars',
                  ),
                  if (_message != null && _message!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _message!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _resetPassword,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Reset Password'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: widget.onBack,
                      child: const Text('Back to Password Reset Code'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onLogout;
  const HomeScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You are logged in.')));
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: onLogout,
          ),
        ],
      ),
      body: const Center(child: Text('Welcome! You are logged in.')),
    );
  }
}
