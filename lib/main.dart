import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:convex_flutter/convex_flutter.dart';

late ConvexClient convexClient;

// --- Set to your deployed Convex Auth backend (site URL, no trailing slash)
const convexBackend =
    'https://kindly-crow-554.convex.site'; // CHANGE to your prod Convex .site URL when needed

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  convexClient = await ConvexClient.init(
    deploymentUrl: convexBackend,
    clientId: "kazi-app-v1.0-demo1",
  );
  runApp(const KaziApp());
}

class KaziApp extends StatelessWidget {
  const KaziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kazi App',
      home: const RegistrationTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RegistrationTestScreen extends StatefulWidget {
  const RegistrationTestScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationTestScreen> createState() => _RegistrationTestScreenState();
}

class _RegistrationTestScreenState extends State<RegistrationTestScreen> {
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
          'provider': 'password',
          'flow': 'signUp',
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'name': _fullNameController.text.trim(),
        }),
      );
      if (res.statusCode == 201) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created & signed in successfully!'),
            ),
          );
        });
        setState(() {
          _message = null;
          _fullNameController.clear();
          _emailController.clear();
          _passwordController.clear();
        });
      } else {
        final error = jsonDecode(res.body);
        setState(() {
          _message = 'Backend error: \n${error['message'] ?? res.body}';
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

  Future<void> _signUpWithGoogle() async {
    final url = Uri.parse('$convexBackend/api/auth/signIn?provider=google');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      setState(() => _message = 'Google sign-in flow started in browser.');
    } else {
      setState(() => _message = 'Could not launch Google sign-in.');
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
                    child: Text('or', style: TextStyle(color: Colors.grey)),
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
}
