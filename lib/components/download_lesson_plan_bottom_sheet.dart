import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/utils/lesson_plan_exporter.dart';
import 'app_bottom_sheet.dart';
import 'app_theme.dart';

class DownloadLessonPlanBottomSheet extends StatelessWidget {
  final String title;
  final String content;
  final Function(String filePath)? onDownloadComplete;
  final BuildContext? parentContext; // Parent context for ScaffoldMessenger

  const DownloadLessonPlanBottomSheet({
    super.key,
    required this.title,
    required this.content,
    this.onDownloadComplete,
    this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'download_lesson_plan'.tr(),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'select_download_format'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _DownloadOption(
            icon: Icons.picture_as_pdf,
            title: 'download_as_pdf'.tr(),
            subtitle: 'pdf_format_description'.tr(),
            onTap: () async {
              final parentCtx = parentContext ?? context;
              Navigator.of(context).pop();
              await _handleDownload(parentCtx, 'pdf');
            },
          ),
          const Divider(height: 1, thickness: 1, color: AppTheme.outline),
          _DownloadOption(
            icon: Icons.insert_drive_file,
            title: 'download_as_docs'.tr(),
            subtitle: 'docs_format_description'.tr(),
            onTap: () async {
              final parentCtx = parentContext ?? context;
              Navigator.of(context).pop();
              await _handleDownload(parentCtx, 'docs');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleDownload(BuildContext context, String format) async {
    // Check if context is still mounted/valid
    if (!context.mounted) return;

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Text('generating_file'.tr()),
            ],
          ),
          duration: const Duration(seconds: 30),
        ),
      );

      String? filePath;
      
      switch (format) {
        case 'pdf':
          filePath = await LessonPlanExporter.generatePDF(
            title: title,
            content: content,
          );
          break;
        case 'docs':
          filePath = await LessonPlanExporter.generateDOCS(
            title: title,
            content: content,
          );
          break;
      }

      if (filePath != null) {
        final fileName = filePath.split('/').last;
        
        // Try to share the file, but handle plugin errors gracefully
        final shareSuccess = await LessonPlanExporter.shareFile(filePath, fileName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('file_downloaded_success'.tr()),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        // If sharing failed (plugin not registered), log it but don't show error
        // since the file was still generated successfully
        if (!shareSuccess) {
          debugPrint('File generated successfully at: $filePath');
          debugPrint('Share functionality unavailable - plugin not registered. Please restart the app.');
        }
        
        if (onDownloadComplete != null) {
          onDownloadComplete!(filePath);
        }
      } else {
        throw Exception('Failed to generate file');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_downloading_file'.tr().replaceAll('{error}', e.toString())),
          ),
        );
      }
    }
  }
}

class _DownloadOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DownloadOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: AppTheme.textDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.inputDescription,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.inputDescription,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

