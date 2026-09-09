import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.prefixAsset,
    this.prefix,
    this.suffix,
    this.prefixIconColor,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.hintColor,
    this.borderColor,
    this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.inputFormatters,
    this.maxLength,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? hint;
  final String? prefixAsset;
  final Widget? prefix;
  final Widget? suffix;
  final Color? prefixIconColor;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Color? hintColor;
  final Color? borderColor;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor ?? AppColors.textFieldBorder),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.destructive),
    );

    Widget? prefixIcon = prefix;
    if (prefixIcon == null && prefixAsset != null) {
      prefixIcon = Padding(
        padding: const EdgeInsets.only(left: 14, right: 8),
        child: AppIcon(
          prefixAsset!,
          size: 22,
          color: prefixIconColor ?? AppColors.black,
        ),
      );
    }

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: autovalidateMode,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      textInputAction: textInputAction,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      style: AppTextStyles.style(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.white,
        counterText: '',
        hintStyle: AppTextStyles.style(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: hintColor ?? AppColors.textFieldHint,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIconConstraints: prefix != null
            ? const BoxConstraints(minWidth: 0, minHeight: 48)
            : const BoxConstraints(minWidth: 48, minHeight: 48),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 48),
        prefixIcon: prefixIcon,
        suffixIcon: suffix,
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: borderColor ?? AppColors.textFieldBorder,
            width: 1.5,
          ),
        ),
        errorBorder: errorBorder,
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.destructive, width: 1.5),
        ),
        errorStyle: AppTextStyles.style(
          fontSize: 12,
          color: AppColors.destructive,
        ),
      ),
    );
  }
}
