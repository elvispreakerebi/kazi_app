import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppPageHeader extends StatelessWidget {
  final Widget? backButton;
  final String? title;
  final bool showLogo;
  final List<Widget>? actions;
  final double? progress; // 0.0 to 1.0
  final String? progressText;
  final BuildContext? parentContext;

  const AppPageHeader({
    super.key,
    this.backButton,
    this.title,
    this.showLogo = false,
    this.actions,
    this.progress,
    this.progressText,
    this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final hasTop =
        backButton != null ||
        title != null ||
        showLogo ||
        (actions != null && actions!.isNotEmpty);
    final hasBottom =
        progress != null || (progressText != null && progressText!.isNotEmpty);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasTop)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left group: back button, logo, title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (backButton != null) ...[
                      backButton!,
                      if (showLogo || (title != null && title!.isNotEmpty))
                        const SizedBox(width: 8),
                    ],
                    if (showLogo)
                      Image.asset(
                        'assets/images/Kazi-Logo.png',
                        width: 64,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    if (showLogo && (title != null && title!.isNotEmpty))
                      const SizedBox(width: 8),
                    if (title != null && title!.isNotEmpty)
                      Text(
                        title!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          color: AppTheme.foreground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                // Right actions
                if (actions != null && actions!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(
                      actions!.length,
                      (i) => Padding(
                        padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                        child: actions![i] is Function
                            ? (actions![i] as dynamic)(parentContext ?? context)
                            : actions![i],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        // Progress bar + step text to the right
        if (hasBottom)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (progress != null)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress!,
                        minHeight: 7,
                        backgroundColor: AppTheme.secondary,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                if (progressText != null && progressText!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      progressText!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
