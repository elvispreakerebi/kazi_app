import 'package:flutter/material.dart';
import 'app_theme.dart';

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
  final double borderRadius;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.expanded = true,
    this.height = 48,
    this.borderRadius = AppTheme.radiusMd,
  }) : super(key: key);

  Color _bg(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return AppTheme.primary;
      case ButtonVariant.secondary:
        return AppTheme.secondary;
      case ButtonVariant.destructive:
        return AppTheme.destructive;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return AppTheme.white;
    }
  }

  Color _txt() {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.destructive:
        return AppTheme.white;
      case ButtonVariant.secondary:
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return AppTheme.textDark;
    }
  }

  BoxBorder? _border() {
    switch (variant) {
      case ButtonVariant.outline:
        return Border.all(color: AppTheme.outline, width: 1);
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
        borderRadius: BorderRadius.circular(borderRadius),
        border: _border(),
      ),
      child: child,
    );

    return SizedBox(
      width: expanded ? double.infinity : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onPressed,
          child: btn,
        ),
      ),
    );
  }
}
