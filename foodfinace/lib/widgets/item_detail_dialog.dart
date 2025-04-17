import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/person.dart';

// Dialog widget for showing item details and selecting payers
class ItemDetailDialog extends StatefulWidget {
  final Item item; // The item to display/edit
  final List<Person> people; // List of all available people
  final Function(List<int>) onSavePayers; // Callback when payers are saved
  final Function() onDeleteItem; // Callback when item should be deleted

  const ItemDetailDialog({
    super.key,
    required this.item,
    required this.people,
    required this.onSavePayers,
    required this.onDeleteItem,
  });

  @override
  State<ItemDetailDialog> createState() => _ItemDetailDialogState();
}

class _ItemDetailDialogState extends State<ItemDetailDialog> {
  late List<int> _currentPayerIds; // Local state for selected payers

  @override
  void initState() {
    super.initState();
    // Initialize local state with the item's current payers
    _currentPayerIds = List.from(widget.item.payerIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('รายละเอียด: ${widget.item.name}'),
      // Use SingleChildScrollView + Column for potentially long content
      content: SingleChildScrollView(
        child: SizedBox( // Constrain the width
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ราคา: ${widget.item.price.toStringAsFixed(2)} บาท'),
              const SizedBox(height: 16),
              const Text('เลือกคนจ่าย:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              if (widget.people.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('ยังไม่มีคนในรายชื่อ', style: TextStyle(color: Colors.grey)),
                )
              else
                // Use ListView.builder for the list of people
                ListView.builder(
                  shrinkWrap: true, // Important inside SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(), // Disable nested scrolling
                  itemCount: widget.people.length,
                  itemBuilder: (context, index) {
                    final person = widget.people[index];
                    final bool isPaying = _currentPayerIds.contains(person.id);
                    // CheckboxListTile for each person
                    return CheckboxListTile(
                      title: Text(person.name),
                      value: isPaying,
                      onChanged: (bool? selected) {
                        if (selected != null) {
                          // Update the local state of the dialog
                          setState(() {
                            if (selected) {
                              _currentPayerIds.add(person.id);
                            } else {
                              _currentPayerIds.remove(person.id);
                            }
                          });
                        }
                      },
                      controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        // Button to delete the item
        TextButton.icon(
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text('ลบรายการ', style: TextStyle(color: Colors.red)),
          onPressed: () {
            widget.onDeleteItem(); // Call the delete callback
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        // Button to cancel changes
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        // Button to save changes to payers
        ElevatedButton(
          onPressed: () {
            widget.onSavePayers(_currentPayerIds); // Call the save callback
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}
