import 'package:flutter/services.dart';
import 'package:responsive_builder/responsive_builder.dart';

/// Centralized service for managing app orientation based on device type
class OrientationService {
  /// Set orientation preferences based on device type
  /// - Phones: Portrait only
  /// - Tablets: Landscape preferred
  static Future<void> setOrientationByDeviceType(DeviceScreenType deviceType) async {
    if (deviceType == DeviceScreenType.mobile) {
      // Lock phones to portrait
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      // Allow tablets to use landscape
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  /// Lock app to portrait orientation (for phones)
  static Future<void> lockToPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  /// Allow landscape orientation (for tablets)
  static Future<void> allowLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  /// Reset to allow all orientations
  static Future<void> resetOrientations() async {
    await SystemChrome.setPreferredOrientations([]);
  }
}

