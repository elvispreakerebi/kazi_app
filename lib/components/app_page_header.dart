import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppPageHeader extends StatelessWidget {
  final Widget? backButton;
  final String? title;
  final bool showLogo;
  final List<Widget>? actions;
  final double? progress; // 0.0 to 1.0
  final String? progressText;

  const AppPageHeader({
    Key? key,
    this.backButton,
    this.title,
    this.showLogo = false,
    this.actions,
    this.progress,
    this.progressText,
  }) : super(key: key);

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
            padding: const EdgeInsets.only(top: 18, left: 16, right: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left section: back, logo, or title
                Expanded(
                  child: Row(
                    children: [
                      if (backButton != null) ...[
                        backButton!,
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
                            color: AppColors.foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Right side actions
                if (actions != null && actions!.isNotEmpty) ...[
                  Row(
                    children: List.generate(
                      actions!.length,
                      (i) => Padding(
                        padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                        child: actions![i],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        if (hasBottom)
          Padding(
            padding: const EdgeInsets.only(
              top: 12,
              left: 16,
              right: 16,
              bottom: 4,
            ),
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
                        backgroundColor: AppColors.secondary,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
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
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
