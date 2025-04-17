import 'package:flutter/material.dart';

// --- Calculator Widget ---

class CalculatorWidget extends StatefulWidget {
  final Function(double) onValue; // Callback function when OK is pressed
  final double initialValue; // Optional initial value for the display

  const CalculatorWidget({
    super.key,
    required this.onValue,
    this.initialValue = 0.0,
  });

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  String _display = "0"; // The text displayed on the calculator screen
  bool _waitingForOperand = true; // True if the next input should start a new number
  String? _pendingOperator; // The operator waiting to be applied (+, -, ×, ÷)
  double? _pendingValue; // The first operand waiting for the second

  @override
  void initState() {
    super.initState();
    // Set initial display value if provided and not zero
    if (widget.initialValue != 0.0) {
       _display = widget.initialValue.toStringAsFixed(widget.initialValue.truncateToDouble() == widget.initialValue ? 0 : 2);
       _waitingForOperand = false; // Ready to append or operate
    } else {
       _display = "0";
       _waitingForOperand = true;
    }
  }


  // Performs the calculation based on the pending operator
  double _calculate(double rightOperand, String pendingOperator) {
    double? leftOperand = _pendingValue;
    if (leftOperand == null) return rightOperand; // Should not happen if operator is pending

    switch (pendingOperator) {
      case '+':
        return leftOperand + rightOperand;
      case '-':
        return leftOperand - rightOperand;
      case '×':
        return leftOperand * rightOperand;
      case '÷':
        if (rightOperand == 0) {
          // Handle division by zero (return 0 or show error)
          return 0;
        }
        return leftOperand / rightOperand;
      default:
        return rightOperand; // Should not happen
    }
  }

  // Handles digit button presses
  void _digitPressed(String digit) {
    setState(() {
      // Prevent leading zeros unless it's the only digit
      if (_display == "0" && digit == "0") return;
      // Limit display length (optional)
      if (_display.length > 10 && !_waitingForOperand) return;

      if (_waitingForOperand) {
        // Start a new number
        _display = digit;
        _waitingForOperand = false;
      } else {
        // Append digit to the current number
        // Handle decimal point separately
        if (digit == '.' ) {
           if(!_display.contains('.')) { // Allow only one decimal point
             _display += digit;
           }
        } else {
           _display = (_display == "0" && digit != '.') ? digit : _display + digit;
        }
      }
    });
  }

