import 'package:flutter/material.dart';
import 'app_theme.dart';

class ErrorAlert extends StatelessWidget {
  final String message;
  final EdgeInsets margin;
  final double borderRadius;
  final Widget? icon;

  const ErrorAlert({
    Key? key,
    required this.message,
    this.margin = const EdgeInsets.only(bottom: 16),
    this.borderRadius = 10,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.inputOutlineError.withOpacity(0.09),
        border: Border.all(
          color: AppTheme.inputOutlineError.withOpacity(0.4),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon ??
              const Icon(
                Icons.error_outline,
                color: AppTheme.inputOutlineError,
                size: 22,
              ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.inputOutlineError,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
