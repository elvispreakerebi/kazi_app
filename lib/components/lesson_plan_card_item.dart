import 'package:flutter/material.dart';
import 'app_theme.dart';

class LessonPlanCardItem extends StatelessWidget {
  final String title;
  final String? subjectName; // Optional subject name
  final VoidCallback? onTap;

  const LessonPlanCardItem({
    super.key,
    required this.title,
    this.subjectName,
    this.onTap,
  });

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
              // Lesson plan info (title and optional subject name)
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (subjectName != null && subjectName!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        subjectName!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
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

