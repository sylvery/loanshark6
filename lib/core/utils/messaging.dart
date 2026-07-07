import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Messaging {
  const Messaging();

  static String reminderMessage(String name, String amount) =>
      'Hi $name, this is a friendly reminder that your loan payment of '
      '$amount is due. Please arrange payment at your earliest convenience. '
      'Thank you.';

  static Future<void> openWhatsApp(
    BuildContext context,
    String phone,
    String message,
  ) async {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse(
      'https://wa.me/$cleaned?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      _snack(context, 'WhatsApp is not available on this device.');
    }
  }

  static Future<void> openSms(
    BuildContext context,
    String phone,
    String message,
  ) async {
    final uri = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      _snack(context, 'SMS is not available on this device.');
    }
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
