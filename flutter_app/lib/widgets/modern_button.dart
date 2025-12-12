import 'package:flutter/material.dart';

class ModernButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool loading;
  const ModernButton({required this.label, required this.onPressed, this.loading = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
