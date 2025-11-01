import 'package:flutter/material.dart';
import 'app_theme.dart';

class CreateLessonPlanCard extends StatelessWidget {
  final VoidCallback? onTap;
  const CreateLessonPlanCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 120),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFe6faff), Color(0xFFe0f6fb)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/file.png',
                height: 80,
                fit: BoxFit.contain,
                semanticLabel: 'Illustration for lesson plans',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Create lesson plan',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Material(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(9999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9999),
                    onTap: onTap,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.add,
                        color: AppTheme.textDark,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
