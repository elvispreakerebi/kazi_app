import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import '../../../components/app_page_header.dart';
import '../../../components/app_popover_menu.dart';
import '../../../components/app_button.dart';
import '../../../components/app_theme.dart';
import '../../../components/app_bottom_sheet.dart';
import '../../../components/download_lesson_plan_bottom_sheet.dart';
import '../../../shared/services/api_service.dart';
import '../../../providers/teacher_provider.dart';
import '../../../core/utils/html_decoder.dart';
import '../../../core/utils/markdown_sanitizer.dart';

class LessonPlanPage extends ConsumerStatefulWidget {
  final String lessonPlanId;

  const LessonPlanPage({super.key, required this.lessonPlanId});

  @override
  ConsumerState<LessonPlanPage> createState() => _LessonPlanPageState();
}

class _LessonPlanPageState extends ConsumerState<LessonPlanPage> {
  Map<String, dynamic>? _lessonPlanData;
  bool _isLoading = true;
  String? _error;
  bool _isEditMode = false;
  late TextEditingController _contentController;
  bool _isSaving = false;
  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _contentController.addListener(_onContentChanged);
    _fetchLessonPlan();
  }

  void _onContentChanged() {
    if (_isEditMode) {
      // Cancel existing timer
      _typingTimer?.cancel();

      // Show typing indicator
      if (!_isTyping) {
        setState(() {
          _isTyping = true;
        });
      }

      // Reset typing indicator after 2 seconds of no typing
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    _contentController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLessonPlan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final lessonPlan = await ApiService().getLessonPlan(widget.lessonPlanId);
      setState(() {
        _lessonPlanData = lessonPlan;
        _contentController.text = lessonPlan['content']?.toString() ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleEditMode() async {
    if (_isEditMode) {
      // Save changes
      _typingTimer?.cancel();
      await _saveChanges();
    } else {
      // Enter edit mode
      setState(() {
        _isEditMode = true;
        _isTyping = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Content cannot be empty')));
      return;
    }

    setState(() {
      _isSaving = true;
      _isTyping = false;
    });

    try {
      await ApiService().editLessonPlan(
        lessonPlanId: widget.lessonPlanId,
        content: content,
      );

      setState(() {
        _isEditMode = false;
        _isSaving = false;
      });

      // Refresh lesson plan data
      await _fetchLessonPlan();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson plan updated successfully')),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating lesson plan: $e')));
    }
  }

  void _showDownloadBottomSheet(BuildContext context) {
    if (_lessonPlanData == null) return;

    final title = _lessonPlanData!['title']?.toString() ?? '';
    final content = _contentController.text.isEmpty
        ? 'no_content_available'.tr()
        : sanitizeMarkdownForRender(
            decodeHtmlEntities(_contentController.text),
          );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DownloadLessonPlanBottomSheet(
          title: title,
          content: content,
          parentContext: context, // Pass parent context for ScaffoldMessenger
        );
      },
    );
  }

  void _showDeleteLessonPlanSheet(BuildContext context) {
    bool deleteLoading = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerCtx, modalSetState) {
            return AppBottomSheet(
              title: 'Delete lesson plan',
              body: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textDark,
                      height: 1.75,
                    ),
                    children: [
                      const TextSpan(text: "You're about to delete "),
                      TextSpan(
                        text:
                            _lessonPlanData?['title']?.toString() ??
                            'this lesson plan',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(
                        text:
                            ', doing so means all data belonging to this lesson plan will no longer exist. Are you sure about this?',
                      ),
                    ],
                  ),
                ),
              ),
              footer: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: "Close",
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                      },
                      variant: ButtonVariant.secondary,
                      borderRadius: 22,
                      height: 48,
                      expanded: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: deleteLoading ? "Deleting..." : "Yes, delete",
                      onPressed: () async {
                        if (deleteLoading) return;

                        modalSetState(() {
                          deleteLoading = true;
                        });

                        try {
                          await ApiService().deleteLessonPlan(
                            widget.lessonPlanId,
                          );
                          // Refresh teacher overview counts
                          await ref
                              .read(teacherProvider.notifier)
                              .fetchTeacherDetailsAndCounts();

                          if (mounted) {
                            Navigator.of(sheetContext).pop();
                            Navigator.of(
                              context,
                            ).pop(); // Go back to previous page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Lesson plan deleted successfully',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error deleting lesson plan: $e'),
                              ),
                            );
                          }
                        } finally {
                          modalSetState(() {
                            deleteLoading = false;
                          });
                        }
                      },
                      variant: ButtonVariant.destructive,
                      borderRadius: 22,
                      height: 48,
                      expanded: true,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRecreateLessonPlanSheet(BuildContext context) {
    bool recreateLoading = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerCtx, modalSetState) {
            return AppBottomSheet(
              title: 'Recreate lesson plan',
              body: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textDark,
                      height: 1.75,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            'This will create a new lesson plan with the same topic and objective. The current lesson plan will remain unchanged. Continue?',
                      ),
                    ],
                  ),
                ),
              ),
              footer: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: "Close",
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                      },
                      variant: ButtonVariant.secondary,
                      borderRadius: 22,
                      height: 48,
                      expanded: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: recreateLoading
                          ? "Creating..."
                          : "Recreate lesson plan",
                      onPressed: () async {
                        if (recreateLoading) return;

                        // Get required data from current lesson plan
                        final classId = _lessonPlanData?['classId']?.toString();
                        final subjectId = _lessonPlanData?['subjectId']
                            ?.toString();
                        final topic = _lessonPlanData?['title']?.toString();
                        final objective = _lessonPlanData?['objective']
                            ?.toString();

                        if (classId == null ||
                            subjectId == null ||
                            topic == null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Unable to recreate: missing lesson plan data',
                                ),
                              ),
                            );
                          }
                          Navigator.of(sheetContext).pop();
                          return;
                        }

                        modalSetState(() {
                          recreateLoading = true;
                        });

                        try {
                          final newLessonPlan = await ApiService()
                              .createLessonPlan(
                                classId: classId,
                                subjectId: subjectId,
                                topic: topic,
                                objective: objective?.isEmpty ?? true
                                    ? null
                                    : objective,
                              );

                          // Refresh teacher overview counts
                          await ref
                              .read(teacherProvider.notifier)
                              .fetchTeacherDetailsAndCounts();

                          if (mounted) {
                            final newLessonPlanId =
                                newLessonPlan['id']?.toString() ??
                                newLessonPlan['_id']?.toString() ??
                                '';

                            Navigator.of(sheetContext).pop();

                            if (newLessonPlanId.isNotEmpty) {
                              // Navigate to the new lesson plan
                              Navigator.of(context).pushReplacementNamed(
                                '/lesson-plan',
                                arguments: {'lessonPlanId': newLessonPlanId},
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Lesson plan recreated successfully',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Lesson plan created but unable to navigate',
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error recreating lesson plan: $e',
                                ),
                              ),
                            );
                          }
                        } finally {
                          modalSetState(() {
                            recreateLoading = false;
                          });
                        }
                      },
                      variant: ButtonVariant.primary,
                      borderRadius: 22,
                      height: 48,
                      expanded: true,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _backButton(BuildContext context) {
    final isIOS =
        Theme.of(context).platform == TargetPlatform.iOS || Platform.isIOS;

    // Check if we came from new lesson plan page, home page, or lesson plans page
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final fromNewLessonPlan = routeArgs?['fromNewLessonPlan'] == true;
    final fromHome = routeArgs?['fromHome'] == true;
    final fromLessonPlansPage = routeArgs?['fromLessonPlansPage'] == true;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (fromNewLessonPlan || fromHome) {
            // If coming from new lesson plan page or home page, go back to home
            Navigator.of(context).popUntil(
              (route) => route.isFirst || route.settings.name == '/home',
            );
          } else if (fromLessonPlansPage) {
            // If coming from lesson plans page, go back to lesson plans page
            Navigator.of(
              context,
            ).popUntil((route) => route.settings.name == '/lesson-plans');
          } else {
            // Otherwise, just pop normally
            Navigator.of(context).pop();
          }
        },
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

  Widget _buildPopoverMenu(BuildContext context) {
    return AppPopoverMenu(
      items: [
        AppPopoverMenuItem.title('lesson_plan_actions'.tr()),
        AppPopoverMenuItem(
          label: 'recreate'.tr(),
          icon: Icons.refresh,
          onTap: (ctx) {
            Navigator.of(ctx).pop(); // Close popover
            _showRecreateLessonPlanSheet(context);
          },
        ),
        AppPopoverMenuItem(
          label: 'delete'.tr(),
          icon: Icons.delete_outline,
          isDestructive: true,
          onTap: (ctx) {
            Navigator.of(ctx).pop(); // Close popover
            _showDeleteLessonPlanSheet(context);
          },
        ),
      ],
      anchor: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.secondary,
        ),
        alignment: Alignment.center,
        child: Icon(Icons.more_vert, color: AppTheme.textDark, size: 24),
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
              title: _lessonPlanData?['title']?.toString() ?? 'loading'.tr(),
              showLogo: false,
              parentContext: context,
              actions: [_buildPopoverMenu(context)],
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Text(
                        'error_loading_lesson_plan'.tr().replaceAll('{error}', _error!),
                        style: const TextStyle(color: AppTheme.destructive),
                      ),
                    )
                  : _lessonPlanData == null
                  ? Center(child: Text('lesson_plan_not_found'.tr()))
                  : Container(
                      color: Colors.white,
                      child: _isEditMode
                          ? SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: TextField(
                                  controller: _contentController,
                                  maxLines: null,
                                  minLines: 1,
                                  autofocus: false,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textDark,
                                    height: 1.6,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'enter_lesson_plan_content'.tr(),
                                    hintStyle: const TextStyle(
                                      color: AppTheme.inputDescription,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: MarkdownBody(
                                  data: _contentController.text.isEmpty
                                      ? 'no_content_available'.tr()
                                      : sanitizeMarkdownForRender(
                                          decodeHtmlEntities(
                                            _contentController.text,
                                          ),
                                        ),
                                  styleSheet: MarkdownStyleSheet(
                                    p: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.textDark,
                                      height: 1.6,
                                    ),
                                    h1: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                      height: 1.4,
                                    ),
                                    h2: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                      height: 1.4,
                                    ),
                                    h3: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                      height: 1.4,
                                    ),
                                    h4: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                      height: 1.4,
                                    ),
                                    h5: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                      height: 1.4,
                                    ),
                                    h6: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                      height: 1.4,
                                    ),
                                    listBullet: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.textDark,
                                    ),
                                    strong: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                    em: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: AppTheme.textDark,
                                    ),
                                    code: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'monospace',
                                      color: AppTheme.textDark,
                                      backgroundColor: AppTheme.secondary,
                                    ),
                                    codeblockDecoration: BoxDecoration(
                                      color: AppTheme.secondary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    codeblockPadding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                            ),
                    ),
            ),
            // Bottom action bar
            if (!_isLoading && _error == null && _lessonPlanData != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    if (!_isEditMode)
                      Expanded(
                        child: AppButton(
                          text: 'download'.tr(),
                          onPressed: () {
                            _showDownloadBottomSheet(context);
                          },
                          variant: ButtonVariant.secondary,
                          borderRadius: 22,
                          height: 48,
                          expanded: true,
                          icon: const Icon(
                            Icons.download,
                            size: 16,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                    if (!_isEditMode) const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        text: _isSaving
                            ? 'Saving...'
                            : (_isEditMode ? 'Save changes' : 'Edit'),
                        onPressed: _isSaving ? null : _toggleEditMode,
                        variant: ButtonVariant.primary,
                        borderRadius: 22,
                        height: 48,
                        expanded: true,
                        icon: _isEditMode && !_isSaving
                            ? const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              )
                            : _isSaving
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
          ],
        ),
      ),
    );
  }
}
