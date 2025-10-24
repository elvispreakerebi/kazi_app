import 'package:flutter/material.dart';
import 'app_colors.dart';

enum ButtonVariant {
  primary, // default
  secondary,
  destructive,
  outline,
  ghost,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final Widget? icon;
  final bool expanded;
  final double height;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.expanded = true,
    this.height = 48,
  }) : super(key: key);

  Color _bg(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return AppColors.secondary;
      case ButtonVariant.destructive:
        return AppColors.destructive;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return AppColors.white;
    }
  }

  Color _txt() {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.destructive:
        return AppColors.white;
      case ButtonVariant.secondary:
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return AppColors.textDark;
    }
  }

  BoxBorder? _border() {
    switch (variant) {
      case ButtonVariant.outline:
        return Border.all(color: AppColors.outline, width: 1);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: 8)],
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: _txt(),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final btn = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      decoration: BoxDecoration(
        color: _bg(context),
        borderRadius: BorderRadius.circular(8),
        border: _border(),
      ),
      child: child,
    );

    return SizedBox(
      width: expanded ? double.infinity : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: btn,
        ),
      ),
    );
  }
}
