import 'package:flutter/material.dart';

/// ErrorMessage
/// -------------
/// Shows a consistent error message with retry option.
class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorMessage({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}