  // Handles operator button presses (+, -, ×, ÷)
  void _operatorPressed(String operator) {
    setState(() {
      final operand = double.tryParse(_display) ?? 0.0; // Get current display value

      // If there's a pending operation, calculate it first
      if (_pendingValue != null && _pendingOperator != null && !_waitingForOperand) {
        final result = _calculate(operand, _pendingOperator!);
        _display = result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 2); // Format result
        _pendingValue = result; // Store result for chained operations
      } else {
        // Store the first operand
        _pendingValue = operand;
      }

      _waitingForOperand = true; // Expecting the next operand
      _pendingOperator = operator; // Store the pressed operator
    });
  }

  // Handles the equals button press
  void _equalPressed() {
    setState(() {
      final operand = double.tryParse(_display) ?? 0.0;

      // Perform calculation if an operator and value are pending
      if (_pendingOperator != null && _pendingValue != null) {
        final result = _calculate(operand, _pendingOperator!);
         _display = result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 2);
        _pendingValue = null; // Clear pending value after equals
        _pendingOperator = null; // Clear pending operator
      }
      // If no operator is pending, equals does nothing to the current display

      _waitingForOperand = true; // Ready for a new calculation
    });
  }

  // Handles the clear button press
  void _clearPressed() {
    setState(() {
      // Reset calculator state
      _display = "0";
      _waitingForOperand = true;
      _pendingOperator = null;
      _pendingValue = null;
    });
  }

  // Handles the OK button press, sending the current value back
  void _handleOk() {
    final value = double.tryParse(_display) ?? 0.0;
    widget.onValue(value); // Call the callback function
  }

  // Build the UI for the calculator
  @override
  Widget build(BuildContext context) {
    // Define button styles
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(16),
      textStyle: const TextStyle(fontSize: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
       backgroundColor: Colors.white, // Default button color
       foregroundColor: Colors.black,
    );
     final operatorButtonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(16),
      textStyle: const TextStyle(fontSize: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
       backgroundColor: Colors.grey[300], // Different color for operators
       foregroundColor: Colors.black,
    );
     final okButtonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(16),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
       backgroundColor: Colors.green, // OK button color
       foregroundColor: Colors.white,
    );

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
         color: Colors.grey[100],
         borderRadius: BorderRadius.circular(12),
         boxShadow: [
           BoxShadow(
             color: Colors.grey.withOpacity(0.5),
             spreadRadius: 2,
             blurRadius: 5,
             offset: const Offset(0, 3),
           ),
         ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Make column height fit content
        children: [
          // Display screen
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _display,
              style: const TextStyle(fontSize: 32, color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
          // Calculator buttons grid
          GridView.count(
            crossAxisCount: 4, // 4 buttons per row
            shrinkWrap: true, // Fit content height
            physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling
            mainAxisSpacing: 5, // Spacing between rows
            crossAxisSpacing: 5, // Spacing between columns
            children: [
              // Row 1
              ElevatedButton(onPressed: () => _digitPressed('7'), style: buttonStyle, child: const Text('7')),
              ElevatedButton(onPressed: () => _digitPressed('8'), style: buttonStyle, child: const Text('8')),
              ElevatedButton(onPressed: () => _digitPressed('9'), style: buttonStyle, child: const Text('9')),
              ElevatedButton(onPressed: () => _operatorPressed('÷'), style: operatorButtonStyle, child: const Text('÷')),
              // Row 2
              ElevatedButton(onPressed: () => _digitPressed('4'), style: buttonStyle, child: const Text('4')),
              ElevatedButton(onPressed: () => _digitPressed('5'), style: buttonStyle, child: const Text('5')),
              ElevatedButton(onPressed: () => _digitPressed('6'), style: buttonStyle, child: const Text('6')),
              ElevatedButton(onPressed: () => _operatorPressed('×'), style: operatorButtonStyle, child: const Text('×')),
              // Row 3
              ElevatedButton(onPressed: () => _digitPressed('1'), style: buttonStyle, child: const Text('1')),
              ElevatedButton(onPressed: () => _digitPressed('2'), style: buttonStyle, child: const Text('2')),
              ElevatedButton(onPressed: () => _digitPressed('3'), style: buttonStyle, child: const Text('3')),
              ElevatedButton(onPressed: () => _operatorPressed('-'), style: operatorButtonStyle, child: const Text('-')),
              // Row 4
              ElevatedButton(onPressed: _clearPressed, style: operatorButtonStyle, child: const Text('C')), // Clear button
              ElevatedButton(onPressed: () => _digitPressed('0'), style: buttonStyle, child: const Text('0')),
              ElevatedButton(onPressed: () => _digitPressed('.'), style: buttonStyle, child: const Text('.')), // Decimal point
              ElevatedButton(onPressed: () => _operatorPressed('+'), style: operatorButtonStyle, child: const Text('+')),
              // Row 5 (Equals and OK) - Spanning multiple columns if needed, or just place OK
               // Use SizedBox to fill empty grid cells if needed
              const SizedBox.shrink(), // Empty cell
              const SizedBox.shrink(), // Empty cell
              ElevatedButton(onPressed: _equalPressed, style: operatorButtonStyle, child: const Text('=')),
              ElevatedButton(onPressed: _handleOk, style: okButtonStyle, child: const Text('OK')),
            ],
          ),
        ],
      ),
    );
  }
}
