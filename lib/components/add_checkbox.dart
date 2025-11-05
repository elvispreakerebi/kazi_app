import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final bool enabled;
  final String? errorText;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final showError = errorText != null && errorText!.isNotEmpty;
    final color = showError
        ? AppTheme.inputOutlineError
        : enabled
        ? AppTheme.primary
        : AppTheme.inputOutlineDisabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          onTap: enabled ? () => onChanged(!value) : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: showError
                        ? AppTheme.inputOutlineError
                        : AppTheme.inputOutline,
                    width: 1.7,
                  ),
                  color: value ? color : AppTheme.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: value
                    ? Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
              if (label != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label!,
                    style: TextStyle(
                      color: enabled
                          ? (showError
                                ? AppTheme.inputOutlineError
                                : AppTheme.textDark)
                          : AppTheme.inputOutlineDisabled,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 5),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: AppTheme.inputOutlineError,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}