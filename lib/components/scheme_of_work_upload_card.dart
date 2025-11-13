import 'package:flutter/material.dart';
import 'app_theme.dart';

// Local illustration asset (update)
const _docIllustrationAsset = 'assets/images/file.png';

enum UploadCardState { idle, uploading, uploaded }

class SchemeOfWorkUploadCard extends StatelessWidget {
  final String title;
  final UploadCardState state;
  final double? progress; // 0..1
  final String? fileName;
  final VoidCallback? onUploadPressed;
  final VoidCallback? onRemovePressed;

  const SchemeOfWorkUploadCard({
    super.key,
    required this.title,
    required this.state,
    this.progress,
    this.fileName,
    this.onUploadPressed,
    this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.addClassContainerBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (state != UploadCardState.uploaded)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Image.asset(
                _docIllustrationAsset,
                width: 118,
                height: 86,
                fit: BoxFit.contain,
                semanticLabel: 'Document illustration',
              ),
            ),
          if (state == UploadCardState.idle) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.textDark,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: onUploadPressed,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: AppTheme.inputBg, width: 1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.upload_file,
                    size: 24,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),
          ] else if (state == UploadCardState.uploading) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.textDark,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              height: 4,
              child: LinearProgressIndicator(
                value: progress ?? 0,
                backgroundColor: AppTheme.secondary,
                color: AppTheme.primary,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Uploading file - ${(progress != null ? (progress! * 100).round() : 0)}%',
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textDark,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.left,
            ),
          ] else if (state == UploadCardState.uploaded) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textDark,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  _docIllustrationAsset,
                  width: 42,
                  height: 40,
                  fit: BoxFit.contain,
                  semanticLabel: 'Document icon',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onRemovePressed,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.delete_outline,
                        size: 22,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
