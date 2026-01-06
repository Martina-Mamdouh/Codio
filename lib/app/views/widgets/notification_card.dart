import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final Color accentColor;
  final IconData icon;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.accentColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat(
      'd MMM yyyy الساعة HH:mm',
    ).format(notification.createdAt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    notification.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(icon, color: accentColor, size: 18.w),
              ],
            ),

            SizedBox(height: 4.h),

            // النص
            Text(
              notification.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white60, fontSize: 12.sp),
            ),

            SizedBox(height: 6.h),

            // التاريخ والوقت
            Text(
              timeString,
              style: TextStyle(color: Colors.white38, fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }
}
