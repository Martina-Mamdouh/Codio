// lib/core/services/update_service.dart
import 'package:in_app_update/in_app_update.dart';
import 'package:flutter/material.dart';
import 'package:kodio_app/core/theme/app_theme.dart';

class UpdateService {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (!context.mounted) return; // تحقق إن الـ context لسه شغال

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          _showUpdateDialog(context);
        }
      } else {
        _showNoUpdateDialog(context);
      }
    } catch (e) {
      debugPrint('Error checking for update: $e');
      if (!context.mounted) return;
      _showErrorDialog(context);
    }
  }

  static void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
          backgroundColor: AppTheme.kDarkBackground,
          title: const Text(
            'تحديث متاح',
            style: TextStyle(
              color: Colors.white,
                                // fontFamily: 'Cairo', // Inherited
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'يتوفر إصدار جديد من التطبيق يحتوي على تحسينات وميزات جديدة',
            style: TextStyle(color: Colors.white70, fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'لاحقاً',
                style: TextStyle(color: Colors.white54, fontFamily: 'Cairo'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                try {
                  await InAppUpdate.startFlexibleUpdate();
                  await InAppUpdate.completeFlexibleUpdate();
                  navigator.pop();
                } catch (e) {
                  debugPrint('Error updating: $e');
                  navigator.pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kElectricLime,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'تحديث الآن',
                style: TextStyle(
                                    // fontFamily: 'Cairo', // Inherited
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
    );
  }

  static void _showNoUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          backgroundColor: AppTheme.kDarkBackground,
          title: const Text(
            '✓ التطبيق محدث',
            style: TextStyle(
              color: Colors.white,
                                // fontFamily: 'Cairo', // Inherited
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'أنت تستخدم أحدث إصدار من التطبيق',
            style: TextStyle(color: Colors.white70, fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'حسناً',
                style: TextStyle(
                  color: AppTheme.kElectricLime,
                                    // fontFamily: 'Cairo', // Inherited
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
    );
  }

  static void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          backgroundColor: AppTheme.kDarkBackground,
          title: const Text(
            'خطأ',
            style: TextStyle(
              color: Colors.white,
                                // fontFamily: 'Cairo', // Inherited
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'لا يمكن التحقق من التحديثات في الوقت الحالي',
            style: TextStyle(color: Colors.white70, fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'حسناً',
                style: TextStyle(
                  color: AppTheme.kElectricLime,
                                    // fontFamily: 'Cairo', // Inherited
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
    );
  }
}
