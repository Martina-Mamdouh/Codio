import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteAccountDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final bool isLoading;

  const DeleteAccountDialog({
    super.key,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Arabic direction
      child: AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8.w),
            Text(
              'حذف الحساب',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من حذف الحساب؟ سيتم حذف جميع بياناتك نهائياً. لا يمكن التراجع عن هذا الإجراء.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 15.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 16.h,
                    width: 16.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'حذف',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
