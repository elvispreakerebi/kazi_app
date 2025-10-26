import 'package:flutter/material.dart';
import 'app_theme.dart';

class ErrorAlert extends StatefulWidget {
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
  State<ErrorAlert> createState() => _ErrorAlertState();
}

class _ErrorAlertState extends State<ErrorAlert>
    with SingleTickerProviderStateMixin {
  bool _visible = true;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    // Start timer to hide
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _visible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible || widget.message.isEmpty) return const SizedBox.shrink();
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(_fadeController),
      child: Container(
        margin: widget.margin,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.inputOutlineError.withOpacity(0.09),
          border: Border.all(
            color: AppTheme.inputOutlineError.withOpacity(0.4),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.icon ??
                const Icon(
                  Icons.error_outline,
                  color: AppTheme.inputOutlineError,
                  size: 22,
                ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                widget.message,
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
      ),
    );
  }
}
