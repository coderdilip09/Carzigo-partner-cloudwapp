import 'package:carzigo_partner/models/notification_data_model.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

class NotificationsProvider extends BaseProvider {
  NotificationsProvider() {
    load();
  }

  List<NotificationDataModel> notifications = [];
  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    safeNotifyListeners();

    try {
      final res = await Api.getNotifications();
      if (res.isSuccess) {
        notifications = res.data ?? [];
      } else {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
      }
    } catch (e, st) {
      debugPrint('Get notifications failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }
}
