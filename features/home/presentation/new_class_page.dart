import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import 'dart:math' as math;
import '../../../components/app_page_header.dart';
import '../../../components/app_input.dart';
import '../../../components/app_button.dart';
import '../../../components/app_theme.dart';
import '../../../providers/class_provider.dart';
import '../../../providers/teacher_provider.dart';

class NewClassPage extends ConsumerStatefulWidget {
  const NewClassPage({super.key});

  @override
  ConsumerState<NewClassPage> createState() => _NewClassPageState();
}

class _NewClassPageState extends ConsumerState<NewClassPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gradeLevelController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _gradeLevelFocusNode = FocusNode();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _gradeLevelController.dispose();
    _nameFocusNode.dispose();
    _gradeLevelFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final gradeLevel = _gradeLevelController.text.trim();

    if (name.isEmpty || gradeLevel.isEmpty) {
      setState(() {
        _error = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      await ref.read(classProvider.notifier).addClasses([
        {'name': name, 'gradeLevel': gradeLevel},
      ], context);

      if (mounted) {
        // Refresh classes to update the list
        await ref.read(classProvider.notifier).fetchClasses();
        // Refresh teacher overview counts to update the home page cards
        await ref.read(teacherProvider.notifier).fetchTeacherDetailsAndCounts();
        Navigator.of(context).pop(); // Go back to home page
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
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
    final classState = ref.watch(classProvider);
    final isLoading = _isLoading || classState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              backButton: _backButton(context),
              title: 'New class',
              showLogo: false,
              parentContext: context,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: math.max(
                    MediaQuery.of(context).viewInsets.bottom,
                    24,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter details below to create a new class',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Inputs container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.addClassContainerBg,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppInput(
                            label: 'Class name',
                            description: 'E.g P5 Class or Primary 5 Class',
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            prefixIcon: const Icon(
                              Icons.school_outlined,
                              color: AppTheme.inputDescription,
                              size: 16,
                            ),
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) {
                              _gradeLevelFocusNode.requestFocus();
                            },
                            errorText:
                                _error != null &&
                                    _nameController.text.trim().isEmpty
                                ? _error
                                : null,
                          ),
                          const SizedBox(height: 20),
                          AppInput(
                            label: 'Grade level',
                            description: 'E.g P5 or Primary 5',
                            controller: _gradeLevelController,
                            focusNode: _gradeLevelFocusNode,
                            prefixIcon: const Icon(
                              Icons.layers_outlined,
                              color: AppTheme.inputDescription,
                              size: 16,
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              _handleSave();
                            },
                            errorText:
                                _error != null &&
                                    _gradeLevelController.text.trim().isEmpty
                                ? _error
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_error != null && _error!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.destructive.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppTheme.destructive,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: AppTheme.destructive,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    AppButton(
                      text: 'Save class',
                      variant: ButtonVariant.primary,
                      onPressed: isLoading ? null : _handleSave,
                      height: 48,
                      borderRadius: AppTheme.radiusFull,
                      icon: isLoading
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