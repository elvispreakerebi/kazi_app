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
        height: 142, // FIX: constrain card Stack height
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
        child: Stack(
          children: [
            // Centered image stack
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/file.png',
                  height: 80,
                  fit: BoxFit.contain,
                  semanticLabel: 'Illustration for lesson plans',
                ),
              ),
            ),
            // Text left bottom
            Positioned(
              left: 0,
              bottom: 8,
              child: Text(
                'Create lesson plan',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            // Add (+) button circle right bottom
            Positioned(
              right: 0,
              bottom: 0,
              child: Material(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(9999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(9999),
                  onTap: onTap,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.add, color: AppTheme.textDark, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
