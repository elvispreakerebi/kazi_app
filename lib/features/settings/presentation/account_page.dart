import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../../../components/app_page_header.dart';
import '../../../components/app_theme.dart';
import '../../../components/app_input.dart';
import '../../../components/app_button.dart';
import '../../../providers/teacher_provider.dart';
import '../../../shared/services/api_service.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _showPassword = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final teacher = ref.read(teacherProvider);
    _nameController = TextEditingController(text: teacher.name ?? '');
    _emailController = TextEditingController(text: teacher.email ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final teacher = ref.read(teacherProvider);
      final currentName = teacher.name ?? '';
      final currentEmail = teacher.email ?? '';

      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Only send fields that have changed
      final updates = <String, dynamic>{};
      if (name.isNotEmpty && name != currentName) {
        updates['name'] = name;
      }
      if (email.isNotEmpty && email != currentEmail) {
        updates['email'] = email;
      }
      if (password.isNotEmpty) {
        updates['password'] = password;
      }

      if (updates.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No changes to save')),
          );
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }

      await ApiService().editTeacherAccount(
        name: updates['name'] as String?,
        email: updates['email'] as String?,
        password: updates['password'] as String?,
      );

      // Refresh teacher data
      await ref.read(teacherProvider.notifier).fetchTeacherDetailsAndCounts();

      if (mounted) {
        // Clear password field after successful save
        _passwordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating account: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _backButton(BuildContext context) {
    final isIOS =
        Theme.of(context).platform == TargetPlatform.iOS || Platform.isIOS;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              backButton: _backButton(context),
              title: 'Account',
              showLogo: false,
              parentContext: context,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Below is your account details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.addClassContainerBg,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          AppInput(
                            label: 'Full name',
                            description: 'E.g Julius Aman',
                            controller: _nameController,
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: AppTheme.inputDescription,
                              size: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppInput(
                            label: 'Email address',
                            description: 'E.g a.julius@gmail.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              Icons.mail_outline,
                              color: AppTheme.inputDescription,
                              size: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppInput(
                            label: 'Password',
                            description: 'Enter new password',
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppTheme.inputDescription,
                              size: 16,
                            ),
                            rightLabelWidget: GestureDetector(
                              onTap: () =>
                                  setState(() => _showPassword = !_showPassword),
                              child: Text(
                                _showPassword ? 'Hide password' : 'Show password',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: AppTheme.inputDescription,
                                  fontSize: 15,
                                  letterSpacing: 0.05,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom action button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white),
              child: AppButton(
                text: _isSaving ? 'Saving...' : 'Save changes',
                onPressed: _isSaving ? null : _saveChanges,
                variant: ButtonVariant.primary,
                borderRadius: 22,
                height: 48,
                expanded: true,
                icon: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
