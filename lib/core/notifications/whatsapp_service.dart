import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class WhatsAppService {
  /// Opens WhatsApp with a pre-filled message for a given phone number.
  /// 
  /// Phone number should be in international format without '+' or '00'.
  static Future<void> sendStatusUpdate({
    required String phoneNumber,
    required String customerName,
    required String orderTitle,
    required String status,
  }) async {
    final message = _generateMessage(customerName, orderTitle, status);
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Use the wa.me link for better compatibility
    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch WhatsApp URL: $url');
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  /// Opens the default SMS app with a pre-filled message.
  static Future<void> sendSMSUpdate({
    required String phoneNumber,
    required String customerName,
    required String orderTitle,
    required String status,
  }) async {
    final message = _generateMessage(customerName, orderTitle, status);
    final url = Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        debugPrint('Could not launch SMS URL: $url');
      }
    } catch (e) {
      debugPrint('Error launching SMS: $e');
    }
  }

  static String _generateMessage(String name, String order, String status) {
    return 'Hello $name, this is an update regarding your order "$order" at TailorSync. Your order status is now: ${status.toUpperCase()}. Thank you for choosing us!';
  }
}
