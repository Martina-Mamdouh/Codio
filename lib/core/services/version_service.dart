// lib/core/services/version_service.dart
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  static PackageInfo? _packageInfo;

  // Initialize the service
  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  // App name
  static String get appName => _packageInfo?.appName ?? 'Codio';
  static String get version => _packageInfo?.version ?? '1.0.0';
  static String get buildNumber => _packageInfo?.buildNumber ?? '1';
  static String get fullVersion => '$version ($buildNumber)';
  static String get packageName => _packageInfo?.packageName ?? '';
}
