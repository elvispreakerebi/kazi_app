import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

class AppInput extends StatelessWidget {
  final String? label;
  final String? description;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final VoidCallback? onPrefixTap;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final String? initialValue;
  final int? maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool autoValidate;
  final bool autoFocus;
  final bool readOnly;
  final bool withButton;
  final VoidCallback? onButtonPressed;
  final String? buttonText;
  final String? passwordToggleText;
  final VoidCallback? onPasswordToggle;
  final Widget? rightLabelWidget;

  const AppInput({
    super.key,
    this.label,
    this.description,
    this.errorText,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onPrefixTap,
    this.textInputAction,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.initialValue,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.autoValidate = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.withButton = false,
    this.onButtonPressed,
    this.buttonText,
    this.passwordToggleText,
    this.onPasswordToggle,
    this.rightLabelWidget,
  });

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 1.6),
    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
  );

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null && errorText!.isNotEmpty;
    final Color borderColor = !enabled
        ? AppTheme.inputOutlineDisabled
        : hasError
        ? AppTheme.inputOutlineError
        : focusNode?.hasFocus ?? false
        ? AppTheme.inputOutlineFocused
        : AppTheme.inputOutline;
    final Color focusedBorderColor = hasError
        ? AppTheme.inputOutlineError
        : AppTheme.inputOutlineFocused;
    final Color labelColor = hasError
        ? AppTheme.inputLabelError
        : AppTheme.inputLabel;
    final Color descriptionColor = hasError
        ? AppTheme.inputOutlineError
        : AppTheme.inputDescription;

    Widget buildInputField() {
      return TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        obscureText: obscureText,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        minLines: minLines,
        maxLines: obscureText ? 1 : maxLines,
        inputFormatters: inputFormatters,
        autofocus: autoFocus,
        readOnly: readOnly,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 14,
          ),
          filled: true,
          fillColor: AppTheme.inputBg,
          prefixIcon: prefixIcon != null
              ? GestureDetector(onTap: onPrefixTap, child: prefixIcon)
              : null,
          suffixIcon: (passwordToggleText == null && suffixIcon != null)
              ? GestureDetector(onTap: onSuffixTap, child: suffixIcon)
              : null,
          hintText: description,
          hintStyle: TextStyle(color: AppTheme.inputDescription),
          enabledBorder: _border(borderColor),
          focusedBorder: _border(focusedBorderColor),
          errorBorder: _border(AppTheme.inputOutlineError),
          disabledBorder: _border(AppTheme.inputOutlineDisabled),
          border: _border(borderColor),
        ),
        style: const TextStyle(fontSize: 16, color: AppTheme.textDark),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label!,
                  style: TextStyle(
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                if (rightLabelWidget != null) rightLabelWidget!,
              ],
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: buildInputField()),
            if (withButton && buttonText != null && onButtonPressed != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onPressed: onButtonPressed,
                  child: Text(
                    buttonText!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 4),
            child: Row(
              children: [
                Icon(Icons.close, size: 17, color: AppTheme.inputOutlineError),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    errorText!,
                    style: TextStyle(
                      color: AppTheme.inputOutlineError,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (description != null && description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              description!,
              style: TextStyle(color: descriptionColor, fontSize: 13),
            ),
          ),
      ],
    );
  }
}