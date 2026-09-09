import 'package:carzigo_partner/models/cms_data_model.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class LegalPageProvider extends BaseProvider {
  LegalPageProvider(this.slug);

  final String slug;
  CmsDataModel? page;
  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    safeNotifyListeners();

    try {
      final res = await Api.getLegalPage(slug);
      if (res.isSuccess && res.data != null) {
        page = res.data;
      } else {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
      }
    } catch (e) {
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }
}
