import 'package:flutter/material.dart';

class NumberKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;

  const NumberKeyboard({
    super.key,
    required this.onKeyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          _buildRow(['7', '8', '9', '÷']),
          _buildRow(['4', '5', '6', '×']),
          _buildRow(['1', '2', '3', '-']),
          _buildRow(['CLEAR', '0', 'BACK', '+']),
          _buildOkButton(),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: SizedBox(
            height: 60,
            child: TextButton(
              onPressed: () => onKeyPressed(key),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: Text(
                key == 'BACK' ? '⌫' : key,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOkButton() {
    return Container(
      width: double.infinity,
      height: 60,
      color: Colors.green,
      child: TextButton(
        onPressed: () => onKeyPressed('OK'),
        child: const Text(
          'OK',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
