import 'package:carzigo_partner/common_widgets/app_text_field.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KycDocNumber {
  KycDocNumber._();

  static const int aadhaar = 0;
  static const int pan = 1;
  static const int drivingLicense = 2;

  static String apiType(int index) {
    switch (index) {
      case pan:
        return 'pan';
      case drivingLicense:
        return 'driving_license';
      default:
        return 'aadhaar';
    }
  }

  static String cardLabel(String? apiType) {
    switch (apiType) {
      case 'pan':
        return AppStrings.panCard.tr();
      case 'driving_license':
        return AppStrings.drivingLicense.tr();
      default:
        return AppStrings.aadhaarCard.tr();
    }
  }

  static int indexFromApi(String? apiType) {
    switch (apiType) {
      case 'pan':
        return pan;
      case 'driving_license':
        return drivingLicense;
      default:
        return aadhaar;
    }
  }

  static bool isPlaceholder(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return true;
    return isMasked(text);
  }

  static bool isMasked(String? value) {
    final text = (value ?? '').trim().toLowerCase();
    if (text.isEmpty) return false;
    return text.contains('x') || text.contains('*');
  }

  static String label(int index) {
    switch (index) {
      case pan:
        return AppStrings.panCardNumber;
      case drivingLicense:
        return AppStrings.drivingLicenseNumber;
      default:
        return AppStrings.aadhaarCardNumber;
    }
  }

  static String hint(int index) {
    switch (index) {
      case pan:
        return AppStrings.enterPanCardNumber;
      case drivingLicense:
        return AppStrings.enterDrivingLicenseNumber;
      default:
        return AppStrings.enterAadhaarCardNumber;
    }
  }

  static TextInputType keyboardType(int index) {
    return index == aadhaar ? TextInputType.number : TextInputType.text;
  }

  static int maxLength(int index) {
    switch (index) {
      case pan:
        return 10;
      case drivingLicense:
        return 16;
      default:
        return 12;
    }
  }

  static List<TextInputFormatter> formatters(int index) {
    if (index == aadhaar) {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
      TextInputFormatter.withFunction((oldValue, newValue) {
        return newValue.copyWith(text: newValue.text.toUpperCase());
      }),
    ];
  }

  static String? validate(int index, String? value) {
    final text = (value ?? '').trim().toUpperCase();
    if (text.isEmpty) {
      return AppStrings.documentNumberRequired.tr();
    }
    switch (index) {
      case pan:
        if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(text)) {
          return AppStrings.panNumberInvalid.tr();
        }
      case drivingLicense:
        if (!RegExp(r'^[A-Z0-9]{8,16}$').hasMatch(text)) {
          return AppStrings.drivingLicenseNumberInvalid.tr();
        }
      default:
        if (!RegExp(r'^\d{12}$').hasMatch(text)) {
          return AppStrings.aadhaarNumberInvalid.tr();
        }
    }
    return null;
  }
}

class KycDocumentNumberSection extends StatelessWidget {
  const KycDocumentNumberSection({
    super.key,
    required this.selectedDoc,
    required this.controller,
    required this.validator,
  });

  final int selectedDoc;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    final masked = KycDocNumber.isMasked(controller.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          KycDocNumber.label(selectedDoc).tr(),
          style: AppTextStyles.style(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        AppTextField(
          key: ValueKey('${selectedDoc}_$masked'),
          controller: controller,
          hint: KycDocNumber.hint(selectedDoc).tr(),
          prefixAsset: AppAssets.personId,
          borderColor: AppColors.textFieldBorder,
          keyboardType: masked
              ? TextInputType.text
              : KycDocNumber.keyboardType(selectedDoc),
          textCapitalization: selectedDoc == KycDocNumber.aadhaar
              ? TextCapitalization.none
              : TextCapitalization.characters,
          maxLength: masked ? null : KycDocNumber.maxLength(selectedDoc),
          inputFormatters: masked
              ? const []
              : KycDocNumber.formatters(selectedDoc),
          validator: validator,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
