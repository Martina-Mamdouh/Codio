import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';

/// Professional snackbar helper for consistent messaging
class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            _buildIcon(type),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: AppTheme.kLightText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onAction();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing12,
                    vertical: AppTheme.spacing8,
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    color: _getAccentColor(type),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: AppTheme.kElevatedBackground,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppTheme.spacing16),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          side: BorderSide(
            color: _getAccentColor(type).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        elevation: 8,
      ),
    );
  }

  static Widget _buildIcon(SnackbarType type) {
    IconData icon;
    Color color;

    switch (type) {
      case SnackbarType.success:
        icon = Icons.check_circle_rounded;
        color = AppTheme.kSuccess;
      case SnackbarType.error:
        icon = Icons.error_rounded;
        color = AppTheme.kError;
      case SnackbarType.warning:
        icon = Icons.warning_rounded;
        color = AppTheme.kWarning;
      case SnackbarType.info:
        icon = Icons.info_rounded;
        color = AppTheme.kInfo;
    }

    return Container(
      padding: EdgeInsets.all(AppTheme.spacing6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: AppTheme.iconSm),
    );
  }

  static Color _getAccentColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return AppTheme.kSuccess;
      case SnackbarType.error:
        return AppTheme.kError;
      case SnackbarType.warning:
        return AppTheme.kWarning;
      case SnackbarType.info:
        return AppTheme.kElectricLime;
    }
  }

  /// Show success message
  static void success(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.success);
  }

  /// Show error message
  static void error(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.error);
  }

  /// Show warning message
  static void warning(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.warning);
  }

  /// Show info message
  static void info(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.info);
  }

  /// Show login required message with action
  static void loginRequired(BuildContext context, {required VoidCallback onLogin}) {
    show(
      context,
      message: 'يجب تسجيل الدخول للمتابعة',
      type: SnackbarType.info,
      actionLabel: 'تسجيل الدخول',
      onAction: onLogin,
    );
  }
}

enum SnackbarType { success, error, warning, info }

/// Professional bottom sheet helper
class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
  }) {
    HapticFeedback.lightImpact();

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.kLightBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radius2xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.only(top: AppTheme.spacing12),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppTheme.kSubtleText.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  /// Show confirmation bottom sheet
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'تأكيد',
    String cancelLabel = 'إلغاء',
    bool isDangerous = false,
  }) {
    return show<bool>(
      context: context,
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: (isDangerous ? AppTheme.kError : AppTheme.kWarning)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDangerous ? Icons.delete_outline_rounded : Icons.help_outline_rounded,
                color: isDangerous ? AppTheme.kError : AppTheme.kWarning,
                size: AppTheme.iconLg,
              ),
            ),
            SizedBox(height: AppTheme.spacing16),
            // Title
            Text(
              title,
              style: TextStyle(
                color: AppTheme.kLightText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacing8),
            // Message
            Text(
              message,
              style: TextStyle(
                color: AppTheme.kSubtleText,
                fontSize: 14.sp,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacing24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppTheme.spacing14),
                      side: BorderSide(color: AppTheme.kCardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: Text(
                      cancelLabel,
                      style: TextStyle(
                        color: AppTheme.kLightText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDangerous ? AppTheme.kError : AppTheme.kElectricLime,
                      foregroundColor: isDangerous ? Colors.white : Colors.black,
                      padding: EdgeInsets.symmetric(vertical: AppTheme.spacing14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing8),
          ],
        ),
      ),
    );
  }
}

/// Professional dialog helper
class AppDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.kLightBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.kLightText,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppTheme.spacing16),
              content,
              if (actions != null) ...[
                SizedBox(height: AppTheme.spacing24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
