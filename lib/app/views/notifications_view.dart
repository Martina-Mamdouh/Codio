import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'deal_details_view.dart';
import 'widgets/notification_card.dart';
import 'widgets/yellow_scaffold.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    // Refresh notifications when entering the screen to ensure latest state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use existing global provider instead of creating a new one
    return Consumer<NotificationsViewModel>(
      builder: (context, vm, child) {
        return YellowScaffold(
          title: 'الإشعارات',
          titleWidget: Row(
            children: [
              Text(
                'الإشعارات',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
              if (vm.newNotifications.isNotEmpty) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${vm.newNotifications.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (vm.newNotifications.isNotEmpty)
              TextButton(
                onPressed: () => vm.markAllAsRead(),
                child: Text(
                  'تحديد الكل كمقروء',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
          body: vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.kElectricLime),
                )
              : vm.errorMessage != null
                  ? Center(
                      child: Text(
                        vm.errorMessage!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  : (vm.newNotifications.isEmpty && vm.oldNotifications.isEmpty)
                      ? const Center(
                          child: Text(
                            'لا توجد إشعارات حالياً',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: vm.loadNotifications,
                          color: AppTheme.kElectricLime,
                          child: ListView(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            children: [
                              // قسم "جديد"
                              if (vm.newNotifications.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Text(
                                    'جديد',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: AppTheme.kElectricLime,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...vm.newNotifications.map(
                                  (n) => NotificationCard(
                                    notification: n,
                                    accentColor: Colors.redAccent,
                                    icon: Icons.error_outline,
                                    onTap: () async {
                                      // Mark as read
                                      vm.markOneAsRead(n);

                                      // Navigate to deal if linked
                                      if (n.dealId != null && context.mounted) {
                                        try {
                                          final deal = await SupabaseService()
                                              .getDealById(n.dealId!);
                                          if (deal != null && context.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DealDetailsView(deal: deal),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          debugPrint(
                                              'Error navigating to deal: $e');
                                        }
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: 24.h), // Spacing between sections
                              ],

                              // قسم "في وقت سابق"
                              if (vm.oldNotifications.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Text(
                                    'في وقت سابق',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: AppTheme.kElectricLime,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...vm.oldNotifications.map(
                                  (n) => NotificationCard(
                                    notification: n,
                                    accentColor: AppTheme.kElectricLime,
                                    icon: Icons.local_offer_outlined,
                                    onTap: () async {
                                      // Navigate to deal if linked
                                      if (n.dealId != null && context.mounted) {
                                        try {
                                          final deal = await SupabaseService()
                                              .getDealById(n.dealId!);
                                          if (deal != null && context.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DealDetailsView(deal: deal),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          debugPrint(
                                              'Error navigating to deal: $e');
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
        );
      },
    );
  }
}
