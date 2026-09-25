class AppConstants {
  AppConstants._();

  static const String androidPackageId = 'com.cw.carzigopartner';

  /// App Store numeric ID. Fill after the partner app is published.
  static const String appStoreId = '';

  static String get storeListingUrl {
    if (appStoreId.isNotEmpty) {
      return 'https://apps.apple.com/app/id$appStoreId';
    }
    return 'https://play.google.com/store/apps/details?id=$androidPackageId';
  }
}
