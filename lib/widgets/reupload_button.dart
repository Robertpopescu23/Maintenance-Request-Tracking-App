import 'package:flutter/material.dart';

class ReUploadButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ReUploadButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 16,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
