import 'package:flutter/material.dart';
import 'app_theme.dart';

class SubjectCardItem extends StatelessWidget {
  final String subjectName;
  final int lessonPlanCount;
  final VoidCallback? onTap;

  const SubjectCardItem({
    super.key,
    required this.subjectName,
    required this.lessonPlanCount,
    this.onTap,
  });

  String _getLessonPlanText(int count) {
    if (count == 1) {
      return '1 lesson plan';
    }
    return '$count lesson plans';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.addClassContainerBg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              // Book icon
              Icon(
                Icons.menu_book_outlined,
                size: 16,
                color: AppTheme.inputDescription,
              ),
              const SizedBox(width: 8),
              // Subject info (name and lesson plan count)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subjectName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getLessonPlanText(lessonPlanCount),
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
