import 'package:flutter/material.dart';

class UIFeedback {
  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(child: CircularProgressIndicator()),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static void hideLoading(BuildContext context) {
    try {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (_) {}
  }

  static void showSnack(
    BuildContext context,
    String message, {
    bool success = true,
  }) {
    final snack = SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green[700] : Colors.red[700],
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
