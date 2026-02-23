import 'package:flutter/material.dart';
import 'package:tailorsync_v2/core/errors/failures.dart';

void showErrorSnackBar(BuildContext context, Object error) {
  String message = 'An unexpected error occurred';

  if (error is Failure) {
    message = error.message;
  } else if (error is String) {
    message = error.replaceAll('Exception:', '').trim();
    // Catch-all for unhandled Supabase API errors slipping as string
    if (message.contains('SocketException') || message.contains('ClientException')) {
      message = 'Network error. Please check your internet connection.';
    }
  } else {
    message = error.toString().replaceAll('Exception: ', '').trim();
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
