import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bill_splitting_app/providers/bill_provider.dart';
import 'package:bill_splitting_app/widgets/number_keyboard.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(text: '0');
  final List<String> _selectedPeople = [];
  bool _showKeyboard = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'รายการ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          _nameController.text.isEmpty ? 'อาหาร' : _nameController.text,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showKeyboard = true;
                            });
                          },
                          child: Text(
                            _priceController.text,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'คนจ่าย (${_selectedPeople.length} คน คนละ ${_calculatePerPerson()} บาท)',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (billProvider.people.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final person in billProvider.people)
                              FilterChip(
                                label: Text(person.name),
                                selected: _selectedPeople.contains(person.name),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedPeople.add(person.name);
                                    } else {
                                      _selectedPeople.remove(person.name);
                                    }
                                  });
                                },
                              ),
                          ],
                        )
                      else
                        const Text('ไม่มีคนจ่าย กรุณาเพิ่มคนจ่ายก่อน'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedPeople.clear();
                            for (final person in billProvider.people) {
                              _selectedPeople.add(person.name);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add),
                            const SizedBox(width: 8),
                            const Text('เลือกทุกคน'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'เพิ่มชื่อคนจ่าย',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_nameController.text.trim().isNotEmpty) {
                              billProvider.addPerson(_nameController.text);
                              setState(() {
                                _selectedPeople.add(_nameController.text);
                                _nameController.clear();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('เพิ่ม'),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedPeople.isNotEmpty && double.parse(_priceController.text) > 0) {
                      billProvider.addFoodItem(
                        _nameController.text.isEmpty ? 'อาหาร' : _nameController.text,
                        double.parse(_priceController.text),
                        _selectedPeople,
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณาเลือกคนจ่ายและใส่ราคา')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('ตกลง'),
                ),
                if (_showKeyboard)
                  NumberKeyboard(
                    onKeyPressed: (value) {
                      if (value == 'CLEAR') {
                        setState(() {
                          _priceController.text = '0';
                        });
                      } else if (value == 'BACK') {
                        if (_priceController.text.length > 1) {
                          setState(() {
                            _priceController.text = _priceController.text.substring(0, _priceController.text.length - 1);
                          });
                        } else {
                          setState(() {
                            _priceController.text = '0';
                          });
                        }
                      } else if (value == 'OK') {
                        setState(() {
                          _showKeyboard = false;
                        });
                      } else {
                        setState(() {
                          if (_priceController.text == '0') {
                            _priceController.text = value;
                          } else {
                            _priceController.text += value;
                          }
                        });
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _calculatePerPerson() {
    if (_selectedPeople.isEmpty) return '0';
    final price = double.tryParse(_priceController.text) ?? 0;
    return (price / _selectedPeople.length).toStringAsFixed(2);
  }
}
