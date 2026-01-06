import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'deal_details_view.dart';
import 'widgets/notification_card.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationsViewModel()..loadNotifications(),
      child: Scaffold(
        backgroundColor: AppTheme.kDarkBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.kDarkBackground,
          elevation: 0,
          shape: const Border(
            bottom: BorderSide(color: Colors.white10, width: 1),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20.w,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('الإشعارات', style: TextStyle(color: Colors.white)),
        ),
        body: Consumer<NotificationsViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.kElectricLime),
              );
            }

            if (vm.errorMessage != null) {
              return Center(
                child: Text(
                  vm.errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            if (vm.newNotifications.isEmpty && vm.oldNotifications.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد إشعارات حالياً',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: vm.loadNotifications,
              color: AppTheme.kElectricLime,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                children: [
                  // Mark all as read button - only show when there are unread notifications
                  if (vm.newNotifications.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => vm.markAllAsRead(),
                        icon: Icon(
                          Icons.done_all,
                          color: AppTheme.kDarkBackground,
                          size: 20.w,
                        ),
                        label: Text(
                          'تحديد الكل كمقروء',
                          style: TextStyle(
                            color: AppTheme.kDarkBackground,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.kElectricLime,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  SizedBox(height: 4.h),

                  // قسم "جديد"
                  if (vm.newNotifications.isNotEmpty) ...[
                    Text(
                      'جديد',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppTheme.kElectricLime,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
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
                              final deal = await SupabaseService().getDealById(
                                n.dealId!,
                              );
                              if (deal != null && context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DealDetailsView(deal: deal),
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint('Error navigating to deal: $e');
                            }
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // قسم "في وقت سابق"
                  if (vm.oldNotifications.isNotEmpty) ...[
                    Text(
                      'في وقت سابق',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppTheme.kElectricLime,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...vm.oldNotifications.map(
                      (n) => NotificationCard(
                        notification: n,
                        accentColor: AppTheme.kElectricLime,
                        icon: Icons.local_offer_outlined,
                        onTap: () async {
                          // Navigate to deal if linked
                          if (n.dealId != null && context.mounted) {
                            try {
                              final deal = await SupabaseService().getDealById(
                                n.dealId!,
                              );
                              if (deal != null && context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DealDetailsView(deal: deal),
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint('Error navigating to deal: $e');
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
