import 'package:flutter/material.dart';
import 'app_theme.dart';

class ClassCard extends StatelessWidget {
  final String className;
  final int subjectCount;
  final VoidCallback onAdd;

  const ClassCard({
    super.key,
    required this.className,
    required this.subjectCount,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.addClassContainerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  className,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$subjectCount subjects',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    color: AppTheme.inputDescription.withOpacity(0.95),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 20, color: AppTheme.primary),
            label: const Text(
              'Add',
              style: TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              side: const BorderSide(color: AppTheme.outline, width: 1),
              backgroundColor: AppTheme.white,
            ),
          ),
        ],
      ),
    );
  }
}
