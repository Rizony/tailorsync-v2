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
    String? shopName,
    String? balanceDue,
    String? currency,
    DateTime? dueDate,
  }) async {
    final message = _generateMessage(
      name: customerName, 
      order: orderTitle, 
      status: status,
      shopName: shopName,
      balance: balanceDue,
      currency: currency,
      dueDate: dueDate,
    );
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  static Future<void> sendSMSUpdate({
    required String phoneNumber,
    required String customerName,
    required String orderTitle,
    required String status,
    String? shopName,
    String? balanceDue,
    String? currency,
    DateTime? dueDate,
  }) async {
    final message = _generateMessage(
      name: customerName, 
      order: orderTitle, 
      status: status,
      shopName: shopName,
      balance: balanceDue,
      currency: currency,
      dueDate: dueDate,
    );
    final url = Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (e) {
      debugPrint('Error launching SMS: $e');
    }
  }

  static String _generateMessage({
    required String name, 
    required String order, 
    required String status,
    String? shopName,
    String? balance,
    String? currency,
    DateTime? dueDate,
  }) {
    final shop = shopName ?? 'TailorSync';
    final dueStr = dueDate != null ? ' Expected delivery: ${dueDate.day}/${dueDate.month}/${dueDate.year}.' : '';
    final balanceStr = (balance != null && balance != '0' && balance != '0.0') 
        ? ' Outstanding balance: ${currency ?? '₦'}$balance.' 
        : '';

    return '*$shop Update* 🧵\n\n'
           'Hello $name!\n'
           'Your order "*$order*" status has been updated to: *${status.toUpperCase()}*.\n'
           '$dueStr$balanceStr\n\n'
           'Thank you for your business!';
  }
}
