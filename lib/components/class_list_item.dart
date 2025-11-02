import 'package:flutter/material.dart';
import 'app_theme.dart';

class ClassListItem extends StatelessWidget {
  final String className;
  final int subjectCount;
  final VoidCallback? onTap;

  const ClassListItem({
    super.key,
    required this.className,
    required this.subjectCount,
    this.onTap,
  });

  String _getSubjectText(int count) {
    if (count == 1) {
      return '1 subject';
    }
    return '$count subjects';
  }

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
              // Graduation cap icon
              Icon(
                Icons.school_outlined,
                size: 16,
                color: AppTheme.inputDescription,
              ),
              const SizedBox(width: 8),
              // Class info (name and subject count)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      className,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getSubjectText(subjectCount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Right arrow icon
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
