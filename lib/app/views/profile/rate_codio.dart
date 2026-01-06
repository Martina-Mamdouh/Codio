import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class StoreService {
  // غيّر هذه القيم لقيم تطبيقك
  static const String androidPackageName = 'com.yourcompany.kodio';
  static const String iosAppId = '1234567890';

  static Future<void> openStorePage() async {
    Uri url;

    if (Platform.isAndroid) {
      url = Uri.parse(
        'https://play.google.com/store/apps/details?id=$androidPackageName',
      );
    } else if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/app/id$iosAppId');
    } else {
      // منصات أخرى: افتح موقع بسيط
      url = Uri.parse('https://your-landing-page.com');
    }

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('لا يمكن فتح المتجر');
    }
  }
}
