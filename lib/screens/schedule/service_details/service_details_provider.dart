import 'package:carzigo_partner/utils/base_provider.dart';

class ServiceDetailsProvider extends BaseProvider {
  int currentStep = 1;

  void markStep(int step) {
    if (step == currentStep + 1) {
      currentStep = step;
      safeNotifyListeners();
    }
  }
}
