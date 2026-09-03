import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/base_provider.dart';

class NotificationsProvider extends BaseProvider {
  final notifications = List.generate(
    6,
    (_) => (
      title: AppStrings.newJobAssigned,
      body: AppStrings.newJobAssignedBody,
      time: AppStrings.twoMinAgo,
    ),
  );
}
