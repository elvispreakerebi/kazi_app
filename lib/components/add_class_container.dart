import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_input.dart';

class AddClassContainer extends StatelessWidget {
  final int classIndex;
  final bool firstClass;
  final VoidCallback? onDelete;
  final TextEditingController nameController;
  final TextEditingController gradeController;
  final String? nameError;
  final String? gradeError;
  final String? namePlaceholder;
  final String? gradePlaceholder;

  const AddClassContainer({
    super.key,
    required this.classIndex,
    required this.firstClass,
    required this.onDelete,
    required this.nameController,
    required this.gradeController,
    this.nameError,
    this.gradeError,
    this.namePlaceholder,
    this.gradePlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.addClassContainerBg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInput(
                label: 'Class ${classIndex + 1} name',
                controller: nameController,
                prefixIcon: const Icon(
                  Icons.school_outlined,
                  color: AppTheme.inputDescription,
                ),
                errorText: nameError,
                description:
                    namePlaceholder ?? 'E.g P5 Class or Primary 5 Class',
              ),
              const SizedBox(height: 20),
              AppInput(
                label: 'Grade level',
                controller: gradeController,
                prefixIcon: const Icon(
                  Icons.layers_outlined,
                  color: AppTheme.inputDescription,
                ),
                errorText: gradeError,
                description: gradePlaceholder ?? 'E.g P5 or Primary 5',
              ),
            ],
          ),
        ),
        if (!firstClass)
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.inputDescription,
              ),
              tooltip: 'Delete this class',
              onPressed: onDelete,
              splashRadius: 20,
            ),
          ),
      ],
    );
  }
}
