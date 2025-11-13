import 'package:flutter/material.dart';
import 'app_theme.dart';

class LessonPlanListItem extends StatelessWidget {
  final String title;
  final String subjectName;
  final VoidCallback? onTap;

  const LessonPlanListItem({
    super.key,
    required this.title,
    required this.subjectName,
    this.onTap,
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
              // Book icon
              Icon(
                Icons.menu_book,
                size: 16,
                color: AppTheme.inputDescription,
              ),
              const SizedBox(width: 8),
              // Lesson plan info (title and subject name)
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
                    const SizedBox(height: 8),
                    Text(
                      subjectName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

