import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:convex_flutter/convex_flutter.dart';

late ConvexClient convexClient;

// --- Set to your deployed Convex Auth backend (site URL, no trailing slash)
const convexBackend =
    'https://kindly-crow-554.convex.site'; // CHANGE to your prod Convex .site URL when needed

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
  // Simple in-memory store for registration/email
  String? _registeredEmail;
  String? _jwt;

  void onRegistered(String email) => setState(() => _registeredEmail = email);
  void onLoggedIn(String jwt) => setState(() => _jwt = jwt);
  void logout() => setState(() => _jwt = null);

  @override
  Widget build(BuildContext context) {
    if (_jwt != null) {
      return MaterialApp(
        title: 'Kazi App',
        home: HomeScreen(onLogout: logout),
        debugShowCheckedModeBanner: false,
      );
    }
    if (_registeredEmail == null) {
      return MaterialApp(
        title: 'Kazi App',
        home: RegistrationScreen(onRegistered: onRegistered),
        debugShowCheckedModeBanner: false,
      );
    } else {
      return MaterialApp(
        title: 'Kazi App',
        home: LoginScreen(
          email: _registeredEmail!,
          onLoggedIn: onLoggedIn,
          onBackToRegister: () => setState(() => _registeredEmail = null),
        ),
        debugShowCheckedModeBanner: false,
      );
    }
  }
}

class RegistrationScreen extends StatefulWidget {
  final void Function(String email) onRegistered;
  const RegistrationScreen({Key? key, required this.onRegistered})
    : super(key: key);

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
          _message = 'Unknown error.';
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
                          : () => widget.onRegistered(
                              _emailController.text.trim(),
                            ),
                      child: const Text('Already have an account?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Sign up with Google'),
                      onPressed: _loading ? null : _signUpWithGoogle,
                    ),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        _message!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
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

  Future<void> _signUpWithGoogle() async {
    final url = Uri.parse('$convexBackend/api/auth/signIn?provider=google');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      setState(() => _message = 'Google sign-in flow started in browser.');
    } else {
      setState(() => _message = 'Could not launch Google sign-in.');
    }
  }
}

class LoginScreen extends StatefulWidget {
  final String email;
  final void Function(String jwt) onLoggedIn;
  final VoidCallback onBackToRegister;
  const LoginScreen({
    Key? key,
    required this.email,
    required this.onLoggedIn,
    required this.onBackToRegister,
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
        // Will show snackbar via HomeScreen
      } else if (json['error'] != null) {
        setState(() {
          _message = json['error'];
        });
      } else if (json['message'] != null) {
        setState(() {
          _message = json['message'];
        });
      } else {
        setState(() {
          _message = 'Login failed.';
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
                    child: TextButton(
                      onPressed: _loading ? null : widget.onBackToRegister,
                      child: const Text('Back to Register'),
                    ),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        _message!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
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
