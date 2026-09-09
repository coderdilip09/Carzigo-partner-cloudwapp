import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/screens/notifications/notifications_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationsProvider(),
      child: Consumer<NotificationsProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AppBg(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: AppBackHeader(
                        title: AppStrings.notifications.tr(),
                        showBackText: false,
                        titleInline: true,
                      ),
                    ),
                    Expanded(child: _NotificationsBody(provider: provider)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({required this.provider});

  final NotificationsProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  AppStrings.noData.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.notifications.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 72),
        itemBuilder: (context, i) {
          final n = provider.notifications[i];
          return ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.peach,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const AppIcon(AppAssets.notificationFilled, size: 22),
            ),
            title: Text(
              n.title ?? '',
              style: AppTextStyles.style(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((n.body ?? '').isNotEmpty)
                  Text(
                    n.body!,
                    style: AppTextStyles.style(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                if ((n.time ?? '').isNotEmpty)
                  Text(
                    n.time!,
                    style: AppTextStyles.style(
                      fontSize: 11,
                      color: AppColors.black,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
