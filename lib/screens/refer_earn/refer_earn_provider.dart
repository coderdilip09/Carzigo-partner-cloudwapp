import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:carzigo_partner/utils/mock_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class ReferEarnProvider extends BaseProvider {
  static final _sample = (
    MockData.serviceCustomerInitials,
    MockData.serviceCustomer,
    MockData.serviceCustomerPhone,
    AppStrings.completedFirstWash,
  );

  final referredCustomers = [_sample, _sample, _sample];

  final allReferredCustomers = [
    _sample,
    _sample,
    _sample,
    _sample,
    _sample,
    _sample,
  ];

  void copyCode() {
    Clipboard.setData(const ClipboardData(text: MockData.referralCode));
    AppToast.success(AppStrings.referralCodeCopied.tr());
  }

  void copyLink() {
    Clipboard.setData(const ClipboardData(text: MockData.referralLink));
    AppToast.success(AppStrings.referralLinkCopied.tr());
  }
}
