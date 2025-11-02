import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppBottomSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? footer;
  final double? maxHeight;

  const AppBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.footer,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxHeightCap =
            maxHeight ??
            (constraints.maxHeight < 800 ? constraints.maxHeight * 0.92 : 800);
        return Container(
          constraints: BoxConstraints(
            maxHeight: maxHeightCap,
            minHeight: 120,
            minWidth: double.infinity,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handlebar
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              // Title/subtitle header, with exact spacing like design
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textDark,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!,
                            style: const TextStyle(
                              color: AppTheme.inputDescription,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Body: scrollable if content exceeds available space
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: body,
                  ),
                ),
              ),
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: footer!,
                ),
            ],
          ),
        );
      },
    );
  }
}
