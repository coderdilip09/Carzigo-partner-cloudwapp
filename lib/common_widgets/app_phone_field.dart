import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppPhoneField extends StatefulWidget {
  const AppPhoneField({
    super.key,
    this.controller,
    this.onChanged,
    this.onCountryChanged,
    this.initialCountryCode = 'IN',
    this.suffix,
    this.borderColor,
    this.readOnly = false,
    this.showDivider = true,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<Country>? onCountryChanged;
  final String initialCountryCode;
  final Widget? suffix;
  final Color? borderColor;
  final bool readOnly;
  final bool showDivider;

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

class _AppPhoneFieldState extends State<AppPhoneField> {
  late Country _country;

  @override
  void initState() {
    super.initState();
    _country = CountryParser.parseCountryCode(widget.initialCountryCode);
  }

  int get _maxLength => _country.countryCode == 'IN' ? 10 : 15;

  Color get _fillColor =>
      widget.readOnly ? AppColors.background : AppColors.white;

  Color get _textColor => AppColors.black;

  void _openCountryPicker() {
    if (widget.readOnly) return;
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        flagSize: 22,
        backgroundColor: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        bottomSheetHeight: MediaQuery.sizeOf(context).height * 0.75,
        inputDecoration: InputDecoration(
          hintText: AppStrings.searchCountry.tr(),
          hintStyle: AppTextStyles.style(
            color: AppColors.textFieldHint,
            fontSize: 14,
          ),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        searchTextStyle: AppTextStyles.style(fontSize: 14),
        textStyle: AppTextStyles.style(fontSize: 14),
      ),
      onSelect: (Country country) {
        setState(() => _country = country);
        widget.onCountryChanged?.call(country);
      },
    );
  }

  Widget _buildFlag() {
    if (_country.countryCode == 'IN') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SvgPicture.asset(
          AppAssets.flagIn,
          width: 22,
          height: 14,
          fit: BoxFit.fill,
        ),
      );
    }
    return Text(
      _country.flagEmoji,
      style: TextStyle(
        fontSize: 16,
        height: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.borderColor ?? AppColors.border;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: widget.readOnly
            ? null
            : [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: widget.readOnly ? null : _openCountryPicker,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: widget.showDivider ? 4 : 8,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFlag(),
                    const SizedBox(width: 8),
                    Text(
                      '+${_country.phoneCode}',
                      style: AppTextStyles.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _textColor,
                      ),
                    ),
                    if (!widget.readOnly) ...[
                      const SizedBox(width: 2),
                      SvgPicture.asset(
                        AppAssets.chevronDown,
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (widget.showDivider)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: VerticalDivider(
                width: 16,
                thickness: 1,
                color: AppColors.border,
              ),
            ),
          Expanded(
            child: Center(
              child: TextField(
                controller: widget.controller,
                onChanged: widget.readOnly ? null : widget.onChanged,
                readOnly: widget.readOnly,
                enableInteractiveSelection: !widget.readOnly,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                keyboardType: TextInputType.phone,
                maxLength: _maxLength,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_maxLength),
                ],
                style: AppTextStyles.style(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _textColor,
                  height: 1.2,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: AppStrings.enterPhoneNumber.tr(),
                  hintStyle: AppTextStyles.style(
                    color: AppColors.textFieldHint,
                    fontSize: 14,
                    height: 1.2,
                  ),
                  filled: true,
                  fillColor: _fillColor,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                ),
              ),
            ),
          ),
          if (widget.suffix != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(child: widget.suffix!),
            ),
        ],
      ),
    );
  }
}
