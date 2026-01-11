import '../constants/app_constants.dart';

class UrlUtils {
  static String cleanUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    var cleaned = url.trim();
    
    // Check for Markdown format [url](text) or [text](url)
    if (cleaned.startsWith('[') && cleaned.contains('](') && cleaned.endsWith(')')) {
      final startIndex = cleaned.indexOf('](') + 2;
      final endIndex = cleaned.length - 1;
      cleaned = cleaned.substring(startIndex, endIndex);
    } else if (cleaned.startsWith('[') && cleaned.contains(']')) {
      final end = cleaned.indexOf(']');
      cleaned = cleaned.substring(1, end);
    }

    // Handle relative paths from Supabase
    if (!cleaned.startsWith('http') && cleaned.isNotEmpty) {
      // Remove leading slash if exists
      if (cleaned.startsWith('/')) {
        cleaned = cleaned.substring(1);
      }
      
      // If the path already includes 'images/', we need to handle it carefully
      // AppConstants.storageBaseUrl already ends with 'images/'
      if (cleaned.startsWith('images/')) {
        cleaned = cleaned.substring(7); // Remove 'images/' prefix
      }
      
      // Prepend the bucket public URL
      cleaned = '${AppConstants.storageBaseUrl}$cleaned';
    }
    
    return cleaned;
  }

  static String constructFullUrl(String? url) {
    return cleanUrl(url);
  }
}
