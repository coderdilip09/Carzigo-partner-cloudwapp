/// Base URL is up to `/api`. Paths after that are endpoints.
class ApiUrls {
  ApiUrls._();

  static const String baseUrl = 'https://api.carzigo.in/api';
  static const String appKeyHeader = 'x-app-key';
  static const String appKey = '9JyaABaAzumJRxd6BjqHsT';

  static const String sendOtp = 'auth/send-otp';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resendOtp = 'auth/resend-otp';
  static const String logout = 'auth/logout';
  static const String deleteAccount = 'auth/account';

  static const String profile = 'auth/profile';
  static const String uploads = 'uploads';
  static const String changePhoneSendOtp = 'auth/change-phone/send-otp';
  static const String changePhoneVerify = 'auth/change-phone/verify';

  static const String kycStatus = 'kyc';
  static const String kycAccountStatus = 'kyc/status';
  static const String kycIdentity = 'kyc/identity';
  static const String kycAddress = 'kyc/address';
  static const String kycLocalAddress = 'kyc/local-address';
  static const String kycAddressProof = 'kyc/address-proof';
  static const String kycDigilockerStart = 'kyc/digilocker/start';
  static const String kycDigilockerComplete = 'kyc/digilocker/complete';
  static const String kycBank = 'kyc/bank';
  static const String kycIfsc = 'kyc/ifsc';
  static const String kycReview = 'kyc/review';
  static const String kycSubmit = 'kyc/submit';

  static const String dashboard = 'partner/dashboard';
  static const String jobs = 'jobs';
  static const String services = 'partner/services';

  static const String referrals = 'partner/referrals';

  static const String notifications = 'partner/notifications';
  static const String notificationsDeviceToken = 'partner/notifications/device-token';

  static const String legal = 'legal';
  static const String legalTermsSlug = 'terms';
  static const String legalPrivacySlug = 'privacy';

  static const String help = 'help';
  static const String helpTopics = 'help/topics';
  static const String helpSearch = 'help/search';
  static const String helpContact = 'help/contact';

  static String sendOtpUrl() => _join(sendOtp);
  static String verifyOtpUrl() => _join(verifyOtp);
  static String resendOtpUrl() => _join(resendOtp);
  static String logoutUrl() => _join(logout);
  static String deleteAccountUrl() => _join(deleteAccount);

  static String profileUrl() => _join(profile);
  static String uploadsUrl() => _join(uploads);
  static String changePhoneSendOtpUrl() => _join(changePhoneSendOtp);
  static String changePhoneVerifyUrl() => _join(changePhoneVerify);

  static String kycStatusUrl() => _join(kycStatus);
  static String kycAccountStatusUrl() => _join(kycAccountStatus);
  static String kycIdentityUrl() => _join(kycIdentity);
  static String kycAddressUrl() => _join(kycAddress);
  static String kycLocalAddressUrl() => _join(kycLocalAddress);
  static String kycAddressProofUrl() => _join(kycAddressProof);
  static String kycDigilockerStartUrl() => _join(kycDigilockerStart);
  static String kycDigilockerCompleteUrl() => _join(kycDigilockerComplete);
  static String kycBankUrl() => _join(kycBank);
  static String kycIfscUrl(String code) => _join('$kycIfsc/$code');
  static String kycReviewUrl() => _join(kycReview);
  static String kycSubmitUrl() => _join(kycSubmit);

  static String dashboardUrl() => _join(dashboard);
  static String servicesUrl() => _join(services);
  static String jobsUrl() => _join(services);
  static String jobDetailsUrl(String id) => _join('$services/$id');
  static String jobStatusUrl(String id) => _join('$services/$id/status');

  static String referralsUrl() => _join(referrals);

  static String notificationsUrl() => _join(notifications);
  static String notificationsDeviceTokenUrl() =>
      _join(notificationsDeviceToken);

  static String legalUrl(String slug) => _join('$legal/$slug');
  static String cmsTermsUrl() => legalUrl(legalTermsSlug);
  static String cmsPrivacyUrl() => legalUrl(legalPrivacySlug);

  static String helpUrl() => _join(help);
  static String helpTopicsUrl() => _join(helpTopics);
  static String helpTopicUrl(String key) => _join('$helpTopics/$key');
  static String helpSearchUrl() => _join(helpSearch);
  static String helpContactUrl() => _join(helpContact);

  static String _join(String path) {
    if (baseUrl.isEmpty) return '';
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final cleaned = path.startsWith('/') ? path.substring(1) : path;
    return '$base$cleaned';
  }
}
