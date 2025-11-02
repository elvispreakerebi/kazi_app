import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../../../components/app_page_header.dart';
import '../../../components/app_popover_menu.dart';
import '../../../components/app_button.dart';
import '../../../components/app_theme.dart';
import '../../../components/app_bottom_sheet.dart';
import '../../../shared/services/api_service.dart';
import '../../../providers/teacher_provider.dart';

class LessonPlanPage extends ConsumerStatefulWidget {
  final String lessonPlanId;

  const LessonPlanPage({
    super.key,
    required this.lessonPlanId,
  });

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

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _fetchLessonPlan();
  }

  @override
  void dispose() {
    _contentController.dispose();
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
      await _saveChanges();
    } else {
      // Enter edit mode
      setState(() {
        _isEditMode = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    final content = _contentController.text.trim();
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content cannot be empty')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating lesson plan: $e')),
      );
    }
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
                        text: _lessonPlanData?['title']?.toString() ?? 'this lesson plan',
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
                          await ApiService().deleteLessonPlan(widget.lessonPlanId);
                          // Refresh teacher overview counts
                          await ref
                              .read(teacherProvider.notifier)
                              .fetchTeacherDetailsAndCounts();
                          
                          if (mounted) {
                            Navigator.of(sheetContext).pop();
                            Navigator.of(context).pop(); // Go back to previous page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lesson plan deleted successfully'),
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
    // TODO: Implement recreate functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recreate functionality coming soon'),
      ),
    );
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

  Widget _buildPopoverMenu(BuildContext context) {
    return AppPopoverMenu(
      items: [
        AppPopoverMenuItem.title('Lesson plan actions'),
        AppPopoverMenuItem(
          label: 'Recreate',
          icon: Icons.refresh,
          onTap: (ctx) {
            Navigator.of(ctx).pop(); // Close popover
            _showRecreateLessonPlanSheet(context);
          },
        ),
        AppPopoverMenuItem(
          label: 'Delete',
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

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectivesSection() {
    final objective = _lessonPlanData?['objective']?.toString() ?? '';
    
    if (objective.isEmpty) {
      return const SizedBox.shrink();
    }

    // Parse objectives if they're separated by newlines or bullets
    final objectives = objective
        .split('\n')
        .map((o) => o.trim())
        .where((o) => o.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(
              Icons.flag_outlined,
              size: 18,
              color: AppTheme.inputDescription,
            ),
            const SizedBox(width: 8),
            const Text(
              'Lesson Objectives',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'By the end of the lesson, learners should be able to:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppTheme.textDark,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        ...objectives.map((obj) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      obj.replaceAll(RegExp(r'^[•\-\*]\s*'), ''),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                size: 18,
                color: AppTheme.inputDescription,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI Tip: "Would you like me to simplify objectives for lower-level learners?"',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
              title: _lessonPlanData?['title']?.toString() ?? 'Loading...',
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
                            'Error loading lesson plan: $_error',
                            style: const TextStyle(color: AppTheme.destructive),
                          ),
                        )
                      : _lessonPlanData == null
                          ? const Center(child: Text('Lesson plan not found'))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Metadata section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.addClassContainerBg,
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildMetadataRow(
                                          'Subject',
                                          _lessonPlanData?['subjectName']
                                                  ?.toString() ??
                                              '',
                                        ),
                                        _buildMetadataRow(
                                          'Class',
                                          _lessonPlanData?['className']
                                                  ?.toString() ??
                                              '',
                                        ),
                                        _buildMetadataRow(
                                          'Topic',
                                          _lessonPlanData?['title']?.toString() ?? '',
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Objectives section
                                  _buildObjectivesSection(),
                                  // Content section
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Lesson Plan Content',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 400,
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: _isEditMode
                                          ? Colors.white
                                          : AppTheme.addClassContainerBg,
                                      borderRadius: BorderRadius.circular(22),
                                      border: _isEditMode
                                          ? Border.all(
                                              color: AppTheme.inputOutlineFocused,
                                              width: 1.6,
                                            )
                                          : null,
                                    ),
                                    child: _isEditMode
                                        ? TextField(
                                            controller: _contentController,
                                            maxLines: null,
                                            minLines: 20,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: AppTheme.textDark,
                                              height: 1.6,
                                            ),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Enter lesson plan content...',
                                              hintStyle: TextStyle(
                                                color: AppTheme.inputDescription,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            _contentController.text.isEmpty
                                                ? 'No content available'
                                                : _contentController.text,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: AppTheme.textDark,
                                              height: 1.6,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 100), // Space for bottom buttons
                                ],
                              ),
                            ),
            ),
            // Bottom action bar
            if (!_isLoading && _error == null && _lessonPlanData != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.outline,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (!_isEditMode)
                      Expanded(
                        child: AppButton(
                          text: 'Save as PDF',
                          onPressed: () {
                            // TODO: Implement PDF export
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('PDF export coming soon'),
                              ),
                            );
                          },
                          variant: ButtonVariant.secondary,
                          borderRadius: 22,
                          height: 48,
                          expanded: true,
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

